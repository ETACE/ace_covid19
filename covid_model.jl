module CovidAgent
using Agents
mutable struct GenericAgent <: AbstractAgent
    id::Int
    pos::Tuple{Int,Int} #region
    type::Int # 1 - nsec+1 HH, nsec + 2 - 2*(nsec+1) Firm, man / service / Food/public
    age:: Int # 1 young, 2 old
    cor::Int #infection status: 1 susceptible, 2 infected, 3 recovered, 4 infected with mutant
    vaccinated::Bool # true, if agent has been vaccinated
    cortime:: Int # time of infection
    infect:: Int # number of people infected by this agent
    emp:: Int #employer ID, 0 is unemployed
    shorttime:: Bool # on short time
    shorttimecounter:: Int # Number of weeks on short time
    homeoffice:: Bool # homeoffice
    worker:: Dict{Int,CovidAgent.GenericAgent} # list of firm employees
    workershorttime:: Dict{Int,CovidAgent.GenericAgent} # list of firm employees on short time
    income:: Float64 # average income
    saving::Float64 # savings of HH and firms
    consbud::Array{Float64,1} # consumption budget for HH for three cons types
    prevconsbud::Array{Float64,1} # consumption budget from previous period
    shopday::Array{Int,1} # array of shopping days in the week
    shoprepeat:: Array{Bool,1} # indicator repetition of shopping trip possible
    product::Float64 # productiviy of firm
    stock::Float64 # stock of product of firm
    demand::Float64 #firm's demand in previous week
    demandexp::Float64 # firm’s demand estimate
    rev::Float64 # firm revenues
    pastrev::Array{Float64,1} # array of last 4 weekly revenes
    markup::Float64 # firm markup
    fixedcosts::Float64 # firms fixed costs
end

end

# function for roulette wheel selection based on fitness vector vec
function conselect(vect::Array{Float64,1})
    vecn = size(vect)[1]
    vecsum = sum(vect)
    vecr = rand()*vecsum
    for i=1:vecn
        if sum(vect[1:i]) >= vecr
            return i
            break
        end
    end
end


function getagent(id::Int)
    return covidmodel[id]
end

