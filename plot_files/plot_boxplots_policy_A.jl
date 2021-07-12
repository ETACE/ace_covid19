using Statistics,Serialization,StatsPlots, DataFrames



# parameter values
paras = ["../data/mutation/beta_l50","../data/no_mutation/beta_l50","../data/no_mutation_pinf125/beta_l50"]
paras_name = ["mutation","no mutation","higher p inf"]

filename_prefix = "../figures/boxplots_policy_A_" # store the plots here

badpol = true # do you have data for badpol and switches?
show_capacity = true # for infected plot

# set intial values as in coivd par ini
datat = 7 # interval of data collection
T = 740 #582  # time periods

# define period of plotting for economic plots
start_week = 3 # cut of first week
end_week = 104
# set periods for covid plots
inf_start_day = 1
inf_end_day = 740 # cut of after period 400
inf_start_week = 3
inf_end_week = 104 # 58*7 = 406 and 42*7 = 294

datapoint = fld(T,datat)
include("../data/mutation//beta_l50/covid_par_ini.jl") # necessary for some basic parameter values (nhh)


# scatterplot
gdploss_means = []
totcas_means = []
pubacc_means = []

# boxplots
number_batches = 50
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


for (i,p) in enumerate(paras)
    #filename_prefix = string("adap_start//", p , "//")
    filename_prefix = string( p , "//")
    # store data scatterplot
    worker_results = deserialize(open("$(filename_prefix)batchdata.dat"))
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
    gdploss_all_means[!, Symbol.(paras_name[i])] = gdploss_all
    totcas_all_means[!, Symbol.(paras_name[i])] = totcas_all
    pubacc_all_means[!, Symbol.(paras_name[i])] = pubacc_all
    if badpol
        badpoltime_all = (results -> results[:badpoltime]).(worker_results)
        polsw_all = (results -> results[:polswitchcount]).(worker_results)
        badpoltime_all_means[!, Symbol.(paras_name[i])] = badpoltime_all
        polsw_all_means[!, Symbol.(paras_name[i])] = polsw_all
    end
    # store data dynamics
    totinfmean_all = vec(mean(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2))
    totinfstd_all = vec(std(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2))
    totinfmean_all_means[!, Symbol.(paras_name[i])] = totinfmean_all
    totinfstd_all_means_plus[!, Symbol.(paras_name[i])] = totinfmean_all + totinfstd_all
    totinfstd_all_means_minus[!, Symbol.(paras_name[i])] = totinfmean_all - totinfstd_all
    infmean = vec(mean(100*cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    infstd = vec(std(100*cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    infmean_all_means[!, Symbol.(paras_name[i])] = infmean
    infstd_all_means_plus[!, Symbol.(paras_name[i])] = infmean + infstd
    infstd_all_means_minus[!, Symbol.(paras_name[i])] = infmean - infstd
    totcasmean = vec(mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    totcasstd = vec(std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)[2:nn,3])
    totcasmean_all_means[!, Symbol.(paras_name[i])] = totcasmean
    totcasstd_all_means_plus[!, Symbol.(paras_name[i])] = totcasmean + totcasstd
    totcasstd_all_means_minus[!, Symbol.(paras_name[i])] = totcasmean - totcasstd
    # gdp
    gdpmean_all = vec(mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2))
    gdpstd_all = vec(std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2))
    gdpmean_all_means[!, Symbol.(paras_name[i])] = gdpmean_all
    gdpstd_all_means_plus[!, Symbol.(paras_name[i])] = gdpmean_all + gdpstd_all
    gdpstd_all_means_minus[!, Symbol.(paras_name[i])] = gdpmean_all - gdpstd_all
    # unemployment
    unempmean_all = vec(mean(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2))
    unempstd_all = vec(std(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2))
    unempmean_all_means[!, Symbol.(paras_name[i])] = unempmean_all
    unempstd_all_means_plus[!, Symbol.(paras_name[i])] = unempmean_all + unempstd_all
    unempstd_all_means_minus[!, Symbol.(paras_name[i])] = unempmean_all - unempstd_all
    # public account, adjusted
    pubh = (datat/(365*gdpmean[2]))*hcat((results -> results[:pubacctraj]).(worker_results)...)
    pubmean = vec(mean(pubh, dims=2))
    pubstd = vec(std(pubh, dims=2))
    pubaccmean_all_means[!, Symbol.(paras_name[i])] = pubmean
    pubaccmean_all_means_plus[!, Symbol.(paras_name[i])] = pubmean + pubstd
    pubaccmean_all_means_minus[!, Symbol.(paras_name[i])] = pubmean - pubstd
end

# GDP loss
pl2 =  @df gdploss_all_means boxplot(cols(),xticks=(1:ncol(gdploss_all_means), paras_name), legend=false, title = "Average GDP Loss")
ylims!(pl2,0,5)
savefig(pl2,"$(filename_prefix)gdp_loss.pdf")


# Casualites
pl3 =  @df totcas_all_means boxplot(cols(),xticks=(1:ncol(totcas_all_means), paras_name), legend=false, title = "Total Casualties")
ylims!(pl3,0,0.25)
savefig(pl3,"$(filename_prefix)casualties.pdf")
