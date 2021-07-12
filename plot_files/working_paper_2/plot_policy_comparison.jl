using Statistics,Serialization,StatsPlots, DataFrames

filename_prefix = "../../figures/working_paper_2/"

path_to_data_prefix = "../../data/working_paper_2/"

mkpath(filename_prefix)

# define period of plotting for economic plots
start_week = 2 # cut of first week
end_week = 102
# set periods for covid plots
inf_start_day = 1
inf_end_day = 600 # cut of after period 400
inf_start_week = 1
inf_end_week = 86 # 58*7 = 406 and 42*7 = 294

include("../../data/working_paper_2/baseline_GER/covid_par_ini.jl") # necessary for some basic parameter values (nhh)

datapoint = fld(T,datat)

# parameter values
paras = ["beta_l5","beta_l10","beta_l30","baseline_GER"]

# scatterplot
gdploss_means = []
totcas_means = []
pubacc_means = []

for (i,p) in enumerate(paras)
    local path_to_data = string(path_to_data_prefix, p , "/")
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
    if p == "beta_l5"
        global point_A_x = gdploss
        global point_A_y = totcas
    end
    if p == "baseline_GER"
            global point_D_x = gdploss
            global point_D_y = totcas
        end
end
plfull = plot(gdploss_means, totcas_means, linewidth = 2, linecolor = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means, totcas_means, linewidth = 2, seriestype = :scatter, color = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

gdploss_means = reverse(gdploss_means)
totcas_means = reverse(totcas_means)
ll = length(paras)
plarrows = quiver(gdploss_means[1:ll-1],totcas_means[1:ll-1],quiver=(gdploss_means[2:ll]-gdploss_means[1:ll-1],totcas_means[2:ll]-totcas_means[1:ll-1]), color = [:black], linewidth = 2, xlabel = "average GDP loss [%]", ylabel = "mortality [%]")

scatter!(gdploss_means, totcas_means, markersize = 3, markercolor = [:black], legend=false)

paras = ["beta_l5_alpha_l025","beta_l5_alpha_l025_alpha_o025"]

# scatterplot
gdploss_means1 = []
totcas_means1 = []
pubacc_means1 = []

for (i,p) in enumerate(paras)
    local path_to_data = string(path_to_data_prefix, p , "/")
    # store data scatterplot
    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    local pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means1,gdploss)
    push!(totcas_means1,totcas)
    push!(pubacc_means1,pubacc)
    if p == "beta_l5_alpha_l025_alpha_o025"
        global point_E_x = gdploss
        global point_E_y = totcas
    end
end
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linewidth = 2)
scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], legend=false)

paras = ["baseline_GER","alpha_o025","alpha_o050","alpha_o075"]

# scatterplot
gdploss_means1 = []
totcas_means1 = []
pubacc_means1 = []

for (i,p) in enumerate(paras)
    local path_to_data = string(path_to_data_prefix, p , "/")
    # store data scatterplot
    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    local pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means1,gdploss)
    push!(totcas_means1,totcas)
    push!(pubacc_means1,pubacc)
    if p == "alpha_o050"
        global point_C_x = gdploss
        global point_C_y = totcas
    end
end
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linestyle= [:dot], linewidth = 2)
scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], linestyle= [:dot], legend=false)


paras = ["beta_l5_alpha_l025","beta_l5_alpha_l050","beta_l5_alpha_l075","beta_l5","beta_l5_alpha_l125"]

# scatterplot
gdploss_means2 = []
totcas_means2 = []
pubacc_means2 = []

for (i,p) in enumerate(paras)
    local path_to_data = string(path_to_data_prefix, p , "/")
    # store data scatterplot
    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    local pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means2,gdploss)
    push!(totcas_means2,totcas)
    push!(pubacc_means2,pubacc)
    if p == "beta_l5_alpha_l025"
        global point_B_x = gdploss
        global point_B_y = totcas
    end
