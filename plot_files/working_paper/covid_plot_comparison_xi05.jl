using Statistics,Serialization,StatsPlots, DataFrames, LaTeXStrings



filename_prefix = "..//..//data//working_paper//main//xi05//"
plotname_prefix = "..//..//figures//working_paper//main_xi05_comparison_" # store the plots here
mkpath(plotname_prefix)

show_capacity = false # for infected plot


# set intial values as in coivd par ini
datat = 7 # interval of data collection
T = 582 #582  # time periods

# define period of plotting for economic plots
start_week = 2 # cut of first week
end_week = 84
# set periods for covid plots
inf_start_day = 1
inf_end_day = 400 # cut of after period 400
inf_start_week = 1
inf_end_week = 58 # 58*7 = 406 and 42*7 = 294

datapoint = fld(T,datat)
include("$(filename_prefix)beta5//alpha1//covid_par_ini.jl")


### blue LINES
# parameter values for xi = 0.6
paras = ["beta5//alpha25","beta5//alpha50","beta5//alpha75","beta5//alpha1"]



# scatterplot
gdploss_means = []
totcas_means = []

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
    if p == "beta5//alpha1"
        global point_A_x = gdploss
        global point_A_y = totcas
    end
    if p == "beta5//alpha25"
        global point_B_x = gdploss
        global point_B_y = totcas
    end
end

ll = length(paras)
gdploss_means = reverse(gdploss_means)
totcas_means = reverse(totcas_means)
suppfig3b = quiver(gdploss_means[1:ll-1],totcas_means[1:ll-1],quiver=(gdploss_means[2:ll]-gdploss_means[1:ll-1],totcas_means[2:ll]-totcas_means[1:ll-1]), color = [:red], linewidth = 2, xlabel = "Average GDP loss [%]", ylabel = "Mortality [%]")
scatter!(suppfig3b, gdploss_means, totcas_means, markersize = 5, markercolor = [:red], legend=false)


fig2b = quiver(gdploss_means[1:ll-1],totcas_means[1:ll-1],quiver=(gdploss_means[2:ll]-gdploss_means[1:ll-1],totcas_means[2:ll]-totcas_means[1:ll-1]), color = [:red], linewidth = 2, xlabel = "Average GDP loss [%]", ylabel = "Mortality [%]")
scatter!(fig2b, gdploss_means, totcas_means, markersize = 5, markercolor = [:red], legend=false)


# set boundaries
ylims!(suppfig3b,0.008,0.07)
xlims!(suppfig3b,0,10)

ylims!(fig2b,0.008,0.055)
xlims!(fig2b,0,10)

### black LINES
paras = ["beta10//alpha25","beta10//alpha50","beta10//alpha75","beta10//alpha1"]

# scatterplot
gdploss_means2 = []
totcas_means2 = []

