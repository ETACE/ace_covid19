using Statistics,Serialization,StatsPlots, DataFrames

filename_prefix = "../figures/"
path_to_data = "../data/no_mutation/"

badpol = true # do you have data for badpol and switches?
show_capacity = false # for infected plot


# set intial values as in coivd par ini
datat = 7 # interval of data collection
T = 744 #582  # time periods

# define period of plotting for economic plots
start_week = 2 # cut of first week
end_week = 102
# set periods for covid plots
inf_start_day = 1
inf_end_day = 600 # cut of after period 400
inf_start_week = 1
inf_end_week = 86 # 58*7 = 406 and 42*7 = 294

datapoint = fld(T,datat)
include("../data/no_mutation/beta_l10/covid_par_ini.jl") # necessary for some basic parameter values (nhh)

# parameter values
paras = ["beta_l0","beta_l5","beta_l30","beta_l50", "beta_l100"]

# scatterplot
gdploss_means = []
totcas_means = []
pubacc_means = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means,gdploss)
    push!(totcas_means,totcas)
    push!(pubacc_means,pubacc)
    if p == "beta_l5"
        global point_A_x = gdploss
        global point_A_y = totcas
    end
    if p == "beta_l50"
            global point_D_x = gdploss
            global point_D_y = totcas
        end
end
plfull = plot(gdploss_means, totcas_means, linewidth = 2, linecolor = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means, totcas_means, linewidth = 2, seriestype = :scatter, color = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
plarrows = quiver([gdploss_means[ll-1]],[totcas_means[ll-1]],quiver=([gdploss_means[ll]-gdploss_means[ll-1]],[totcas_means[ll]-totcas_means[ll-1]]), linecolor = [:black], linewidth = 2, xlabel = "average GDP loss [%]", ylabel = "mortality [%]")
gdploss_means = reverse(gdploss_means)
totcas_means = reverse(totcas_means)
ll = length(paras)
quiver!(plarrows, gdploss_means[2:ll-1],totcas_means[2:ll-1],quiver=(gdploss_means[3:ll]-gdploss_means[2:ll-1],totcas_means[3:ll]-totcas_means[2:ll-1]), linecolor = [:black], linewidth = 2)
scatter!(gdploss_means, totcas_means, markersize = 3, markercolor = [:black], legend=false)


# parameter values
#paras = ["p10_050","p30_050","p50_050"]
#
# scatterplot
#gdploss_means = []
#totcas_means = []
#pubacc_means = []
#
#for (i,p) in enumerate(paras)
#    #filename_prefix = string("adap_start//", p , "//")
#    prefix = string(path_to_data, "/", p , "/")
#    # store data scatterplot
#    worker_results = deserialize(open("$(prefix)batchdata.dat"))
#    gdploss = mean((results -> results[:togdploss]).(worker_results))
#    totcas = mean(100*(results -> results[:totcas]).(worker_results))
#    pubacch = (results -> results[:pubacctraj]).(worker_results)
#    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
#    global nn = size(gdpmean)[1]
#    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
#    push!(gdploss_means,gdploss)
#    push!(totcas_means,totcas)
#    push!(pubacc_means,pubacc)
#end
#plot!(plfull, gdploss_means, totcas_means, linewidth = 2, linestyle = [:dot], linecolor = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
#plot!(plfull, gdploss_means, totcas_means, linewidth = 2, seriestype = [:scatter], color = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
#
#ll = length(paras)
#quiver!(plarrows, gdploss_means[1:ll-1],totcas_means[1:ll-1],quiver=(gdploss_means[2:ll]-gdploss_means[1:ll-1],totcas_means[2:ll]-totcas_means[1:ll-1]), linecolor = [:black], linestyle = [:dot], linewidth = 2)
#scatter!(gdploss_means, totcas_means, markersize = 3, markercolor = [:black], legend=false)

paras = ["beta_l5","beta_l5_alpha_o025","beta_l5_alpha_o050","beta_l5_alpha_o075","beta_l5_alpha_o100"]

# scatterplot
gdploss_means1 = []
totcas_means1 = []
pubacc_means1 = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means1,gdploss)
    push!(totcas_means1,totcas)
    push!(pubacc_means1,pubacc)
end
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linewidth = 2)
scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], legend=false)


paras = ["beta_l5_alpha_l050","beta_l5_alpha_l050_alpha_o025","beta_l5_alpha_l050_alpha_o050"]

# scatterplot
gdploss_means1 = []
totcas_means1 = []
pubacc_means1 = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means1,gdploss)
    push!(totcas_means1,totcas)
    push!(pubacc_means1,pubacc)
    if p == "beta_l5_alpha_l050_alpha_o050"
        global point_E_x = gdploss
        global point_E_y = totcas
    end
