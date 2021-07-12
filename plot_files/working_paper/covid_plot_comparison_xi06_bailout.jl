using Statistics,Serialization,StatsPlots, DataFrames, LaTeXStrings



filename_prefix = "..//..//data//working_paper//bailout//xi06//"
plotname_prefix = "..//..//figures//working_paper//bailout_xi06_comparison_" # store the plots here
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


suppfig2a = quiver(gdploss_means[1:ll-1],totcas_means[1:ll-1],quiver=(gdploss_means[2:ll]-gdploss_means[1:ll-1],totcas_means[2:ll]-totcas_means[1:ll-1]), color = [:red], linewidth = 2, xlabel = "Average GDP loss [%]", ylabel = "Mortality [%]")
scatter!(suppfig2a, gdploss_means, totcas_means, markersize = 5, markercolor = [:red], legend=false)


ylims!(suppfig2a,0.008,0.065)
xlims!(suppfig2a,0,10)



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

quiver!(suppfig2a, gdploss_means4[1:ll-1],totcas_means4[1:ll-1],quiver=(gdploss_means4[2:ll]-gdploss_means4[1:ll-1],totcas_means4[2:ll]-totcas_means4[1:ll-1]), color = [:blue], linewidth = 2)
scatter!(suppfig2a, gdploss_means4, totcas_means4, markersize = 5, markercolor = [:blue], legend=false)



### add specific points A B C
scatter!(suppfig2a, [point_A_x], [point_A_y], markersize = 6, markercolor = [:black])
annotate!(suppfig2a,[point_A_x+0.4], [point_A_y+0.0005], text.([L"A_1"]) , fontsize=60 )

scatter!(suppfig2a, [point_B_x], [point_B_y], markersize = 6, markercolor = [:black])
annotate!(suppfig2a,[point_B_x+0.4], [point_B_y+0.0015], text.([L"B_1"]) , fontsize=160 )

scatter!(suppfig2a, [point_C_x], [point_C_y], markersize = 6, markercolor = [:black])
annotate!(suppfig2a,[point_C_x+0.4], [point_C_y], text.([L"C_1"]) , fontsize=160 )


plot!(suppfig2a, size=(600,400))
savefig(suppfig2a,"$(plotname_prefix)supp_fig_2a.pdf")
