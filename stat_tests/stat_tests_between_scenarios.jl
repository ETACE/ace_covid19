using Statistics,Serialization,StatsPlots, DataFrames, HypothesisTests


filename_prefix_mutation = "../data/mutation/"
filename_prefix_125pinf = "../data/no_mutation_pinf125//"
filename_prefix_no_mutation = "../data/no_mutation/"


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
include("$(filename_prefix_mutation)beta_l5//covid_par_ini.jl")

### store data in txt file
io = open("stat_tests_results_btw_scenarios.txt", "w")
println(io, "Statisitcal tests: p-values from Mann-Whitney U tests\n")

# POINT A, B, C, D, E in Table 1
paras = ["beta_l50","beta_l5","beta_l5_alpha_l050", "beta_l5_alpha_l050_alpha_o050"]

################# with mutation
### get point A
p=paras[1]
data_prefix = string("$(filename_prefix_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_A_mut = (results -> results[:togdploss]).(worker_results)
totcas_A_mut = (results -> results[:totcas]).(worker_results)

### get point B
p=paras[2]
data_prefix = string("$(filename_prefix_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_B_mut = (results -> results[:togdploss]).(worker_results)
totcas_B_mut = (results -> results[:totcas]).(worker_results)

### get point C
p=paras[3]
data_prefix = string("$(filename_prefix_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_C_mut = (results -> results[:togdploss]).(worker_results)
totcas_C_mut = (results -> results[:totcas]).(worker_results)

### get point D
p=paras[4]
data_prefix = string("$(filename_prefix_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_D_mut = (results -> results[:togdploss]).(worker_results)
totcas_D_mut = (results -> results[:totcas]).(worker_results)


######### higher pinf 125
### get point A
p=paras[1]
data_prefix = string("$(filename_prefix_125pinf)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_A125 = (results -> results[:togdploss]).(worker_results)
totcas_A125 = (results -> results[:totcas]).(worker_results)

### get point B
p=paras[2]
data_prefix = string("$(filename_prefix_125pinf)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_B125 = (results -> results[:togdploss]).(worker_results)
totcas_B125 = (results -> results[:totcas]).(worker_results)

### get point C
p=paras[3]
data_prefix = string("$(filename_prefix_125pinf)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_C125 = (results -> results[:togdploss]).(worker_results)
totcas_C125 = (results -> results[:totcas]).(worker_results)

### get point D
p=paras[4]
data_prefix = string("$(filename_prefix_125pinf)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_D125 = (results -> results[:togdploss]).(worker_results)
totcas_D125 = (results -> results[:totcas]).(worker_results)


### no mutation
### get point A
p=paras[1]
data_prefix = string("$(filename_prefix_no_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_A = (results -> results[:togdploss]).(worker_results)
totcas_A = (results -> results[:totcas]).(worker_results)

### get point B
p=paras[2]
data_prefix = string("$(filename_prefix_no_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_B = (results -> results[:togdploss]).(worker_results)
totcas_B = (results -> results[:totcas]).(worker_results)

### get point C
p=paras[3]
data_prefix = string("$(filename_prefix_no_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_C = (results -> results[:togdploss]).(worker_results)
totcas_C = (results -> results[:totcas]).(worker_results)

### get point D
p=paras[4]
data_prefix = string("$(filename_prefix_no_mutation)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_D = (results -> results[:togdploss]).(worker_results)
totcas_D = (results -> results[:totcas]).(worker_results)

println(io,"\n MUTATION vs NO MUTATION\n")
println(io,"\n TESTS FOR GDP\n")

HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_A_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_A_mut))
println(io,"\n pvalue for GDP A vs A_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_B, gdploss_B_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_B, gdploss_B_mut))
println(io,"\n pvalue for GDP B vs B_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_C, gdploss_C_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_C, gdploss_C_mut))
println(io,"\n pvalue for GDP C vs C_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_D, gdploss_D_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_D, gdploss_D_mut))
println(io,"\n pvalue for GDP D vs D_mut: ", p)


println(io,"\n \n TESTS FOR TOT CAS Table 1\n")

HypothesisTests.MannWhitneyUTest(totcas_A, totcas_A_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_A, totcas_A_mut))
println(io,"\n pvalue for CAS A vs A_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_B, totcas_B_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_B, totcas_B_mut))
println(io,"\n pvalue for CAS B vs B_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_C, totcas_C_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_C, totcas_C_mut))
println(io,"\n pvalue for CAS C vs C_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_D, totcas_D_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_D, totcas_D_mut))
println(io,"\n pvalue for CAS D vs D_mut: ", p)



println(io,"\n \n RATIO GDP\n")

println(io,"\n ratio for GDP A vs A_mut: ", mean(gdploss_A_mut)/mean(gdploss_A))
println(io,"\n ratio for GDP B vs B_mut: ", mean(gdploss_B_mut)/mean(gdploss_B))
println(io,"\n ratio for GDP C vs C_mut: ", mean(gdploss_C_mut)/mean(gdploss_C))
println(io,"\n ratio for GDP D vs D_mut: ", mean(gdploss_D_mut)/mean(gdploss_D))

println(io,"\n \n RATIO CAS\n")

println(io,"\n ratio for CAS A vs A_mut: ", mean(totcas_A_mut)/mean(totcas_A))
println(io,"\n ratio for CAS B vs B_mut: ", mean(totcas_B_mut)/mean(totcas_B))
println(io,"\n ratio for CAS C vs C_mut: ", mean(totcas_C_mut)/mean(totcas_C))
println(io,"\n ratio for CAS D vs D_mut: ", mean(totcas_D_mut)/mean(totcas_D))


println(io,"\n \n DIFF GDP\n")

println(io,"\n ratio for GDP A vs A_mut: ", (mean(gdploss_A_mut) - mean(gdploss_A)))
println(io,"\n ratio for GDP B vs B_mut: ", (mean(gdploss_B_mut) - mean(gdploss_B)))
println(io,"\n ratio for GDP C vs C_mut: ", (mean(gdploss_C_mut) - mean(gdploss_C)))
println(io,"\n ratio for GDP D vs D_mut: ", (mean(gdploss_D_mut) - mean(gdploss_D)))

println(io,"\n \n DIFF CAS\n")

println(io,"\n ratio for CAS A vs A_mut: ", (mean(totcas_A_mut) - mean(totcas_A)))
println(io,"\n ratio for CAS B vs B_mut: ", (mean(totcas_B_mut) - mean(totcas_B)))
println(io,"\n ratio for CAS C vs C_mut: ", (mean(totcas_C_mut) - mean(totcas_C)))
println(io,"\n ratio for CAS D vs D_mut: ", (mean(totcas_D_mut) - mean(totcas_D)))


println(io,"\n MUTATION vs HIGHER PINF 125\n")
println(io,"\n TESTS FOR GDP\n")

HypothesisTests.MannWhitneyUTest(gdploss_A125, gdploss_A_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A125, gdploss_A_mut))
println(io,"\n pvalue for GDP A125 vs A_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_B125, gdploss_B_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_B125, gdploss_B_mut))
println(io,"\n pvalue for GDP B125 vs B_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_C125, gdploss_C_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_C125, gdploss_C_mut))
println(io,"\n pvalue for GDP C125 vs C_mut: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_D125, gdploss_D_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_D125, gdploss_D_mut))
println(io,"\n pvalue for GDP D125 vs D_mut: ", p)


println(io,"\n \n TESTS FOR TOT CAS Table 1\n")

HypothesisTests.MannWhitneyUTest(totcas_A125, totcas_A_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_A125, totcas_A_mut))
println(io,"\n pvalue for CAS A125 vs A_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_B125, totcas_B_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_B125, totcas_B_mut))
println(io,"\n pvalue for CAS B125 vs B_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_C125, totcas_C_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_C125, totcas_C_mut))
println(io,"\n pvalue for CAS C125 vs C_mut: ", p)

HypothesisTests.MannWhitneyUTest(totcas_D125, totcas_D_mut)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_D125, totcas_D_mut))
println(io,"\n pvalue for CAS D125 vs D_mut: ", p)



println(io,"\n \n RATIO GDP\n")

println(io,"\n ratio for GDP A125 vs A_mut: ", mean(gdploss_A_mut)/mean(gdploss_A125))
println(io,"\n ratio for GDP B125 vs B_mut: ", mean(gdploss_B_mut)/mean(gdploss_B125))
println(io,"\n ratio for GDP C125 vs C_mut: ", mean(gdploss_C_mut)/mean(gdploss_C125))
println(io,"\n ratio for GDP D125 vs D_mut: ", mean(gdploss_D_mut)/mean(gdploss_D125))

println(io,"\n \n RATIO CAS\n")

println(io,"\n ratio for CAS A125 vs A_mut: ", mean(totcas_A_mut)/mean(totcas_A125))
println(io,"\n ratio for CAS B125 vs B_mut: ", mean(totcas_B_mut)/mean(totcas_B125))
println(io,"\n ratio for CAS C125 vs C_mut: ", mean(totcas_C_mut)/mean(totcas_C125))
println(io,"\n ratio for CAS D125 vs D_mut: ", mean(totcas_D_mut)/mean(totcas_D125))


println(io,"\n \n DIFF GDP\n")

println(io,"\n ratio for GDP A125 vs A_mut: ", (mean(gdploss_A_mut) - mean(gdploss_A125)))
println(io,"\n ratio for GDP B125 vs B_mut: ", (mean(gdploss_B_mut) - mean(gdploss_B125)))
println(io,"\n ratio for GDP C125 vs C_mut: ", (mean(gdploss_C_mut) - mean(gdploss_C125)))
println(io,"\n ratio for GDP D125 vs D_mut: ", (mean(gdploss_D_mut) - mean(gdploss_D125)))

println(io,"\n \n DIFF CAS\n")

println(io,"\n ratio for CAS A125 vs A_mut: ", (mean(totcas_A_mut) - mean(totcas_A125)))
println(io,"\n ratio for CAS B125 vs B_mut: ", (mean(totcas_B_mut) - mean(totcas_B125)))
println(io,"\n ratio for CAS C125 vs C_mut: ", (mean(totcas_C_mut) - mean(totcas_C125)))
println(io,"\n ratio for CAS D125 vs D_mut: ", (mean(totcas_D_mut) - mean(totcas_D125)))



### close txt file
close(io)