end
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linewidth = 2)
scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], legend=false)

paras = ["beta_l50","beta_l50_alpha_o025","beta_l50_alpha_o050","beta_l50_alpha_o075","beta_l50_alpha_o100"]

# scatterplot
gdploss_means1 = []
totcas_means1 = []
pubacc_means1 = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means1,gdploss)
    push!(totcas_means1,totcas)
    push!(pubacc_means1,pubacc)
    if p == "beta_l50_alpha_o050"
        global point_C_x = gdploss
        global point_C_y = totcas
    end
end
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

ll = length(paras)
quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linestyle= [:dot], linewidth = 2)
scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], linestyle= [:dot], legend=false)


# paras = ["5","5_025","5_050","5_075"]
#
# # scatterplot
# gdploss_means1 = []
# totcas_means1 = []
# pubacc_means1 = []
#
# for (i,p) in enumerate(paras)
#     #filename_prefix = string("adap_start//", p , "//")
#     prefix = string(path_to_data, "/", p , "/")
#     # store data scatterplot
#     worker_results = deserialize(open("$(prefix)batchdata.dat"))
#     gdploss = mean((results -> results[:togdploss]).(worker_results))
#     totcas = mean(100*(results -> results[:totcas]).(worker_results))
#     pubacch = (results -> results[:pubacctraj]).(worker_results)
#     gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
#     global nn = size(gdpmean)[1]
#     pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
#     push!(gdploss_means1,gdploss)
#     push!(totcas_means1,totcas)
#     push!(pubacc_means1,pubacc)
#     if p == "50_050"
#         global point_C_x = gdploss
#         global point_C_y = totcas
#     end
# end
# plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], linecolor = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
# plot!(plfull, gdploss_means1, totcas_means1, linewidth = 2, linestyle= [:dot], seriestype = [:scatter], color = [:blue], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
#
# ll = length(paras)
# quiver!(plarrows, gdploss_means1[1:ll-1],totcas_means1[1:ll-1],quiver=(gdploss_means1[2:ll]-gdploss_means1[1:ll-1],totcas_means1[2:ll]-totcas_means1[1:ll-1]), linecolor = [:blue], linestyle= [:dot], linewidth = 2)
# scatter!(gdploss_means1, totcas_means1, markersize = 3, markercolor = [:blue], linestyle= [:dot], legend=false)


paras = ["beta_l5_alpha_l025","beta_l5_alpha_l050","beta_l5_alpha_l075","beta_l5","beta_l5_alpha_l125"]

# scatterplot
gdploss_means2 = []
totcas_means2 = []
pubacc_means2 = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
    push!(gdploss_means2,gdploss)
    push!(totcas_means2,totcas)
    push!(pubacc_means2,pubacc)
    if p == "beta_l5_alpha_l050"
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

paras = ["beta_l50_alpha_l025","beta_l50_alpha_l050","beta_l50_alpha_l075","beta_l50","beta_l50_alpha_l125"]

# scatterplot
gdploss_means2 = []
totcas_means2 = []
pubacc_means2 = []

for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    prefix = string(path_to_data, "/", p , "/")
    # store data scatterplot
    worker_results = deserialize(open("$(prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    pubacch = (results -> results[:pubacctraj]).(worker_results)
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    pubacc = mean([pubacch[i][datapoint+1]*datat/(365*gdpmean[2]) for  i = 1:size(pubacch)[1]])
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
scatter!([point_A_x- 0.15], [point_A_y], markersize = 0, markercolor = [:white], series_annotations = text.(["B"], :top))

scatter!([point_B_x], [point_B_y], markersize = 4, markercolor = [:green])
scatter!([point_B_x], [point_B_y-0.002], markersize = 0, markercolor = [:white], series_annotations = text.(["C"], :top))

#scatter!([point_C_x], [point_C_y], markersize = 4, markercolor = [:green])
#scatter!([point_C_x-0.15], [point_C_y], markersize = 0, markercolor = [:white], series_annotations = text.(["D"], :right))

scatter!([point_D_x], [point_D_y], markersize = 4, markercolor = [:green])
scatter!([point_D_x+0.15], [point_D_y+0.001], markersize = 0, markercolor = [:white], series_annotations = text.(["A"], :bottom))

scatter!([point_E_x], [point_E_y], markersize = 4, markercolor = [:green])
scatter!([point_E_x+.05], [point_E_y+0.002], markersize = 0, markercolor = [:white], series_annotations = text.(["D"], :bottom))



ylims!(plarrows,0.0,0.1)
xlims!(plarrows,0,6)

savefig(plarrows,"$(filename_prefix)variation_policy_no_mutation.pdf")
