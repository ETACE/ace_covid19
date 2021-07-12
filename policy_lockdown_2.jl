# targets for phase in / phase out of policies

pinft = 0.375.*pinf_o # infection prob at meeting

socialmaxyyt = 2 # max no. people met outside firm young_young
socialmaxoyt = 1 # max no. people met outside firm old_young
socialmaxoot = 0.5 # max no. people met outside firm old_old
socialmaxyot = 0.5 # max no. people met outside firm old_old


phomeofficet = 1

pshopt = [[1,1,1],[1,1,1]] - alpha_lockdown*[[0.1,0.33,0],[0.1,0.33,0]]
pshop = [[1,1,1],[1,1,1]] - alpha_lockdown*[[0.1,0.33,0],[0.1,0.33,0]]

workmeett = [4,5,8,2] # max number of people met at work: man / ser / food /public
shopmeett = [5,20,10] # max number of people met at each shopping instant  man / ser / food

# direct change in variable through policy
tauadj = 0

genhomeoffice = true

ptravel = 0

bailoutprogram = true # initially no bailouts

shorttimeprogram = true # initially no short term program

# If this is the first (non-adaptive) lockdown, set policy indicator to 'bad' and counter to 1
if polswitchcount == 0
    currentadaptivepolicy = "BAD"
    polswitchvount = 1
end
