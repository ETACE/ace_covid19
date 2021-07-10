# agent-based economy under covid infection

# Check if covid_par_ini defines symmetric threshold (legacy code)
if @isdefined(adaptivepolicythreshold) && !@isdefined(adaptivepolicythresholdon) && !@isdefined(adaptivepolicythresholdoff)
    adaptivepolicythresholdon = adaptivepolicythreshold
    adaptivepolicythresholdoff = adaptivepolicythreshold
end

# Check if covid_par_ini does not define mutation parameters (legacy code)
if !@isdefined(muttime)
    muttime = -1
    mutnum = 0
    pinf = pinf * [1.0, 1.0]
end
if loadsnapshot
    covidmodel, lochh, locf, unemplist, shorttimelist, empcount, unempcount, shorttimecount, oldcount, unemp, firms, hh, tau, divperhh, weeklyconsumption = restore_snapshot("$snapname")
else
    include("covid_rand_ini.jl")
end

datapoint = fld(T,datat)
actshoplist = deepcopy(locf) # initialize list of active stores

castraj = zeros(datapoint+1,k1,k2,2)
totcastraj = zeros(datapoint+1,3)
unempltraj = zeros(datapoint+1)
shorttimetraj = zeros(datapoint+1)
unempsectraj = zeros(datapoint+1,nsec)
emplwopubtraj = zeros(datapoint+1,nsec) # Employment without public sector
shorttimesectraj = zeros(datapoint+1,nsec)
pubacctraj = zeros(datapoint+1)
tautraj = zeros(datapoint+1)
totfirmtraj = zeros(datapoint+1)
constraj = zeros(datapoint+1,nsec,k1,k2) # total consuption during the data collection interval
conspercaptraj = zeros(datapoint+1)
gdppercaptraj = zeros(datapoint+1)
gdplosstraj = zeros(datapoint+1)
totgdploss = 0
inactivefirmstraj = zeros(datapoint+1)
bailouttraj = zeros(datapoint+1)
totalaccountstraj = zeros(datapoint+1)
totalsavtraj = zeros(datapoint+1)
R0count = Int[]  # list of number infected by infected agents
R0counttraj = zeros(datapoint+1)
f_av_savings_reg = zeros(datapoint+1,nsec,k1,k2)
f_av_workers_reg = zeros(datapoint+1,nsec+1,k1,k2)
f_av_stock_reg = zeros(datapoint+1,nsec,k1,k2)
f_av_demandexp_reg = zeros(datapoint+1,nsec,k1,k2)
f_av_savings = zeros(datapoint+1,nsec)
f_var_savings = zeros(datapoint+1,nsec)
f_av_workers = zeros(datapoint+1,nsec+1)
f_var_workers = zeros(datapoint+1,nsec+1)
f_av_stock = zeros(datapoint+1,nsec)
f_av_demandexp = zeros(datapoint+1,nsec)
f_var_demandexp = zeros(datapoint+1,nsec)
bankrupttraj = zeros(datapoint+1,nsec)
inftraj = zeros(datapoint+1,3)
inftrajmut = zeros(datapoint+1)
totinftraj = []
RKIR0traj = zeros(datat*datapoint+1)
curinftraj = []
curinfregtraj = []
contact_count_traj = [] # list of number of contatcs
contact_work_traj = [] # list of number of contatcs in work
contact_social_traj = [] # list of number of social contatcs
contact_shop_traj = [] # list of number of contatcs shopping
bankruptcount = zeros(nsec)

#initial unemployment rate
unempltraj[1] = unemp
unempsectraj[1,1] = unemp
unempsectraj[1,2] = unemp
unempsectraj[1,3] = unemp
shorttimetraj[1] = 0
shorttimesectraj[1,1] = 0
shorttimesectraj[1,2] = 0
shorttimesectraj[1,3] = 0
#initial public account
pubacctraj[1] = 0
#initial number of firms
totfirmtraj[1] = size(firms)[1]
# initial tax
tautraj[1] = tau
#initially no infected
push!(totinftraj, 0)
# initial no contact
push!(contact_count_traj, 0)
push!(contact_work_traj, 0)
push!(contact_social_traj, 0)
push!(contact_shop_traj, 0)

# robert koch R0
RKIR0traj[1] =0
inftraj[1,1] = 0
inftraj[1,2] = 0
inftraj[1,3] = 0
ttt=0

