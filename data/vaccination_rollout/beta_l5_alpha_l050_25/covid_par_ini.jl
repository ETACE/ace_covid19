# agent-based economy under covid infection
using Agents,Random,Plots, Statistics

snapshot = false # set true if snapshot should be made at end of run
loadsnapshot = true # set true if initialization comes from file "snapshot.dat" else random initialization
snapname = "snapshot100kr1.dat"

#snapshot = true # set true if snapshot should be made at end of run
#loadsnapshot = false # set true if initialization comes from file "snapshot.dat" else random initialization

#Random.seed!(20042020)
#filename_prefix = ""

#parameters
k1 = 1 # dimension1 of space
k2 = 1 # dimension2 of space
nhh = 100000 # number of hh

T = 744  # time periods
virustime =14 # time where infection starts

vacctime = 338
vaccspeed = 337 # vaccinations per day
vaccefficiency = 0.95
vaccwillingness_old = 0.75
vaccwillingness_young = 0.75

enablebankruptciestime = 1000 #1000
endfcadj = 1250
resetfirmsavingstime = 500

datat = 7 # interval of data collection
bankruptcypossible = false #true
if loadsnapshot   #adjust fixed costs in both directions only if no snapshot is loaded
    updatefixedcosts = false
else
    updatefixedcosts = true
end

#policy data
alpha_lockdown = 0.5
alpha_open = 0.0
alpha_open = 0.0
tpol = virustime + 21
policies = Dict{Int64,String}()
policies[tpol] = "policy_lockdown_2.jl"
#policies[tpol + 21] = "policy_open_2.jl
policies[vacctime+56] = "policy_allout.jl"

detfrac = 0.15 # detection frequency
adaptivepolicythresholdoff = 5 * nhh / (detfrac*100000) # Threshold infected/week
adaptivepolicythresholdon = 5 * nhh / (detfrac*100000) # Threshold infected/week
poladjfrac = 0.6 # factor by which gap in policy parameter is closeed during phase in / phase out every week

tadaptivepolicystart = tpol + 21 # Enable adaptive policy response
tadaptivepolicyend = vacctime+56 - 7 # Enable adaptive policy response
adaptivepolicygood = "policy_open_2.jl" # policy acitvated if number of infected above threshold
adaptivepolicybad = "policy_lockdown_2.jl" #  policy activated if number of infected below threshold

fracy = .75 # fraction of young households
avempl = 15 # average number of employees per firm
nf =Int(floor(fracy*nhh/avempl)) # number of firms
nsec = 3 # number of sectors: man / ser / food
pubfrac = 0.12 # employment share in public sector
fraccons = [0.21, 0.5, 0.29] # fraction consumption man / ser / food
essentialsec = 3
essentialadj = 0.01
baseprod = [97, 62, 48, 62] # average productivities in 1000€ man / ser / food /pub
#fracemp = [0.14, 0.49, 0.37] # initial fraction employment man / ser / food
fracemp = (fraccons ./ baseprod[1:3]) / sum(fraccons ./ baseprod[1:3])

#phome = 0.9 # prob of being in own region
ptravel = 0.1 # prob of being in other region, only for young
socialmaxyy = 5 # max no. people met outside firm young_young
socialmaxoo = 2 # max no. people met outside firm old_old
socialmaxoy = 4 # max no. people met outside firm old_old
socialmaxyo = 2 # max no. people met outside firm young_old
workmeet = [8,8,8,8] # max number of people met at work: man / ser / food /public
shopmeet = [10,28,10] # max number of people met at each shopping instant  man / ser / food
homeofficefrac = [.45,.3,.0 ,0.75] # data taken from Fadinger/Schymik: man / ser / food /public
phomeoffice = 0

pinf = 0.0725*[1,1.5] # infection prob at meeting before/after mutation
muttime =180 # time of mutation
mutnum = 5 # number of mutating
trec = 21 # recovery time
corlatent = 5 # latency time
corinf = 5 # infectious period
hcap = Int(0.5*round(0.0003*(nhh))) # no of intensive beds based on 30 per 100.000
mortl = detfrac*[0.0066/trec, 0.16/trec] # mortality young, old, normal cap, data from Germany
morth = detfrac*[0.018/trec, 0.5/trec] # mortality young, old, overcap, data from Italy
icufrac = detfrac*0.085 # fraction of infected needing intensive care unit

#firm markup
etmin = [0.18, 0.18, 0.18, 0] #profit markups after fixed costs are introduced
etmax = [0.25, 0.25, 0.25, 0] #profit markups after fixed costs are introduced

#et = 0.15
#inventory buffer for firms  # man / ser / food

buff = .25*[0.1 / 7., 0.03 / 7, 0.05 / 7, 0] # changes
#buff = .005*[0.1 / 7., 0.05 / 7, 0.05 / 7, 0]


#buff = [0.2 / 7., 0.05 / 7, 0.1 / 7, 0]

