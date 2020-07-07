using Statistics,Serialization,StatsPlots, DataFrames



# parameter values
filename_prefix = "..//data//main//xi05//"
paras = ["beta5//alpha1","beta5//alpha25","beta30/alpha1"]

plotname_prefix = "..//figures//main_xi05_" # store the plots here

badpol = true # do you have data for badpol and switches?
show_capacity = false # for Infected plot

# set intial values as in coivd par ini
datat = 7 # interval of data collection
T = 582 #582  # time periods

# define period of plotting for economic plots
start_week = 3 # cut of first week
end_week = 84
# set periods for covid plots
inf_start_day = 1
inf_end_day = 400 # cut of after period 400
inf_start_week = 3
inf_end_week = 58 # 58*7 = 406 and 42*7 = 294

datapoint = fld(T,datat)
include("$(filename_prefix)beta5//alpha1//covid_par_ini.jl")


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
    data_prefix = string("$(filename_prefix)", p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
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
    if badpol
        badpoltime_all = (results -> results[:badpoltime]).(worker_results)
        polsw_all = (results -> results[:polswitchcount]).(worker_results)
        badpoltime_all_means[Symbol.(paras[i])] = badpoltime_all
        polsw_all_means[Symbol.(paras[i])] = polsw_all
    end
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
pl1
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
ylims!(pl2,0.0,1.8)
savefig(pl2,"$(plotname_prefix)scen_infdyn.pdf")


pl3 = @df totcasmean_all_means[inf_start_week:inf_end_week, :] plot(datat*collect(inf_start_week:inf_end_week),cols(1), linewidth = [2],   legend = false, xlabel = "Day", ylabel = "casualties [%]", label = false, linecolor =1)
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

ylims!(pl4,30,47)

savefig(pl4,"$(plotname_prefix)scen_gdpdyn.pdf")


pl5 = @df unempmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1),   linewidth = [2], xlabel = "Day", ylabel = "unempl. [%]", legend = false, linecolor =1)
@df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot],  linecolor = 1,legend = false, label = ["" "" ""])
@df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], linecolor = 1,legend = false, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df unempmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df unempstd_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df unempstd_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl5,"$(plotname_prefix)scen_unempdyn.pdf")


pl6 = @df pubaccmean_all_means[start_week:end_week, :] plot(datat*collect(start_week:end_week), cols(1), title = "Public Account",  linewidth = [2],  legend = false, linecolor =1)
@df pubaccmean_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linewidth = [1], linestyle= [:dot], linecolor = 1, legend = false,label = ["" "" ""])
@df pubaccmean_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(1), linestyle= [:dot], linewidth = [1], linecolor = 1,legend = false, label = ["" "" ""])
global i=0
for p in paras
    global i = i+1
    @df pubaccmean_all_means[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [2],  legend = false, label = false, linecolor = i)
    @df pubaccmean_all_means_plus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linewidth = [1], linestyle= [:dot], linecolor = i)
    @df pubaccmean_all_means_minus[start_week:end_week, :] plot!(datat*collect(start_week:end_week), cols(i), linestyle= [:dot], linewidth = [1], linecolor = i)
end
savefig(pl6,"$(plotname_prefix)scen_pubaccdyn.pdf")
