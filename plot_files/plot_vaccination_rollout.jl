using Statistics,Serialization,StatsPlots, DataFrames



# paras = ["no_pol","dist","dist_ho"]
badpol = true # do you have data for badpol and switches?
show_capacity = false # for infected plot

filename_prefix = "../figures/" # store the plots here

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
include("../data/vaccination_rollout/beta_l50_60//covid_par_ini.jl") # necessary for some basic parameter values (nhh)

plfull = plot()

pcts = ["100", "40", "25", "0"]

for p in ["beta_l5_", "beta_l50_", "beta_l5_alpha_l050_", "beta_l5_alpha_l050_alpha_o050_"]
    # scatterplot
    gdploss_means = []
    totcas_means = []
    pubacc_means = []

    for pct in pcts
        prefix = "../data/vaccination_rollout/$p$pct/"
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

        if "$p$pct" == "beta_l50_100"
            global point_A_x = gdploss
            global point_A_y = totcas
        end

        if "$p$pct" == "beta_l5_100"
            global point_B_x = gdploss
            global point_B_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_100"
            global point_C_x = gdploss
            global point_C_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_alpha_o050_100"
            global point_D_x = gdploss
            global point_D_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_0"
            global point_C_0_x = gdploss
            global point_C_0_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_25"
            global point_C_25_x = gdploss
            global point_C_25_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_40"
            global point_C_40_x = gdploss
            global point_C_40_y = totcas
        end

        if "$p$pct" == "beta_l5_alpha_l050_100"
            global point_C_100_x = gdploss
            global point_C_100_y = totcas
        end


        #if "$p$pct" == "100_100"
        #    global point_E_x = gdploss
        #    global point_E_y = totcas
        #end
    end

    plot!(plfull, gdploss_means, totcas_means, linewidth = 2, linecolor = [:black], legend=false, xlabel = "average GDP loss [%]", ylabel = "mortality [%]") #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)
    plot!(plfull, gdploss_means, totcas_means, linewidth = 2, seriestype = :scatter, color = [:black], legend=false) #, linewidth = [2], linecolor = [:black], xlabel = "Average GDP Loss", ylabel = "Total Casualties", group = paras, legend =:top)

end

### add specific points A B C
scatter!([point_A_x], [point_A_y-0.001], markersize = 0, markercolor = [:white], series_annotations = text.(["A"], :top))

scatter!([point_B_x], [point_B_y-0.001], markersize = 0, markercolor = [:white], series_annotations = text.(["B"], :top))

scatter!([point_C_x], [point_C_y-0.003], markersize = 0, markercolor = [:white], series_annotations = text.(["C"], :top))

scatter!([point_D_x], [point_D_y-0.001], markersize = 0, markercolor = [:white], series_annotations = text.(["D"], :top))


scatter!([point_C_0_x+0.08], [point_C_0_y+0.003], markersize = 0, markercolor = [:white], series_annotations = text.(["0%"], :top, 5))
scatter!([point_C_25_x+0.1], [point_C_25_y+0.004], markersize = 0, markercolor = [:white], series_annotations = text.(["25%"], :top, 5))
scatter!([point_C_40_x+0.08], [point_C_40_y+0.007], markersize = 0, markercolor = [:white], series_annotations = text.(["40%"], :top, 5))
scatter!([point_C_100_x-0.03], [point_C_100_y+0.007], markersize = 0, markercolor = [:white], series_annotations = text.(["100%"], :top, 5))


ylims!(plfull,0.005,0.25)
xlims!(plfull,0,4)

#ylims!(plfull,0.005,0.06)
#xlims!(plfull,0,8)

savefig(plfull,"$(filename_prefix)vaccination_rollout.pdf")


#ylims!(plarrows,0.005,0.13)
#xlims!(plarrows,0,12)
