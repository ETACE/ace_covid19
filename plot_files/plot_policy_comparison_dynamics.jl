using Statistics,Serialization,StatsPlots, DataFrames

# parameter values
paras = ["beta_l5","alpha_o050","beta_l5_alpha_l025", "baseline_GER", "beta_l5_alpha_l025_alpha_o025"]

filename_prefix = "../figures/"

# define period of plotting for economic plots
start_week = 3 # cut of first week
end_week = 102
# set periods for covid plots
inf_start_day = 1
inf_end_day = 600 # cut of after period 400
inf_start_week = 3
inf_end_week = 86 # 58*7 = 406 and 42*7 = 294

include("../data/baseline_GER/covid_par_ini.jl") # necessary for some basic parameter values (nhh)

datapoint = fld(T,datat)

# scatterplot
gdploss_means = []
totcas_means = []
pubacc_means = []

# boxplots
number_batches = 20
gdploss_all_means = DataFrame()
totcas_all_means = DataFrame()
pubacc_all_means = DataFrame()
badpoltime_all_means = DataFrame()
polsw_all_means = DataFrame()
totinfmean_all_means = DataFrame()
totinfstd_all_means_plus = DataFrame()
totinfstd_all_means_minus = DataFrame()
infmean_all_means = DataFrame()
infstd_all_means_plus = DataFrame()
infstd_all_means_minus = DataFrame()
totcasmean_all_means = DataFrame()
totcasstd_all_means_plus = DataFrame()
totcasstd_all_means_minus = DataFrame()
gdpmean_all_means = DataFrame()
gdpstd_all_means_plus = DataFrame()
gdpstd_all_means_minus = DataFrame()
unempmean_all_means = DataFrame()
unempstd_all_means_plus = DataFrame()
unempstd_all_means_minus = DataFrame()
pubaccmean_all_means = DataFrame()
pubaccmean_all_means_plus = DataFrame()
pubaccmean_all_means_minus = DataFrame()
totfirmsmean_all_means = DataFrame()