end
plot!(plfull, gdploss_means2, totcas_means2, linewidth = 2, linecolor = [:red], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means2, totcas_means2, linewidth = 2, seriestype= [:scatter], color = [:red], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, [gdploss_means2[ll-1]],[totcas_means2[ll-1]],quiver=([gdploss_means2[ll]-gdploss_means2[ll-1]],[totcas_means2[ll]-totcas_means2[ll-1]]), linecolor = [:red], linewidth = 2)
gdploss_means2 = reverse(gdploss_means2)
totcas_means2 = reverse(totcas_means2)
quiver!(plarrows, gdploss_means2[2:ll-1],totcas_means2[2:ll-1],quiver=(gdploss_means2[3:ll]-gdploss_means2[2:ll-1],totcas_means2[3:ll]-totcas_means2[2:ll-1]), linecolor = [:red], linewidth = 2)
scatter!(gdploss_means2, totcas_means2, markersize = 3, markercolor = [:red], legend=false)

paras = ["alpha_l025","alpha_l050","alpha_l075","baseline_GER","alpha_l125"]

# scatterplot
gdploss_means2 = []
totcas_means2 = []
pubacc_means2 = []

for (i,p) in enumerate(paras)
    local path_to_data = string(path_to_data_prefix, p , "/")
    # store data scatterplot
    local worker_results = deserialize(open("$(path_to_data)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    local pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means2,gdploss)
    push!(totcas_means2,totcas)
    push!(pubacc_means2,pubacc)
end
plot!(plfull, gdploss_means2, totcas_means2, linewidth = 2, linestyle= [:dot], linecolor = [:red], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means2, totcas_means2, linewidth = 2, linestyle= [:dot], seriestype= [:scatter], color = [:red], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, [gdploss_means2[ll-1]],[totcas_means2[ll-1]],quiver=([gdploss_means2[ll]-gdploss_means2[ll-1]],[totcas_means2[ll]-totcas_means2[ll-1]]), linecolor = [:red], linestyle= [:dot], linewidth = 2)
gdploss_means2 = reverse(gdploss_means2)
totcas_means2 = reverse(totcas_means2)
quiver!(plarrows, gdploss_means2[2:ll-1],totcas_means2[2:ll-1],quiver=(gdploss_means2[3:ll]-gdploss_means2[2:ll-1],totcas_means2[3:ll]-totcas_means2[2:ll-1]), linecolor = [:red], linestyle= [:dot], linewidth = 2)
scatter!(gdploss_means2, totcas_means2, markersize = 3, markercolor = [:red], linestyle= [:dot], legend=false)




### add specific points A B C
scatter!([point_A_x], [point_A_y], markersize = 4, markercolor = [:green])
scatter!([point_A_x], [point_A_y+0.0008], markersize = 0, markercolor = [:white], series_annotations = text.(["B"], :bottom))

scatter!([point_B_x], [point_B_y], markersize = 4, markercolor = [:green])
scatter!([point_B_x], [point_B_y+0.0008], markersize = 0, markercolor = [:white], series_annotations = text.(["C"], :bottom))

scatter!([point_C_x], [point_C_y], markersize = 4, markercolor = [:green])
scatter!([point_C_x-0.25], [point_C_y], markersize = 0, markercolor = [:white], series_annotations = text.(["D"], :right))

scatter!([point_D_x], [point_D_y], markersize = 4, markercolor = [:green])
scatter!([point_D_x], [point_D_y+0.001], markersize = 0, markercolor = [:white], series_annotations = text.(["A"], :bottom))

scatter!([point_E_x], [point_E_y], markersize = 4, markercolor = [:green])
scatter!([point_E_x-0.3], [point_E_y-0.002], markersize = 0, markercolor = [:white], series_annotations = text.(["E"], :left))

ylims!(plfull,0.005,0.07)
xlims!(plfull,0,9)

savefig(plarrows,"$(filename_prefix)policy_comparison.pdf")
