using Statistics,Serialization,StatsPlots, DataFrames, HypothesisTests

filename_prefix = "../data/no_mutation_pinf125/"
filename_prefix_2 = "no_mutation_pinf125"


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
include("$(filename_prefix)beta_l50//covid_par_ini.jl")

### store data in txt file
io = open("stat_tests_results_$(filename_prefix_2).txt", "w")
println(io, "Statisitcal tests: p-values from Mann-Whitney U tests\n")

# POINT A, B, C in fig 2a
paras = ["beta_l5","beta_l50","beta_l50_alpha_o050","beta_l5_alpha_l050","beta_l5_alpha_l050_alpha_o050"]


### get point A
p=paras[1]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_1 = (results -> results[:togdploss]).(worker_results)
totcas_1 = (results -> results[:totcas]).(worker_results)

### get point B
p=paras[2]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_2 = (results -> results[:togdploss]).(worker_results)
totcas_2 = (results -> results[:totcas]).(worker_results)

### get point C
p=paras[3]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_3 = (results -> results[:togdploss]).(worker_results)
totcas_3 = (results -> results[:totcas]).(worker_results)


### get point D
p=paras[4]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_4 = (results -> results[:togdploss]).(worker_results)
totcas_4 = (results -> results[:totcas]).(worker_results)


### get point E
p=paras[5]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_5 = (results -> results[:togdploss]).(worker_results)
totcas_5 = (results -> results[:totcas]).(worker_results)

println(io,"\n TESTS FOR GDP LOSS \n")


HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_2)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_2))
println(io,"\n ", paras[1]," and ", paras[2] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_3)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_3))
println(io,"\n ", paras[1]," and ", paras[3] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_4))
println(io,"\n ", paras[1]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_1, gdploss_5))
println(io,"\n ", paras[1]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_3)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_3))
println(io,"\n ", paras[2]," and ", paras[3] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_4))
println(io,"\n ", paras[2]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_2, gdploss_5))
println(io,"\n ", paras[2]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_3, gdploss_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_3, gdploss_4))
println(io,"\n ", paras[3]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_3, gdploss_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_3, gdploss_5))
println(io,"\n ", paras[3]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(gdploss_4, gdploss_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_4, gdploss_5))
println(io,"\n ", paras[4]," and ", paras[5] ," pvalue ", p)

println(io,"\n \n TESTS FOR TOT CAS\n")

HypothesisTests.MannWhitneyUTest(totcas_1, totcas_2)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_1, totcas_2))
println(io,"\n ", paras[1]," and ", paras[2] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_1, totcas_3)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_1, totcas_3))
println(io,"\n ", paras[1]," and ", paras[3] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_1, totcas_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_1, totcas_4))
println(io,"\n ", paras[1]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_1, totcas_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_1, totcas_5))
println(io,"\n ", paras[1]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_2, totcas_3)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_2, totcas_3))
println(io,"\n ", paras[2]," and ", paras[3] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_2, totcas_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_2, totcas_4))
println(io,"\n ", paras[2]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_2, totcas_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_2, totcas_5))
println(io,"\n ", paras[2]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_3, totcas_4)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_3, totcas_4))
println(io,"\n ", paras[3]," and ", paras[4] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_3, totcas_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_3, totcas_5))
println(io,"\n ", paras[3]," and ", paras[5] ," pvalue ", p)

HypothesisTests.MannWhitneyUTest(totcas_4, totcas_5)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_4, totcas_5))
println(io,"\n ", paras[4]," and ", paras[5] ," pvalue ", p)



### close txt file
close(io)