for (i,p) in enumerate(paras)
    local path_to_data = string("../data/", p , "/")
    # store data scatterplot
    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    local pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means,gdploss)
    push!(totcas_means,totcas)
    push!(pubacc_means,pubacc)
    # store data boxplot
    gdploss_all = (results -> results[:togdploss]).(worker_results)
    totcas_all = 100*(results -> results[:totcas]).(worker_results)
    pubacc_all = [pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]]
    gdploss_all_means[Symbol.(paras[i])] = gdploss_all
    totcas_all_means[Symbol.(paras[i])] = totcas_all
    pubacc_all_means[Symbol.(paras[i])] = pubacc_all
    badpoltime_all = (results -> results[:badpoltime]).(worker_results)
    polsw_all = (results -> results[:polswitchcount]).(worker_results)
    badpoltime_all_means[Symbol.(paras[i])] = badpoltime_all
    polsw_all_means[Symbol.(paras[i])] = polsw_all

    # store data dynamics
    totinfmean_all = vec(mean(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2))
    totinfstd_all = vec(std(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2))
    totinfmean_all_means[Symbol.(paras[i])] = totinfmean_all
    totinfstd_all_means_plus[Symbol.(paras[i])] = totinfmean_all + totinfstd_all
    totinfstd_all_means_minus[Symbol.(paras[i])] = totinfmean_all - totinfstd_all
    infmean = vec(mean(100*cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    infstd = vec(std(100*cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    infmean_all_means[Symbol.(paras[i])] = infmean
    infstd_all_means_plus[Symbol.(paras[i])] = infmean + infstd
    infstd_all_means_minus[Symbol.(paras[i])] = infmean - infstd
    global totcasmean = vec(mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    global totcasstd = vec(std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    totcasmean_all_means[Symbol.(paras[i])] = totcasmean
    totcasstd_all_means_plus[Symbol.(paras[i])] = totcasmean + totcasstd
    totcasstd_all_means_minus[Symbol.(paras[i])] = totcasmean - totcasstd
    # gdp
    gdpmean_all = vec(mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2))
    gdpstd_all = vec(std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2))
    gdpmean_all_means[Symbol.(paras[i])] = gdpmean_all
    gdpstd_all_means_plus[Symbol.(paras[i])] = gdpmean_all + gdpstd_all
    gdpstd_all_means_minus[Symbol.(paras[i])] = gdpmean_all - gdpstd_all
    # unemployment
    unempmean_all = vec(mean(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2))
    unempstd_all = vec(std(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2))
    unempmean_all_means[Symbol.(paras[i])] = unempmean_all
    unempstd_all_means_plus[Symbol.(paras[i])] = unempmean_all + unempstd_all
    unempstd_all_means_minus[Symbol.(paras[i])] = unempmean_all - unempstd_all
    # public account, adjusted
    pubh = (datat/(365*gdpmean[2]))*hcat((results -> results[:pubacctraj]).(worker_results)...)
    pubmean = vec(mean(pubh, dims=2))
    pubstd = vec(std(pubh, dims=2))
    pubaccmean_all_means[Symbol.(paras[i])] = pubmean
    pubaccmean_all_means_plus[Symbol.(paras[i])] = pubmean + pubstd
    pubaccmean_all_means_minus[Symbol.(paras[i])] = pubmean - pubstd
    #totfirms
    totfirmsmean_all = vec(mean(hcat((results -> results[:totfirmtraj]).(worker_results)...), dims=2))
    totfirmsstd_all = vec(std(hcat((results -> results[:totfirmtraj]).(worker_results)...), dims=2))
    totfirmsmean_all_means[Symbol.(paras[i])] = totfirmsmean_all
end

hcapfrac = zeros(datapoint+1)
for th = 1:datapoint+1
    hcapfrac[th] = hcap / (nhh * icufrac)
end

# Infections
pl8 = @df infmean_all_means[inf_start_week:inf_end_week, :] plot(datat*collect(inf_start_week:inf_end_week), cols(1), linewidth = [2],   legend = false, xlabel = "Days", ylabel = "infected [%]", label = false, linecolor = 1)
@df infstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor = 1 )
@df infstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1)

global i=0
for p in paras
    global i = i+1
    @df infmean_all_means[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df infstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df infstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl8,"$(filename_prefix)policy_comparison_infection_dynamics.pdf")

# Casulties
pl9 = @df totcasmean_all_means[inf_start_week:inf_end_week, :] plot(datat*collect(inf_start_week:inf_end_week),cols(1), linewidth = [2],   legend = false, xlabel = "Days", ylabel = "casualties [%]", label = false, linecolor =1)
@df totcasstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week),cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor =1)
@df totcasstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week),cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1)
global i=0
for p in paras
    global i = i+1
    @df totcasmean_all_means[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df totcasstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df totcasstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl9,"$(filename_prefix)policy_comparison_casulties_dynamics.pdf")

# GDP
pl10 = @df gdpmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1),  linewidth = [2],  legend = false, xlabel = "Days", ylabel = "GDP",label = false, linecolor =1)
@df gdpstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor = 1, label = ["" "" ""])
@df gdpstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df gdpmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df gdpstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df gdpstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl10,"$(filename_prefix)policy_comparison_gdp_dynamics.pdf")

# Unemployment
pl11 = @df unempmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1),   linewidth = [2], xlabel = "Days", ylabel = "unempl. [%]", legend = false, linecolor =1)
@df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot],  linecolor = 1,legend = false, label = ["" "" ""])
@df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], linecolor = 1,legend = false, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df unempmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl11,"$(filename_prefix)policy_comparison_unemployment_dynamics.pdf")

# public account
pl12 = @df pubaccmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1), title = "Public Account",  linewidth = [2],  legend = false, linecolor =1)
@df pubaccmean_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot], linecolor = 1, legend = false,label = ["" "" ""])
@df pubaccmean_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], linecolor = 1,legend = false, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df pubaccmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df pubaccmean_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df pubaccmean_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl12,"$(filename_prefix)policy_comparison_public_account_dynamics.pdf")