# weekly depreciation of inventory
de = [0.01, 1, 0.5, 0] # man / service / food
rhodem = 0.5 # demand expectation smoothing parameter
zerostockboost = 8 # factor to boost expansion if stock is zero
divrate = 0.7 # dividend rate if savings are not too high
savtar = [1,.5,.5,0] # target of firm savings relative to av. revenues during last 4 weeks


#fcvcratio = 0.1*[0.47, 0.3, 0.3, 0.3] #fixed cost to variable cost ratio
fcvcratio = 0.16*[0.47, 0.3, 0.3, 0.3]

#productivity distribution
#prodlb = [.9, 1. / 1.1, .9, 1.]    # man / ser / food
#produb = [1.1, 1.1, 1.1, 1.]    # man / ser / food
prodlb = [.9, 1.05 , .9, 1.]    # man / ser / food
produb = [1.1, 0.95, 1.1, 1.]    # man / ser / food


wage = baseprod .* (1 .- buff .* de) ./ ((1 .+ fcvcratio) .* (1 .+ etmin)) # weekly wage
pension = 0.5 * mean(wage)
unempbenefit = 0.6 .* wage[1:nsec]
shorttimewage = 0.7 .* wage[1:nsec]

#consumption budget rule parameters
kap = 0.1 / 4. #marginal  prop to consume from exzess saving
phi = 4*8.  # target savings / weekly income ratio (16.67 per month in Eurace)
rhoinc = 0.4 # income expectation smoothing parameter
pshop = [[1,1,1],[1,1,1]] # prob of weekly shopping in man/ser/food
numshops = [4,4,4] # numer of local suppliers consumer checks each shopping: man/ser/food
gac = 16 # intensity of choice parameters for consumers

# government
tauadj = 0.05 # speed of adjusment of tax rate
debtfrac = 1. / (52. * 10.) # fraction of public debt erased'/added in one week

#calculate agent numbers
nhhy = Int(floor(fracy*nhh)) # number of young hh
nhho = nhh - nhhy # number of old hh
nfsec = [0 for tt=1:nsec+1]
for tt=1:nsec
    nfsec[tt] = Int(floor((1-pubfrac)*fracemp[tt]*nf)) # number  of firms in sector tt
end
nfsec[nsec+1] = nf - sum(nfsec[1:nsec]) # number of public sector offices

#initialization
consumption = zeros(nsec, k1, k2)
inifrac = 0.0001 # fraction of pop infected when virus starts, Germany 9.3. 1/10000 taken into account undetected
ininumy = Int(ceil(fracy*inifrac*nhh))
ininumo = Int(ceil((1-fracy)*inifrac*nhh))
iniinf = [[[ininumy,ininumo]]]
trigger = true # initial infection can start
unemp = 0.1 # initial unemployment
incomehh = (1-unemp)*wage
savinghh = phi*incomehh
incomehho = pension
savinghho = phi*incomehho
savingf  = 100
consbud = [0.,0.,0.] #man / service / food
prevconsbud = [0.,0.,0.] #man / service / food
shoprepini = [true, true, true] #  possible repetition of shopping trip
daycounter = 6
tau = (fracy*unemp*mean(unempbenefit) + (1-fracy)*pension) / ((1-unemp)*fracy*mean(wage .* (1 .+ etmin))) # initial tax rate
pubacc = 0. # public account
pastrevini = 10000*[1,1,1,1] # intitializations of past revenue
virus = false # initially there is no virus
genhomeoffice = false # initially no home-office
bailoutprogram = false # initially no bailouts
end_bailout_after_weeks = 78
shorttimeprogram = false # initially no short term program
shorttimeperiod = 78
shorttimeprob = 0.9
demandexpini = [1700,1000,600,0]

# list for total consumption i regions
regcons = [] # saves regional consumption every day

cas = [[0,0] for i=1:k1, j=1:k2] # casualties every day

# save default values
pinf_o = pinf
socialmaxyy_o = socialmaxyy
socialmaxoy_o = socialmaxoy
socialmaxoo_o = socialmaxoo
socialmaxyyh = socialmaxyy
socialmaxoyh = socialmaxoy
socialmaxooh = socialmaxoo
ptravel_o = ptravel
pshop_o = pshop
tauadj_o = tauadj
phomeoffice_o = phomeoffice
workmeet_o = workmeet
shopmeet_o = shopmeet
workmeeth = workmeet
shopmeeth = shopmeet
#set initial targets equal to current values
pinft = pinf
socialmaxyyt = socialmaxyy
socialmaxoyt = socialmaxoy
socialmaxoot = socialmaxoo
pshopt = pshop
phomeofficet = phomeoffice
workmeett = workmeet
shopmeett = shopmeet
socialmaxyo_o = socialmaxyo
socialmaxyoh = socialmaxyo
socialmaxyot = socialmaxyo
