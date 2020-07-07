using Statistics,Serialization,StatsPlots, DataFrames



# parameter values
filename_prefix = "..//data//no_pol//"
paras = ["nopol","xi06","xi06_ho"]

plotname_prefix = "..//figures//no_pol_" # store the plots here

show_capacity = true # for icu capacity in infetected plot

# set intial values as in coivd par ini
datat = 7 # interval of data collection
T = 582 #582  # time periods

# define period of plotting for economic plots
start_week = 3 # cut of first week
end_week = 42
# set periods for covid plots
inf_start_day = 1
inf_end_day = 300 # cut of after period 400
inf_start_week = 3
inf_end_week = 42 # 58*7 = 406 and 42*7 = 294

datapoint = fld(T,datat)
include("$(filename_prefix)nopol//covid_par_ini.jl")


# scatterplot
gdploss_means = []
totcas_means = []

# boxplots
number_batches = 20
gdploss_all_means = DataFrame()
totcas_all_means = DataFrame()
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



for (i,p) in enumerate(paras)
    data_prefix = string("$(filename_prefix)", p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    push!(gdploss_means,gdploss)
    push!(totcas_means,totcas)
    # store data boxplot
    gdploss_all = (results -> results[:togdploss]).(worker_results)
    totcas_all = 100*(results -> results[:totcas]).(worker_results)
    gdploss_all_means[Symbol.(paras[i])] = gdploss_all
    totcas_all_means[Symbol.(paras[i])] = totcas_all
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
    totcasmean = vec(mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    totcasstd = vec(std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
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
end



### plot dynamics
# inf plots daily array
pl1 = @df totinfmean_all_means[inf_start_day:inf_end_day, :] plot(collect(inf_start_day:inf_end_day), cols(1), linewidth = [2],  legend = false, xlabel = "Day", ylabel = "tot. inf. [%]", label = false, linecolor = 1)
@df totinfstd_all_means_plus[inf_start_day:inf_end_day, :] plot!(collect(inf_start_day:inf_end_day), cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor = 1)
@df totinfstd_all_means_minus[inf_start_day:inf_end_day, :] plot!(collect(inf_start_day:inf_end_day), cols(1), linestyle= [:dot], linewidth = [1], legend = false, linecolor = 1)
global i=0
for p in paras
    global i = i+1
    @df totinfmean_all_means[inf_start_day:inf_end_day, :] plot!(collect(inf_start_day:inf_end_day), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i, xlabel = "Day", ylabel = "tot. inf. [%]")
    @df totinfstd_all_means_plus[inf_start_day:inf_end_day, :] plot!(collect(inf_start_day:inf_end_day), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df totinfstd_all_means_minus[inf_start_day:inf_end_day, :] plot!(collect(inf_start_day:inf_end_day), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i, xlabel = "Day", ylabel = "tot. inf. [%]")
end
savefig(pl1,"$(plotname_prefix)scen_totinfdyn.pdf")



hcapfrac = zeros(datapoint+1)
for th = 1:datapoint+1
    hcapfrac[th] = hcap / (nhh * icufrac)
end

# inf plots weekly array
pl2 = @df infmean_all_means[inf_start_week:inf_end_week, :] plot(datat*collect(inf_start_week:inf_end_week), cols(1), linewidth = [2],   legend = false, xlabel = "Day", ylabel = "Infected [%]", label = false, linecolor = 1)
@df infstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor = 1 )
@df infstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1)
if show_capacity
    plot!([100*hcap / (nhh * icufrac)], seriestype = :hline, linestyle= [:dot], linewidth = [2], linecolor = [:black], label = "capacity")
end
global i=0
for p in paras
    global i = i+1
    @df infmean_all_means[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df infstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df infstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl2,"$(plotname_prefix)scen_infdyn.pdf")


pl3 = @df totcasmean_all_means[inf_start_week:inf_end_week, :] plot(datat*collect(inf_start_week:inf_end_week),cols(1), linewidth = [2],   legend = false, xlabel = "Day", ylabel = "Casualties [%]", label = false, linecolor =1)
@df totcasstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week),cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor =1)
@df totcasstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week),cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1)
global i=0
for p in paras
    global i = i+1
    @df totcasmean_all_means[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df totcasstd_all_means_plus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df totcasstd_all_means_minus[inf_start_week:inf_end_week, :] plot!(datat*collect(inf_start_week:inf_end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl3,"$(plotname_prefix)scen_casdyn.pdf")


# eco plots weekly array
pl4 = @df gdpmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1),  linewidth = [2],  legend = false, xlabel = "Day", ylabel = "GDP",label = false, linecolor =1)
@df gdpstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot], legend = false,linecolor = 1, label = ["" "" ""])
@df gdpstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], legend = false,linecolor = 1, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df gdpmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df gdpstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df gdpstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
ylims!((43,45))
savefig(pl4,"$(plotname_prefix)scen_gdpdyn.pdf")


pl5 = @df unempmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1),   linewidth = [2], xlabel = "Day", ylabel = "Unempl. [%]", legend = false, linecolor =1)
@df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot],  linecolor = 1,legend = false, label = ["" "" ""])
@df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], linecolor = 1,legend = false, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df unempmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
ylims!(0.035,0.055)
savefig(pl5,"$(plotname_prefix)scen_unempdyn.pdf")