currentadaptivepolicy = "NONE"
polswitchcount = 0
badpoltime = 0

#iteration
#@showprogress
for t = 1:datapoint
    global datahhy = zeros(nhhy, 5) #pos,cor, emp, saving, consbud
    global datahho = zeros(nhho, 5) #pos,cor, emp, saving, consbud
    global dataf = zeros(nf, 5) #pos,saving,product,stock, demand

    if t*datat+1 > virustime && trigger # activated if t first crosses virustime

        for i=1:k1
            for j=1:k2
#                infected = rand(merge(lochh[1,i,j],lochh[2,i,j]),iniinf[i][j]) # select randomly infected
#                for (id, agent) in infected
#                    agent.cor = 2 # agent is infected
#                    agent.cortime = trec
#                end
                infected = rand(lochh[1,i,j],iniinf[i][j][1]) # select randomly infected
                for (id, agent) in infected
                    agent.cor = 2 # agent is infected
                    agent.cortime = trec
                end
                infected = rand(lochh[2,i,j],iniinf[i][j][2]) # select randomly infected
                for (id, agent) in infected
                    agent.cor = 2 # agent is infected
                    agent.cortime = trec
                end
            end
        end

        global trigger = false
        global virus = true  # activate virus spreading in model_step
        global totgdploss = 0
    end

    # adjust policy variables
    global pinf += poladjfrac*(pinft .- pinf)
    global socialmaxyyh += poladjfrac*(socialmaxyyt - socialmaxyyh)
    if socialmaxyyh >= 1
        global socialmaxyy = Int(ceil(socialmaxyyh))
    else
        global socialmaxyy = socialmaxyyh
    end
    global socialmaxoyh += poladjfrac*(socialmaxoyt - socialmaxoyh)
    if socialmaxoyh >= 1
        global socialmaxoy = Int(ceil(socialmaxoyh))
    else
        global socialmaxoy = socialmaxoyh
    end
    global socialmaxooh += poladjfrac*(socialmaxoot - socialmaxooh)
    if socialmaxooh >= 1
        global socialmaxoo = Int(ceil(socialmaxooh))
    else
        global socialmaxoo = socialmaxooh
    end
    global pshop += poladjfrac .* (pshopt .- pshop)
    global phomeoffice += poladjfrac*(phomeofficet - phomeoffice)

    if t*datat <= resetfirmsavingstime && (t+1)*datat > resetfirmsavingstime && !loadsnapshot  # reset firm savings after initial burn-in
        for id in firms
            getagent(nhh+id).saving = 500
        end
    end

    if t*datat < enablebankruptciestime && !loadsnapshot
        global bankruptcypossible = false
    else
        global bankruptcypossible = true
    end

    if t*datat <= endfcadj && (t+1)*datat > endfcadj && !loadsnapshot # update firm fixed costs after initial burn-in
        global updatefixedcosts  = false
    end

    for (tpol, policyfile) in policies
        if t*datat <= tpol && (t+1)*datat > tpol
            include("$policyfile")
        end
    end

    # mutation of virus is introduced at muttime
    if t*datat <= muttime && (t+1)*datat > muttime
        permlist = shuffle(union(hh[1],hh[2]))
        global mutcount = 0
        for ii in permlist
            if mutcount < mutnum
                agent = getagent(ii)
                if (agent.cor ==2) && (agent.cortime > trec - corlatent- corinf)
                    agent.cor = 4
                    global mutcount+=1
                end
            end
        end
    end

    #step!(covidmodel, dummystep, model_step!, datat)
    noinfbow = totinftraj[size(totinftraj, 1)]

    global end_bailout_after_weeks
    if t > end_bailout_after_weeks
        global bailoutprogram = false
        global shorttimeprogram = false
    end

    for j = 1:datat
        global ttt +=1
        step!(covidmodel, dummystep, model_step!, 1)
        if ttt > 9 && totinftraj[ttt-8] > 0
            global RKIR0traj[ttt] = (totinftraj[ttt]-totinftraj[ttt-4]) / (totinftraj[ttt-4]-totinftraj[ttt-8])
        end
        push!(curinfregtraj,curinfregcount)
        push!(curinftraj,curinfcount)
    end

    noinfeow = totinftraj[size(totinftraj, 1)]

    newinf = noinfeow - noinfbow

    # Adaptive policy
    global currentadaptivepolicy
    if t*datat >= tadaptivepolicystart && (t+1)*datat < tadaptivepolicyend
        if newinf >= adaptivepolicythresholdon && (currentadaptivepolicy == "GOOD" || currentadaptivepolicy == "NONE")
            include("$adaptivepolicybad")
            currentadaptivepolicy = "BAD"
            global polswitchcount += 1
        elseif newinf < adaptivepolicythresholdoff && currentadaptivepolicy == "BAD"
            include("$adaptivepolicygood")
            currentadaptivepolicy = "GOOD"
        end
    end
    if currentadaptivepolicy == "BAD"
        global badpoltime += datat
    end

    if t == 1
        global gdppercapref = gdp / nhh #size(union(hh[1],hh[2]))[1]
        global firmref = zeros(nsec)
        for tt=1:nsec
             global firmref[tt] = 0
             for i = 1:k1
                 for j=1:k2
                   global firmref[tt] += size(locf[tt,i,j])[1]
                 end
              end
          end
      end

    for id in hh[1]
        current_agent = getagent(id)
        datahhy[id,1] = ((current_agent.pos[1]-1)*k2+current_agent.pos[2])
        datahhy[id,2] = current_agent.cor
        datahhy[id,3] = current_agent.emp
        datahhy[id,4] = current_agent.saving
        datahhy[id,5] = sum(current_agent.consbud)
    end
    unempltraj[t+1] = unemp
    for tt = 1:nsec
        unempsectraj[t+1,tt] = unempcount[tt] / (size(hh[1])[1] * fracemp[tt])
    end

    for tt = 1:nsec
        shorttimetraj[t+1] += shorttimecount[tt]
        emplwopubtraj[t+1] += (1-unempsectraj[t+1,tt])*size(hh[1])[1] * fracemp[tt]
        shorttimesectraj[t+1,tt] = shorttimecount[tt] / (size(hh[1])[1] * fracemp[tt])
    end

    shorttimetraj[t+1] = shorttimetraj[t+1] / emplwopubtraj[t+1]

    pubacctraj[t+1] = pubacc / size(union(hh[1],hh[2]))[1]
    tautraj[t+1] = tau
    totfirmtraj[t+1] = size(firms)[1]
    R0counttraj[t+1] = mean(R0count)

    for id in hh[2]
        current_agent = getagent(id)
        datahho[id-nhhy,1] = ((current_agent.pos[1]-1)*k2+current_agent.pos[2])
        datahho[id-nhhy,2] = current_agent.cor
        datahho[id-nhhy,3] = current_agent.emp
        datahho[id-nhhy,4] = current_agent.saving
        datahho[id-nhhy,5] = sum(current_agent.consbud)
    end
    for id in firms
        current_agent = getagent(nhh+id)
        dataf[id,1] = ((current_agent.pos[1]-1)*k2+current_agent.pos[2])
        dataf[id,2] = current_agent.saving
        dataf[id,3] = length(current_agent.worker)
        dataf[id,4] = current_agent.stock
        dataf[id,5] = current_agent.demandexp
    end
    inftraj[t+1,1] =(sum(datahhy[:,2] .== 2) .+ sum(datahhy[:,2] .== 4))/ nhhy
    inftraj[t+1,2] =(sum(datahho[:,2] .== 2) .+ sum(datahhy[:,2] .== 4)) / nhho
    inftraj[t+1,3] = (sum(datahhy[:,2] .== 2) .+ sum(datahho[:,2] .== 2) .+ sum(datahhy[:,2] .== 4) .+ sum(datahho[:,2] .== 4)) / nhh
    inftrajmut[t+1] = (sum(datahhy[:,2] .== 4) .+ sum(datahho[:,2] .== 4)) / nhh

    for tt = 1:nsec
             tempsavreg = [[] for i = 1:k1, j = 1:k2]
             tempworkreg = [[] for i = 1:k1, j = 1:k2]
             tempstockreg = [[] for i = 1:k1, j = 1:k2]
             tempdemandexpreg = [[] for i = 1:k1, j = 1:k2]
             tempsav = []
             tempwork = []
             tempstock = []
             tempdemandexp = []
             for id in firms
                 if getagent(nhh+id).type-(nsec+1) == tt
                 push!(tempsavreg[Int(dataf[id,1])],dataf[id,2])
                 push!(tempworkreg[Int(dataf[id,1])],dataf[id,3])
                 push!(tempstockreg[Int(dataf[id,1])],dataf[id,4])
                 push!(tempdemandexpreg[Int(dataf[id,1])],dataf[id,5])
                 push!(tempsav,dataf[id,2])
                 push!(tempwork,dataf[id,3])
                 push!(tempstock,dataf[id,4])
                 push!(tempdemandexp,dataf[id,5])
                 end
             end
             for i=1:k1
                 for j=1:k2
                     ii = (i-1)*k2+j
                     f_av_savings_reg[t+1,tt,i,j] = mean(tempsavreg[ii])
                     f_av_workers_reg[t+1,tt,i,j] = mean(tempworkreg[ii])
                     f_av_stock_reg[t+1,tt,i,j] = mean(tempstockreg[ii])
                     f_av_demandexp_reg[t+1,tt,i,j] = mean(tempdemandexpreg[ii])
                 end
             end
             f_av_savings[t+1,tt] = mean(tempsav)
             f_var_savings[t+1,tt] = var(tempsav)
             f_av_workers[t+1,tt] = mean(tempwork)
             f_var_workers[t+1,tt] = var(tempwork)
             f_av_stock[t+1,tt] = mean(tempstock)
             f_av_demandexp[t+1,tt] = mean(tempdemandexp)
             f_var_demandexp[t+1,tt] = var(tempdemandexp)
         end
         tempworkreg = [[] for i = 1:k1, j = 1:k2]
         tempwork = []
         for id in firms
             if getagent(nhh+id).type-(nsec+1) == nsec+1
                 push!(tempworkreg[Int(dataf[id,1])],dataf[id,3])
                 push!(tempwork,dataf[id,3])
             end
         end
         for i=1:k1
             for j=1:k2
                 ii = (i-1)*k2+j
                 f_av_workers_reg[t,nsec+1,i,j] = mean(tempworkreg[ii])
             end
         end
         f_av_workers[t,nsec+1] = mean(tempwork)
         f_var_workers[t,nsec+1] = var(tempwork)

    conspercaph = 0
    totcastraj[t+1,1] = 0
    totcastraj[t+1,2] = 0
    totcastraj[t+1,3] = 0
    for i=1:k1
        for j=1:k2
            castraj[t+1,i,j,1] =cas[i,j][1]
            castraj[t+1,i,j,2] =cas[i,j][2]
            totcastraj[t+1,1] +=cas[i,j][1] / nhhy
            totcastraj[t+1,2] += cas[i,j][2] / nhho
            totcastraj[t+1,3] += (cas[i,j][1] + cas[i,j][2]) / nhh
            for tt =1:nsec
                sumh = 0
                for jj = 1: datat
                    sumh += regcons[(t-1)*datat+jj][tt,i,j]
                end
                constraj[t+1,tt,i,j] = sumh
                conspercaph += sumh
            end
        end
    end
    conspercaptraj[t+1] = conspercaph / size(union(hh[1],hh[2]))[1]
    gdppercaptraj[t+1] = gdp / nhh #size(union(hh[1],hh[2]))[1]
    gdplosstraj[t+1] =  (gdppercapref - gdp / nhh)/ gdppercapref
    global totgdploss += gdplosstraj[t+1]
    for tt = 1:nsec
        bankrupttraj[t+1,tt] = bankruptcount[tt] / firmref[tt]
    end
    inactivefirmstraj[t+1] = inactivefirms
    bailouttraj[t+1] = sumbailouts
    totalaccountstraj[t+1] = totalaccounts
    totalsavtraj[t+1] = totalsav
end
curinfregtrajy = [curinfregtraj[i][1,:,:] for i=1:size(curinfregtraj)[1]]
curinfregtrajo = [curinfregtraj[i][2,:,:] for i=1:size(curinfregtraj)[1]]
curinftrajy = [curinftraj[i][1] for i=1:size(curinftraj)[1]]
curinftrajo = [curinftraj[i][2] for i=1:size(curinftraj)[1]]
totcas = totcastraj[datapoint+1,3]

totgdploss = totgdploss * 365 / max(1, T - virustime)
RKIR0smtraj = zeros(datat*datapoint+1)
for t= 1:datat*datapoint+1
    if t > 6 && RKIR0traj[t-6] > 0
        global RKIR0smtraj[t] = mean(RKIR0traj[t-6:t])
    end
end
