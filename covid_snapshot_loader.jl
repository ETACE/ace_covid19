using Agents
using Serialization


function restore_snapshot(filename = "snapshot100kr1.dat")
    space = GridSpace((k1,k2))
    covidmodel = ABM(CovidAgent.GenericAgent,space; scheduler = fastest)
    (agents, lochh, locf, unemplist, shorttimelist, empcount, unempcount, shorttimecount, oldcount, unemp, firms, hh, tau, divperhh, weeklyconsumption) = open(filename,"r") do snapshot_file
        deserialize(snapshot_file)
    end
    for (id, agent) in agents
        add_agent_pos!(agent,covidmodel)
    end
    return covidmodel, lochh, locf, unemplist, shorttimelist, empcount, unempcount, shorttimecount, oldcount, unemp, firms, hh, tau, divperhh, weeklyconsumption
end