for (i,p) in enumerate(paras)
    data_prefix = string("$(filename_prefix)", p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    push!(gdploss_means2,gdploss)
    push!(totcas_means2,totcas)
end

ll = length(paras)
gdploss_means2 = reverse(gdploss_means2)
totcas_means2 = reverse(totcas_means2)
quiver!(suppfig3b, gdploss_means2[1:ll-1],totcas_means2[1:ll-1],quiver=(gdploss_means2[2:ll]-gdploss_means2[1:ll-1],totcas_means2[2:ll]-totcas_means2[1:ll-1]), color = [:black], linewidth = 2)
scatter!(suppfig3b, gdploss_means2, totcas_means2, markersize = 5, markercolor = [:black], legend=false)


### Green LINES
paras = ["beta30//alpha25","beta30//alpha50","beta30//alpha75","beta30//alpha1"]

# scatterplot
gdploss_means3 = []
totcas_means3 = []

for (i,p) in enumerate(paras)
    data_prefix = string("$(filename_prefix)", p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    push!(gdploss_means3,gdploss)
    push!(totcas_means3,totcas)
    if p == "beta30//alpha25"
        global point_D_x = gdploss
        global point_D_y = totcas
    end
end

ll = length(paras)
gdploss_means3 = reverse(gdploss_means3)
totcas_means3 = reverse(totcas_means3)
quiver!(suppfig3b, gdploss_means3[1:ll-1],totcas_means3[1:ll-1],quiver=(gdploss_means3[2:ll]-gdploss_means3[1:ll-1],totcas_means3[2:ll]-totcas_means3[1:ll-1]), color = [:green], linewidth = 2)
scatter!(suppfig3b, gdploss_means3, totcas_means3, markersize = 5, markercolor = [:green], legend=false)


### blue LINES
paras = ["beta5//alpha1","beta10//alpha1","beta30//alpha1"]

# scatterplot
gdploss_means4 = []
totcas_means4 = []

for (i,p) in enumerate(paras)
    data_prefix = string("$(filename_prefix)", p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss = mean((results -> results[:togdploss]).(worker_results))
    totcas = mean(100*(results -> results[:totcas]).(worker_results))
    gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
    global nn = size(gdpmean)[1]
    push!(gdploss_means4,gdploss)
    push!(totcas_means4,totcas)
    if p == "beta30//alpha1"
        global point_C_x = gdploss
        global point_C_y = totcas
    end
end

ll = length(paras)
quiver!(suppfig3b, gdploss_means4[1:ll-1],totcas_means4[1:ll-1],quiver=(gdploss_means4[2:ll]-gdploss_means4[1:ll-1],totcas_means4[2:ll]-totcas_means4[1:ll-1]), color = [:blue], linewidth = 2)
scatter!(suppfig3b, gdploss_means4, totcas_means4, markersize = 5, markercolor = [:blue], legend=false)

quiver!(fig2b, gdploss_means4[1:ll-1],totcas_means4[1:ll-1],quiver=(gdploss_means4[2:ll]-gdploss_means4[1:ll-1],totcas_means4[2:ll]-totcas_means4[1:ll-1]), color = [:blue], linewidth = 2)
scatter!(fig2b, gdploss_means4, totcas_means4, markersize = 5, markercolor = [:blue], legend=false)



#### add specific points A B C
scatter!(suppfig3b, [point_A_x], [point_A_y], markersize = 6, markercolor = [:black])
annotate!(suppfig3b,[point_A_x+0.4], [point_A_y+0.0005], text.([L"A_2"]) , fontsize=60 )

scatter!(suppfig3b, [point_B_x], [point_B_y], markersize = 6, markercolor = [:black])
annotate!(suppfig3b,[point_B_x], [point_B_y-0.003], text.([L"B_2"]) , fontsize=160 )

scatter!(suppfig3b, [point_C_x], [point_C_y], markersize = 6, markercolor = [:black])
annotate!(suppfig3b,[point_C_x+0.4], [point_C_y], text.([L"C_2"]) , fontsize=160 )

scatter!(suppfig3b, [point_D_x], [point_D_y], markersize = 6, markercolor = [:black])
annotate!(suppfig3b,[point_D_x], [point_D_y-0.003], text.([L"D_2"]) , fontsize=160 )



plot!(suppfig3b, size=(600,400))
savefig(suppfig3b,"$(plotname_prefix)supp_fig_3b.pdf")



### add specific points A B C
scatter!(fig2b, [point_A_x], [point_A_y], markersize = 6, markercolor = [:black])
annotate!(fig2b,[point_A_x+0.4], [point_A_y+0.0005], text.([L"A_2"]) , fontsize=60 )
# scatter!(plarrows, [point_A_x-0.3], [point_A_y], markersize = 0, markercolor = [:white], series_annotations = text.([L"\textrm{\sffamily A_1}"], :top))

scatter!(fig2b, [point_B_x], [point_B_y], markersize = 6, markercolor = [:black])
annotate!(fig2b,[point_B_x+0.4], [point_B_y+0.0005], text.([L"B_2"]) , fontsize=160 )
#scatter!(plarrows, [point_B_x], [point_B_y-0.003], markersize = 0, markercolor = [:white], series_annotations = text.([L"B_1"], :top))

scatter!(fig2b, [point_C_x], [point_C_y], markersize = 6, markercolor = [:black])
annotate!(fig2b,[point_C_x+0.4], [point_C_y], text.([L"C_2"]) , fontsize=160 )


plot!(fig2b, size=(600,400))
savefig(fig2b,"$(plotname_prefix)fig_2b.pdf")