# one step in the dynamics
function model_step!(covidmodel)
    global hh, firms, lochh, unemplist, shorttimelist, cas, daycounter, noinf, noinfmut, unemp, consumption, weeklyconsumption, shoppers, nsec
    global regcons, regemp, actshoplist, pubacc, empcount, tau,trigger, proftax, totaldiv, totalfixedcosts
    global virus, unempcount, shorttimecount, oldcount, R0count,gdp, genhomeoffice, noinftraj
    global bankruptcypossible, inactivefirms, sumbailouts, totalaccounts, divperhh, totalsav

    global contact_count_traj, contact_work_traj, contact_social_traj, contact_shop_traj
    global contact_count, contact_work, contact_social, contact_shop, contact_num, nosuscep

    global updatefixedcosts, bankruptcount, curinfcount, curinfregcount

    # reset consumption counter
    consumption = zeros(nsec, k1, k2)
    #reset total savings
    totalsav = 0

    #determine mortaliy
    noinf = 0
    noinfmut = 0
    aginf = 0
    for i in union(hh[1],hh[2])
        if (getagent(i).cor ==2) || (getagent(i).cor ==4)
            noinf = noinf +1
        end
        if (getagent(i).cor ==4)
            noinfmut = noinfmut +1
        end
        if getagent(i).cor > 1
            aginf +=1
        end
    end
    push!(totinftraj,aginf)  # number of infected and recoverd
    mort = (min(hcap,icufrac*noinf) /(icufrac*noinf))*mortl  + (1 - min(hcap,icufrac*noinf) / (icufrac*noinf))*morth

    # determine first which of the young hh is travelling
    #lochhytemp = deepcopy(lochh[1,:,:]) # temp list of young at locations
    postemp = [(0,0) for i=1:nhh] # temp list of young positions



    lochhytemp = [Dict{Int,CovidAgent.GenericAgent}() for a = 1:2, i=1:k1, j=1:k2]
    for a=1:2
        for i=1:k1
            for j=1:k2
                for k in keys(lochh[a,i,j])
                    lochhytemp[a,i,j][k] = lochh[a,i,j][k]
                end
            end
        end
    end

    for i in hh[1]  # only young households travel
        agent = getagent(i)
        if rand() < ptravel
            posh = agent.pos
            posn = [rand(1:k1),rand(1:k2)]
            delete!(lochhytemp[posh[1],posh[2]],i)
            lochhytemp[posn[1],posn[2]][i] = agent
            postemp[i] = (posn[1],posn[2]) # save new position
        else
            postemp[i] =agent.pos # stick to default position
        end
    end

    for i in hh[2] # old agents do not travel
        postemp[i] =getagent(i).pos # stick to default position
    end

    # firm decisions once a week
    if daycounter == 0
        totaldiv = 0. # sums dividends of all firms
        totalfixedcosts = 0. # sums fixed costs of all firms
        proftax = 0. # total profit tax
        gdp = 0.
        inactivefirms = 0
        sumbailouts = 0.0
        badbankacc = 0.0
        actshoplist = [[] for tt=1:nsec, i=1:k1, j2 = 1:k2]

        totprice = zeros(nsec)
        pricecount = zeros(nsec)
        permlist = shuffle(firms)
        for id in permlist
            firm = getagent(nhh+id)
            if firm.type-(nsec+1) <= nsec # not a public sector office
                numworker = length(firm.worker)

                # firms collect profits, pay dividends, wages, taxes, update demand estimate
                profit = firm.rev - wage[firm.type-(nsec+1)]*numworker - firm.fixedcosts
                totalfixedcosts += firm.fixedcosts

                # determine dividend
                for revt = 1:3
                    firm.pastrev[revt] = firm.pastrev[revt+1]
                end
                firm.pastrev[4] = firm.rev
                divthr = savtar[firm.type-(nsec+1)]*mean(firm.pastrev) # dividend threhshold
                if firm.saving + (1-tau)*max(0,profit) > divthr
                    div = (1-tau)*max(0,profit)
                else
                    div = divrate*(1-tau)*max(0,profit)
                end
                totaldiv += div  # add to total dividends
                proftax += tau*max(0,profit)
                firm.saving += profit-tau*max(0,profit) - div

                # pricing
                if weeklyconsumption[firm.type-(nsec+1), firm.pos[1], firm.pos[2]] > 0
                    marketshare = firm.demand / weeklyconsumption[firm.type-(nsec+1), firm.pos[1], firm.pos[2]]
                    firm.markup = etmin[firm.type-(nsec+1)] + marketshare*(etmax[firm.type-(nsec+1)]-etmin[firm.type-(nsec+1)])
                else
                    firm.markup = etmin[firm.type-(nsec+1)]
                end

                firm.demandexp = (1 - rhodem)*firm.demandexp + rhodem*firm.demand # update demand expectation
                firm.demand = 0. # reset weekly demand
                firm.rev = 0. # reset weekly revenue

                # production, hiring/firing
                if firm.stock > 0
                    # mormal plan
                    prodplan = max(0,(firm.demandexp*(1 + buff[firm.type-(nsec+1)]) - (1-de[firm.type-(nsec+1)])*firm.stock))
                else
                    # stronger expansion if stock is empty
                    prodplan = max(0,(firm.demandexp*(1 + zerostockboost*buff[firm.type-(nsec+1)]) - (1-de[firm.type-(nsec+1)])*firm.stock))
                end
                labdem = ceil(prodplan / firm.product) - numworker

                if firm.saving < 0 && bailoutprogram
                    sumbailouts += - firm.saving
                    firm.saving = 0
                end

                if firm.saving < 0 && bankruptcypossible
                    prodplan = 0
                    labdem = -numworker
                end

                for (id2, stworker) in firm.workershorttime
                    stworker.shorttimecounter += 1

                    # move worker from short term to unemployed if:
                    # - short time program has ended
                    # - worker excedded maximum time in short time
                    # - firm is bankrupt
                    if (!shorttimeprogram || stworker.shorttimecounter > shorttimeperiod || (firm.saving < 0 && bankruptcypossible))
                        delete!(firm.workershorttime,id2)
                        delete!(shorttimelist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],id2)
                        unemplist[firm.type-(nsec+1),stworker.pos[1],stworker.pos[2]][id2] = stworker
                        stworker.shorttime = false
                        stworker.shorttimecounter = 0
                        stworker.emp = 0
                    end
                end

                if labdem < 0 # random firing
                    firelist = shuffle(collect(keys(firm.worker)))[1:Int(-labdem)]
                    for id2 in firelist
                        fireagent = getagent(id2)
                        if shorttimeprogram && rand() < shorttimeprob && !(firm.saving < 0 && bankruptcypossible)
                            delete!(firm.worker,id2)
                            firm.workershorttime[id2] = fireagent
                            shorttimelist[firm.type-(nsec+1),fireagent.pos[1],fireagent.pos[2]][id2] = fireagent # put on regional short time list
                            fireagent.shorttime = true
                            fireagent.shorttimecounter = 0
                        else
                            delete!(firm.worker,id2)
                            unemplist[firm.type-(nsec+1),fireagent.pos[1],fireagent.pos[2]][id2] = fireagent # put on regional unemploymentlist
                            fireagent.emp = 0
                        end
                    end
                    numworker += labdem
                elseif labdem > 0 # hiring
                    numhire = min(labdem)
                    numhirefromshorttime = min(numhire, length(firm.workershorttime))
                    numhirefrommarket = min(numhire - numhirefromshorttime, length(unemplist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]])) # check if firm is rationed on labor market

                    if numhirefromshorttime > 0
                        hirelist = shuffle(collect(keys(firm.workershorttime)))[1:Int(numhirefromshorttime)] # search among unemployd from firms short time list
                        for id2 in hirelist
                            hireagent = getagent(id2)
                            firm.worker[id2] = hireagent
                            delete!(firm.workershorttime,id2) # remove from firms short time list
                            delete!(shorttimelist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],id2) # remove from regional unemploymentlist
                            hireagent.shorttime = false
                            hireagent.shorttimecounter = 0
                        end
                        numworker += numhirefromshorttime
                    end

                    if numhirefrommarket > 0
                        hirelist = shuffle(collect(keys(unemplist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]])))[1:Int(numhirefrommarket)] # search among unemployd in region
                        for id2 in hirelist
                            hireagent = getagent(id2)
                            firm.worker[id2] = hireagent
                            delete!(unemplist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],id2) # remove from regional unemploymentlist
                            hireagent.emp = id
                        end
                        numworker += numhirefrommarket
                    end
                end

                firm.stock = (1-de[firm.type-(nsec+1)])*firm.stock + numworker*firm.product # update product stock with production
                gdp += (numworker*wage[firm.type-(nsec+1)]+firm.fixedcosts)*(1+firm.markup)/(1 - buff[firm.type-(nsec+1)]*de[firm.type-(nsec+1)])
                if firm.stock > 0
                    push!(actshoplist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],id) # if sotcvk positive add to actve shops
                end
            else # public sector office
                gdp += length(firm.worker)*wage[nsec+1]*(1+fcvcratio[nsec+1])
            end
            if updatefixedcosts  # update fixed costs
                firm.fixedcosts = fcvcratio[firm.type-(nsec+1)] * wage[firm.type-(nsec+1)]*length(firm.worker) # fixed costs here prop to vc
            else
                if firm.fixedcosts < fcvcratio[firm.type-(nsec+1)] * wage[firm.type-(nsec+1)]*length(firm.worker) # adjust fc only if firm expands
                    firm.fixedcosts = fcvcratio[firm.type-(nsec+1)] * wage[firm.type-(nsec+1)]*length(firm.worker)
                end
            end
            if firm.type < 2*(nsec+1) # temp delete
                totprice[firm.type-(nsec+1)] += (wage[firm.type-(nsec+1)] + firm.fixedcosts / (length(firm.worker)+10^(-5)))*(1+firm.markup)/ (firm.product*(1 - buff[firm.type-(nsec+1)]*de[firm.type-(nsec+1)]))
                pricecount[firm.type-(nsec+1)] += 1
            end
            if firm.saving < 0 && bankruptcypossible
                badbankacc -= firm.saving
                setdiff!(firms,(firm.id-nhh))
                setdiff!(actshoplist[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],(firm.id-nhh))
                setdiff!(locf[firm.type-(nsec+1),firm.pos[1],firm.pos[2]],(firm.id-nhh))
                bankruptcount[firm.type-(nsec+1)] += 1
                kill_agent!(firm,covidmodel)
            end
        end # end firm loop
        #println(totprice ./ pricecount)

        weeklyconsumption = zeros(nsec, k1, k2)


        # government pays unemployment benefits, psensions and public sector, adjusts tax rate
        pubsur = proftax + tau*sum(empcount.*wage) + tau*(sum(empcount)+sum(unempcount)+sum(shorttimecount)+oldcount)*divperhh- (1-tau)*(sum(unempcount.*unempbenefit) + sum(shorttimecount.*shorttimewage) + oldcount*pension) - empcount[nsec+1]*wage[nsec+1]
        pubacc += pubsur

        # Cost of bailouts to the public account
        pubacc -= (sumbailouts + badbankacc)
        # --- End of tax period ---

        tauhat = max(0,(sum(unempcount.*unempbenefit) + sum(shorttimecount.*shorttimewage) + oldcount*pension + empcount[nsec+1]*wage[nsec+1] - debtfrac*pubacc) /
        ((proftax / tau) + sum(empcount.*wage) + sum(unempcount.*unempbenefit) + sum(shorttimecount.*shorttimewage) + oldcount*pension +
        (sum(empcount)+sum(unempcount)+sum(shorttimecount)+oldcount)*divperhh)) #taxrate needed to balance budget

        tau = (1-tauadj)*tau + tauadj*tauhat

        # reset employment, unemployment and shorttime counter
        empcount = zeros(nsec+1)
        unempcount = zeros(nsec)
        shorttimecount = zeros(nsec)
        oldcount = 0

        # calculate div per hh
        divperhh = (totaldiv+totalfixedcosts) / size(union(hh[1],hh[2]))[1]  # equasl share of total dividends for each hh
    end # end daycounter == 0



    #reset consumption counter
    consumption = zeros(nsec,k1,k2)

    #resent local shoppers list
    shoppers = [Dict{Int,CovidAgent.GenericAgent}() for tt=1:nsec, i=1:k1, j=1:k2]


    curinfcount = zeros(2)
    curinfregcount = zeros(2,k1,k2)
    # Household loop
    permlist = shuffle(union(hh[1],hh[2]))
    for ii in permlist
        agent = getagent(ii)
        # potential death of agent

        if (agent.cor == 2) || (agent.cor == 4) # if infected
            if rand() < mort[agent.age]
                setdiff!(hh[agent.age],agent.id)
                delete!(lochh[agent.age,agent.pos[1],agent.pos[2]],agent.id)
                delete!(lochh[agent.age,agent.pos[1],agent.pos[2]],agent.id)
                cas[agent.pos[1],agent.pos[2]][agent.age] += 1
                push!(R0count,agent.infect)
                if agent.age == 1
                    delete!(lochhytemp[postemp[agent.id][1],postemp[agent.id][2]],agent.id)
                    if agent.emp ==0
                        delete!(unemplist[agent.type,agent.pos[1],agent.pos[2]],agent.id)
                    else
                        employer = getagent(nhh+agent.emp)
                        if agent.shorttime
                            delete!(employer.workershorttime,agent.id)
                            delete!(shorttimelist[agent.type,agent.pos[1],agent.pos[2]],agent.id)
                        else
                            delete!(employer.worker,agent.id)
                        end
                    end
                end
                # transfer savings of HH to random other HH
                permlisttemp = shuffle(union(hh[1],hh[2]))
                heiragent = getagent(permlisttemp[1])
                heiragent.saving += agent.saving
                kill_agent!(agent,covidmodel)
                continue
            end
            agent.cortime = agent.cortime-1 # if not dying reduce recovery time by one
            if agent.cortime ==0
                agent.cor = 3
                push!(R0count,agent.infect)
            end
        end

    # hh determine consumption budgets and count unemp once a week
        if daycounter ==0
            agent.saving += sum(agent.consbud)   # non-spent consumption budget is added to savings
            actualincome = 0
            if agent.emp > 0 # employed

                if agent.shorttime
                    shorttimecount[agent.type] += 1
                    actualincome = (1-tau)*(shorttimewage[agent.type] + divperhh)
                    agent.income = (1-rhoinc)*agent.income +  rhoinc*(1-tau)*(shorttimewage[agent.type] + divperhh) # update income expectations
                else
                    empcount[agent.type] += 1
                    actualincome = (1-tau)*(wage[agent.type] + divperhh)
                    agent.income = (1-rhoinc)*agent.income +  rhoinc*(1-tau)*(wage[agent.type] + divperhh) # update income expectations

                end
            elseif agent.age==1 # unemployed young
                unempcount[agent.type] += 1
                agent.income = (1-rhoinc)*agent.income +  rhoinc*(1-tau)*(unempbenefit[agent.type] + divperhh)
                actualincome = (1-tau)*(unempbenefit[agent.type] + divperhh)
            else # old agent
                oldcount += 1
                agent.income = (1-rhoinc)*agent.income +  rhoinc*(1-tau)*(pension +  divperhh)
                actualincome = (1-tau)*(pension + divperhh)
            end

            totcons = max(0,agent.income + kap*(agent.saving - phi*agent.income))
            agent.consbud = fraccons*totcons

            if essentialsec > 0
                if agent.consbud[essentialsec] < (1-essentialadj) * agent.prevconsbud[essentialsec]
                    if totcons < (1-essentialadj) * agent.prevconsbud[essentialsec]
                        for i = 1:size(agent.consbud, 1)
                            agent.consbud[i] = 0
                        end
                        agent.consbud[essentialsec] = totcons
                    else
                        remainingcons = totcons - (1-essentialadj) * agent.prevconsbud[essentialsec]
                        tempfraccons = deepcopy(fraccons)
                        tempfraccons[essentialsec] = 0
                        sumfrac = sum(tempfraccons)
                        for i = 1:size(tempfraccons, 1)
                            tempfraccons[i] = tempfraccons[i] / sumfrac
                        end
                        agent.consbud = tempfraccons*remainingcons
                        agent.consbud[essentialsec] = (1-essentialadj) * agent.prevconsbud[essentialsec]
                    end
                end
            end

            agent.prevconsbud = deepcopy(agent.consbud)
            agent.saving += actualincome - totcons
            agent.shopday = rand(0:6,nsec) # determine shopping days for three sectors
            agent.shoprepeat = [true, true, true] # consumer repeats shopping once if rationed
            # calculate total savings
            totalsav += agent.saving
        end # end daycounter = 0

        for tt = 1:nsec
            if agent.shopday[tt] == daycounter && rand() < pshop[agent.age][tt] # agent goes shopping
                numshoph = min(size(actshoplist[tt,postemp[agent.id][1],postemp[agent.id][2]])[1],numshops[tt])
                shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]][agent.id] = agent # if agent shops in region where she currently is
                if numshoph > 0 # only if there are potential suppliers
                    storelist = shuffle(actshoplist[tt,postemp[agent.id][1],postemp[agent.id][2]])[1:numshoph] # list of supplier agent observes
                    pricelist = Float64[]
                    for storeid in storelist
                        store = getagent(nhh + storeid)
                        push!(pricelist, exp( - gac*log((wage[store.type-(nsec+1)] + store.fixedcosts / (length(store.worker)+10^(-5)))*(1+store.markup)/ (store.product*(1 - buff[store.type-(nsec+1)]*de[store.type-(nsec+1)]) ))))
                    end
                    store = getagent(nhh + storelist[conselect(pricelist)]) # selected supplier
                    price = (wage[store.type-(nsec+1)] + store.fixedcosts / (length(store.worker)+10^(-5)))*(1+store.markup)/ (store.product*(1 - buff[store.type-(nsec+1)]*de[store.type-(nsec+1)]))
                    quant = min(agent.consbud[tt] / price, store.stock) # minimum of demand and stock
                    agent.consbud[tt] -= quant*price # update agent's consumer budget
                    store.stock -= quant # update stock of supplier
                    if store.stock < 0.0000001
                        setdiff!(actshoplist[store.type-(nsec+1),store.pos[1],store.pos[2]],(store.id-nhh)) # if stock is empty make store inactive
                    end
                    consumption[tt,postemp[agent.id][1],postemp[agent.id][2]] += quant # update total consumption
                    weeklyconsumption[tt,postemp[agent.id][1],postemp[agent.id][2]] += quant
                    store.rev += quant*price # update firm revenues
                    store.demand += quant # update demand
                end
                if agent.consbud[tt] > 0.000001 && agent.shoprepeat[tt]
                    agent.shopday[tt] += 1 # try again next day if rationed
                    agent.shoprepeat[tt] = false # only one repetition possible
                end
            end
        end
    end # end HH loop


    totalaccounts = pubacc
    for i in firms
        totalaccounts += getagent(nhh+i).saving
    end
    for i in union(hh[1], hh[2])
        totalaccounts += getagent(i).saving
    end
    # calculate unemployment
    unemp = 1 - (sum(empcount)+sum(shorttimecount))/size(hh[1])[1]

    #update total consumption
    push!(regcons, consumption)


    # start counting contatcs
    contact_count = 0
    contact_work = 0
    contact_social = 0
    contact_shop = 0
    contact_num = 0
    nosuscep = 0 # count susceptible


