demand = nhhy * (1-unemp)*(1-tau)* ((prodlb+produb)/2)/nf

space = GridSpace((k1,k2))

covidmodel = ABM(CovidAgent.GenericAgent,space; scheduler = fastest)

#create emtpy list of employees for all firms
workerlist =  Array{Int}[]
for n=1:nf
    push!(workerlist, Int[])
end
#unemployd list
unemplist = [Dict{Int,CovidAgent.GenericAgent}() for tt=1:nsec, i=1:k1, j=1:k2] # only dimension nsec because there are no unemployd public workers
shorttimelist = [Dict{Int,CovidAgent.GenericAgent}() for tt=1:nsec, i=1:k1, j=1:k2]

#generate list of firms in each location
locf = [Int[] for tt = 1:nsec+1, i=1:k1, j=1:k2] # separated by type of firm
locallf = [Int[] for i=1:k1, j=1:k2] # all types

# first setor
for n =1: nfsec[1]
    k1help = 1+fld(mod(n-1,k1*k2),k2)
    k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
    push!(locf[1,k1help,k2help],n)
    push!(locallf[k1help,k2help],n)
end

for tt = 2:nsec
    for n = sum(nfsec[1:tt-1])+1: sum(nfsec[1:tt])
        k1help = 1+fld(mod(n-1,k1*k2),k2)
        k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
        push!(locf[tt,k1help,k2help],n)
        push!(locallf[k1help,k2help],n)
    end
end
for n = sum(nfsec[1:nsec])+1: nf
    k1help = 1+fld(mod(n-1,k1*k2),k2)
    k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
    push!(locf[nsec+1,k1help,k2help],n)
    push!(locallf[k1help,k2help],n)
end



#generate list of hh in each location
lochh = [Dict{Int,CovidAgent.GenericAgent}() for tt = 1:2, i=1:k1, j=1:k2]

#list of households
hh  = [collect(1:nhhy), collect(nhhy+1:nhhy+nhho)]

#list of firms
firms = collect(1:nf)

global empcount = zeros(nsec+1)
global unempcount = zeros(nsec)
global shorttimecount = zeros(nsec)
global oldcount = 0

# add young households
for n =1:nhhy
    k1help = 1+fld(mod(n-1,k1*k2),k2)
    k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
    if rand() < unemp
        emp=0
        tt = conselect(fracemp) # no unemployed for public sector
        unempcount[tt] += 1
    else
        emp = rand(locallf[k1help,k2help])
        push!(workerlist[emp],n)
        if emp <= nfsec[1]
            tt = 1
        end
        for tth=2:nsec+1
            if sum(nfsec[1:tth-1]) < emp && emp <= sum(nfsec[1:tth])
                tt = tth
            end
        end

        empcount[tt] +=1
    end
    if rand() < homeofficefrac[tt] # can this worker do home-office ?
        ho = true
    else
        ho = false
    end
    shopday = rand(0:6,nsec)
    agent = CovidAgent.GenericAgent(n,(k1help,k2help),tt,1,1,false,0,0,emp,false,0,ho,Dict{Int,CovidAgent.GenericAgent}(),Dict{Int,CovidAgent.GenericAgent}(),incomehh[tt],savinghh[tt],consbud,prevconsbud,shopday,shoprepini,0,0,0,0,0,pastrevini, 0,0)

    add_agent_pos!(agent,covidmodel)
    lochh[1,k1help,k2help][n] = agent
    if emp == 0
        unemplist[tt,k1help,k2help][n] = agent
    end
end

# add old households
for n = nhhy+1:nhhy+nhho
    global oldcount += 1
    k1help = 1+fld(mod(n-1,k1*k2),k2)
    k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
    shopday = rand(0:6,nsec)
    agent = CovidAgent.GenericAgent(n,(k1help,k2help),1,2,1,false,0,0,0,false,0,false,Dict{Int,CovidAgent.GenericAgent}(),Dict{Int,CovidAgent.GenericAgent}(),incomehho,savinghho,consbud,prevconsbud,shopday,shoprepini,0,0,0,0,0,pastrevini,0,0)

    add_agent_pos!(agent,covidmodel)
    lochh[2,k1help,k2help][n] = agent
end

# add firms
#first sector
for n = 1: nfsec[1]
    k1help = 1+fld(mod(n-1,k1*k2),k2)
    k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
    product =  (prodlb[1]+ (produb[1]-prodlb[1])*rand())*baseprod[1] # determine productivity
    shopday = [0,0,0]

    worker = Dict{Int,CovidAgent.GenericAgent}()
    for id in workerlist[n]
        worker[id] = covidmodel[id]
    end

    agent = CovidAgent.GenericAgent(nhhy+nhho+n,(k1help,k2help),nsec+2,1,1,false,0,0,0,false,0,false,worker,Dict{Int,CovidAgent.GenericAgent}(),0,savingf,consbud,prevconsbud,shopday,shoprepini,product,0,demand[1],demandexpini[1],0,pastrevini,etmin[1],0)
    add_agent_pos!(agent,covidmodel)
end
#other sectors
for tt = 2:nsec+1
    for n = sum(nfsec[1:tt-1])+1: sum(nfsec[1:tt])
        k1help = 1+fld(mod(n-1,k1*k2),k2)
        k2help = 1+mod(n-1,k1*k2)-(k1help-1)*k2 # distribute evenly on grid
        product =  (prodlb[tt]+ (produb[tt]-prodlb[tt])*rand())*baseprod[tt] # determine productivity
        shopday = [0,0,0]

        worker = Dict{Int,CovidAgent.GenericAgent}()
        for id in workerlist[n]
            worker[id] = covidmodel[id]
        end

        agent = CovidAgent.GenericAgent(nhhy+nhho+n,(k1help,k2help),nsec+1+tt,1,1,false,0,0,0,false,0,false,worker,Dict{Int,CovidAgent.GenericAgent}(),0,savingf,consbud,prevconsbud,shopday,shoprepini,product,0,demand[tt],demandexpini[tt],0,pastrevini, etmin[tt], 0)
        add_agent_pos!(agent,covidmodel)
    end
end

divperhh = 0
weeklyconsumption = zeros(nsec, k1, k2)


covidmodel_copy = copy(covidmodel.agents)
