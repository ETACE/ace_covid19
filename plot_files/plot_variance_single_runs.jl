using Statistics,Serialization,StatsPlots

# parameter values
paras = ["beta_l5","alpha_o050","beta_l5_alpha_l025", "baseline_GER", "beta_l5_alpha_l025_alpha_o025"]

filename_prefix = "../figures/"

mkpath(filename_prefix)

include("../data/baseline_GER/covid_par_ini.jl")
datapoint = fld(T,datat)

for (i,p) in enumerate(paras)
    local path_to_data = string("../data/", p , "/")

    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))

    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    gdpstd = std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    gdpall = hcat((results -> results[:gdppercaptraj]).(worker_results)...)
    local nn = size(gdpmean)[1]
    pl1a = plot(datat*collect(2:nn),[gdpall[2:nn,1],gdpall[2:nn,2],gdpall[2:nn,3],gdpall[2:nn,4],gdpall[2:nn,5],gdpall[2:nn,6]], linewidth = [2 2 2 2 2 2], linecolor = [:red :green :black :blue :cyan :grey],ylims = (32,48), xlabel = "Days", ylabel = "GDP", label = false)
    savefig(pl1a,"$(filename_prefix)gdp_dynamics_single_$(p).pdf")

    local hcapfrac = zeros(datapoint+1)
    for th = 1:datapoint+1
        hcapfrac[th] = hcap / (nhh * icufrac)
    end
    infmean = mean(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
    infstd = std(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
    infall = cat((results -> results[:inftraj]).(worker_results)...,dims=3)
    pl6a = plot(datat*collect(2:nn),[infall[2:nn,3,1],infall[2:nn,3,2],infall[2:nn,3,3],infall[2:nn,3,4],infall[2:nn,3,5],infall[2:nn,3,6]], linewidth = [2 2 2 2 2 2], linecolor = [:red :green :black :blue :cyan :grey], ylabel = "Inf [%]", xlabel = "Days", label = false)
    savefig(pl6a,"$(filename_prefix)infection_dynamics_single_$(p).pdf")

end