### infection loop from perspective of infected
    if virus
        for ii in union(hh[1],hh[2])
            agent = getagent(ii)
            if (agent.cor == 2) || (agent.cor == 4)
                global curinfcount[agent.age] += 1
                global curinfregcount[agent.age,agent.pos[1], agent.pos[2]] += 1
            end
            # possible infection
            if ((agent.cor==2)|| (agent.cor == 4))  && (agent.cortime < trec - corlatent) && (agent.cortime > trec - corlatent- corinf)
                contact_num += 1
                # first infection at the workplace
                if agent.emp > 0 && !agent.shorttime
                    if !agent.homeoffice || !genhomeoffice || rand() > phomeoffice # no home-office for agent
                        employer = getagent(nhh+agent.emp)
                        idlist = employer.worker
                        nummeet = rand(0:workmeet[employer.type-(nsec+1)])
                        for i in shuffle(collect(keys(idlist)))[1:min(nummeet,length(idlist))]
                            partner = getagent(i)
                            contact_work = contact_work + 1 # add contatcs
                            if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) && partner.cor == 1 && !(partner.homeoffice && genhomeoffice && rand() < phomeoffice) && !partner.shorttime
                                partner.cor=agent.cor
                                partner.cortime = trec
                                agent.infect +=1
                            end
                        end
                    end
                end

                # second infection through consumption
                for tt=1:nsec
                    if length(shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]]) > 2
                        if sum(collect(keys(shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]])) .== agent.id) > 0 # agent shopped in sector tt at that day
                            nummeet = rand(0:shopmeet[tt])
                            shopmeeth = Int(ceil(nummeet * length(shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]]) * 7 / (length(lochh[1,postemp[agent.id][1],postemp[agent.id][2]]) + length(lochh[2,postemp[agent.id][1],postemp[agent.id][2]])))) # number of contacts when shopping, equal to nummeet if 1/7 of local pop is shopping
                            shopcontact = rand(collect(keys(delete!(shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]],agent.id))),shopmeeth) #random selection from list of shoppers in same region
                            for i in shopcontact
                                partner = getagent(i)
                                contact_shop = contact_shop + 1 # add contacts
                                if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) &&  (partner.cor ==1)
                                    partner.cor=agent.cor
                                    partner.cortime = trec
                                    agent.infect +=1
                                end
                            end
                            shoppers[tt,postemp[agent.id][1],postemp[agent.id][2]][agent.id] = agent
                        end
                    end
                end

                # third infection through other social contacts
                if agent.age ==1 # young agent
                        # meet young
                        helplist = collect(keys(delete!(lochhytemp[postemp[agent.id][1],postemp[agent.id][2]],agent.id))) # list of potential young contacts in the region
                        if socialmaxyy >= 1
                            numcontact = rand(0:socialmaxyy) # number of contacts
                        else
                            if rand() < mean([0,socialmaxyy])
                                numcontact = 1
                            else
                                numcontact = 0
                            end
                        end
                        if numcontact > 0
                            helpcontact = shuffle(helplist)[1:min(numcontact,size(helplist)[1])] #list of contacts
                            for i in helpcontact
                                partner = getagent(i)
                                contact_social = contact_social + 1 # add contacts
                                if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) &&  (partner.cor ==1)
                                    partner.cor=agent.cor
                                    partner.cortime = trec
                                    agent.infect +=1
                                end
                            end
                        end
                        lochhytemp[postemp[agent.id][1],postemp[agent.id][2]][agent.id] = agent

                        #meet old
                        helplist = collect(keys(lochh[2,postemp[agent.id][1],postemp[agent.id][2]])) # list of potential old in the region
                        if socialmaxyo >= 1
                            numcontact = rand(0:socialmaxyo) # number of contacts
                        else
                            if rand() < mean([0,socialmaxyo])
                                numcontact = 1
                            else
                                numcontact = 0
                            end
                        end
                        if numcontact > 0
                            helpcontact = shuffle(helplist)[1:min(numcontact,size(helplist)[1])] #list of contacts
                            for i in helpcontact
                                partner = getagent(i)
                                contact_social = contact_social + 1 # add contacts
                                if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) &&  (partner.cor ==1)
                                    partner.cor=agent.cor
                                    partner.cortime = trec
                                    agent.infect +=1
                                end
                            end
                        end
                else # old agent
                    # meet young
                    helplist = collect(keys(lochhytemp[agent.pos[1],agent.pos[2]])) # list of potential young contacts in the region
                    if socialmaxoy >= 1
                        numcontact = rand(0:socialmaxoy) # number of contacts
                    else
                        if rand() < mean([0,socialmaxoy])
                            numcontact = 1
                        else
                            numcontact = 0
                        end
                    end
                    if numcontact > 0
                        helpcontact = shuffle(helplist)[1:min(numcontact,size(helplist)[1])] #list of contacts
                        for i in helpcontact
                            partner = getagent(i)
                            contact_social = contact_social + 1 # add contacts
                            if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) &&  (partner.cor ==1)
                                partner.cor=agent.cor
                                partner.cortime = trec
                                agent.infect +=1
                            end
                        end
                    end
                    #meet old
                    helplist = collect(keys(delete!(lochh[2,agent.pos[1],agent.pos[2]],agent.id))) # list of potential old in the region
                    if socialmaxoo >= 1
                        numcontact = rand(0:socialmaxoo) # number of contacts
                    else
                        if rand() < mean([0,socialmaxoo])
                            numcontact = 1
                        else
                            numcontact = 0
                        end
                    end
                    if numcontact > 0
                        helpcontact = shuffle(helplist)[1:min(numcontact,size(helplist)[1])] #list of contacts
                        for i in helpcontact
                            partner = getagent(i)
                            contact_social = contact_social + 1 # add contacts
                            if !partner.vaccinated && (rand() < pinf[Int(agent.cor/2)]) &&  (partner.cor ==1)
                                partner.cor=agent.cor
                                partner.cortime = trec
                                agent.infect +=1
                            end
                        end
                    end
                    lochh[2,agent.pos[1],agent.pos[2]][agent.id] = agent
                end
            end # if cor = 1

        end # summing over all young hh

        # collect contact data
        contact_count = contact_work + contact_social + contact_shop
        push!(contact_count_traj,contact_count/(contact_num + 10^(-5)))
        push!(contact_work_traj,contact_work/(contact_num + 10^(-5)))
        push!(contact_social_traj,contact_social/(contact_num + 10^(-5)))
        push!(contact_shop_traj,contact_shop/(contact_num + 10^(-5)))

    end # virus from infected perspective



    if daycounter == 0
        daycounter = 7
    end
    # reduce daycounter
    daycounter -=1
    return
end
