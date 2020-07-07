using Statistics,Serialization,StatsPlots, DataFrames, HypothesisTests


filename_prefix = "..//data//main//xi06//"


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

### store data in txt file
io = open("stat_tests_results.txt", "w")
println(io, "Statisitcal tests: p-values from Mann-Whitney U tests\n")

# POINT A, B, C in fig 2a
paras = ["beta5//alpha1","beta5//alpha25","beta30//alpha1"]


### get point A
p=paras[1]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_A = (results -> results[:togdploss]).(worker_results)
totcas_A = (results -> results[:totcas]).(worker_results)

### get point B
p=paras[2]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_B = (results -> results[:togdploss]).(worker_results)
totcas_B = (results -> results[:totcas]).(worker_results)

### get point C
p=paras[3]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_C = (results -> results[:togdploss]).(worker_results)
totcas_C = (results -> results[:totcas]).(worker_results)


println(io,"\n TESTS FOR FIGURE 2\n")

println(io,"\n TESTS FOR GDP FIGURE 2a\n")

HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_B)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_B))
println(io,"\n pvalue for GDP A1 vs B1: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_C)
p= pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_C))
println(io,"\n pvalue for GDP A1 vs C1: ", p)



println(io,"\n \n TESTS FOR TOT CAS FIGURE 2a\n")

HypothesisTests.MannWhitneyUTest(totcas_A, totcas_B)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_A, totcas_B))
println(io,"\n pvalue for CAS A1 vs B1: ", p)

HypothesisTests.MannWhitneyUTest(totcas_A, totcas_C)
p= pvalue(HypothesisTests.MannWhitneyUTest(totcas_A, totcas_C))
println(io,"\n pvalue for CAS A1 vs C1: ", p)



### include points from xi05
filename_prefix = "..//data//main//xi05//"
# POINT A, B, C in fig 2a
paras2 = ["beta5//alpha1","beta5//alpha25","beta30//alpha1"]


### get point A
p=paras2[1]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_A2 = (results -> results[:togdploss]).(worker_results)
totcas_A2 = (results -> results[:totcas]).(worker_results)

### get point B
p=paras2[2]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_B2 = (results -> results[:togdploss]).(worker_results)
totcas_B2 = (results -> results[:totcas]).(worker_results)

### get point C
p=paras2[3]
data_prefix = string("$(filename_prefix)", p , "//")
worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
gdploss_C2 = (results -> results[:togdploss]).(worker_results)
totcas_C2 = (results -> results[:totcas]).(worker_results)


### btw xi05 points

println(io,"\n \n TESTS FOR GDP FIGURE 2b\n")

HypothesisTests.MannWhitneyUTest(gdploss_A2, gdploss_B2)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A2, gdploss_B2))
println(io,"\n pvalue for GDP A2 vs B2: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_A2, gdploss_C2)
p= pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A2, gdploss_C2))
println(io,"\n pvalue for GDP A2 vs C2: ", p)




println(io,"\n \n TESTS FOR TOT CAS FIGURE 2b\n")

HypothesisTests.MannWhitneyUTest(totcas_A2, totcas_B2)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_A2, totcas_B2))
println(io,"\n pvalue for CAS A2 vs B2: ", p)

HypothesisTests.MannWhitneyUTest(totcas_A2, totcas_C2)
p= pvalue(HypothesisTests.MannWhitneyUTest(totcas_A2, totcas_C2))
println(io,"\n pvalue for CAS A2 vs C2: ", p)



### compare btw xi05 and default

println(io,"\n \n TESTS btw xi06 (Fig 2a) and xi05 (Fig 2b)\n")

HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_A2)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_A, gdploss_A2))
println(io,"\n pvalue for GDP A1 vs A2: ", p)

HypothesisTests.MannWhitneyUTest(totcas_A, totcas_A2)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_A, totcas_A2))
println(io,"\n pvalue for CAS A1 vs A2: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_B, gdploss_B2)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_B, gdploss_B2))
println(io,"\n pvalue for GDP B1 vs B2: ", p)

HypothesisTests.MannWhitneyUTest(totcas_B, totcas_B2)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_B, totcas_B2))
println(io,"\n pvalue for CAS B1 vs B2: ", p)

HypothesisTests.MannWhitneyUTest(gdploss_C, gdploss_C2)
p = pvalue(HypothesisTests.MannWhitneyUTest(gdploss_C, gdploss_C2))
println(io,"\n pvalue for GDP C1 vs C2: ", p)

HypothesisTests.MannWhitneyUTest(totcas_C, totcas_C2)
p = pvalue(HypothesisTests.MannWhitneyUTest(totcas_C, totcas_C2))
println(io,"\n pvalue for CAS C1 vs C2: ", p)


### between different starting weeks

filename_prefix = "..//data//adap_start//"

paras3 = ["week1","week2","week3","week4"]

include("$(filename_prefix)//week1/covid_par_ini.jl") # necessary for some basic parameter values (nhh)



gdploss_all_means = DataFrame()
totcas_all_means = DataFrame()
pubacc_all_means = DataFrame()
badpoltime_all_means = DataFrame()
polsw_all_means = DataFrame()

for (i,p) in enumerate(paras3)
    data_prefix = string("$(filename_prefix)", p , "//")
    if p == "week2"
        data_prefix = string("..//data//main//xi06//beta5//alpha1//")
    end
    # store data scatterplot
    worker_results = deserialize(open("$(data_prefix)batchdata.dat"))
    gdploss_all = (results -> results[:togdploss]).(worker_results)
    totcas_all = 100*(results -> results[:totcas]).(worker_results)
    gdploss_all_means[Symbol.(paras3[i])] = gdploss_all
    totcas_all_means[Symbol.(paras3[i])] = totcas_all
end


println(io,"\n \n TEST BETWEEN DIFFERENT STARTING WEEKS\n")


println(io,"\n TESTS FOR GDP\n ")
week1 = gdploss_all_means[1]
week2 = gdploss_all_means[2]
week3 = gdploss_all_means[3]
week4 = gdploss_all_means[4]

HypothesisTests.MannWhitneyUTest(week1, week2)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week2))
println(io,"\n pvalue for week 1 vs 2: ", p)

HypothesisTests.MannWhitneyUTest(week1, week3)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week3))
println(io,"\n pvalue for week 1 vs 3: ", p)

HypothesisTests.MannWhitneyUTest(week1, week4)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week4))
println(io,"\n pvalue for week 1 vs 4: ", p)


println(io,"\n \n TESTS FOR TOT CAS\n")

week1 = totcas_all_means[1]
week2 = totcas_all_means[2]
week3 = totcas_all_means[3]
week4 = totcas_all_means[4]

HypothesisTests.MannWhitneyUTest(week1, week2)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week2))
println(io,"\n pvalue for week 1 vs 2: ", p)

HypothesisTests.MannWhitneyUTest(week1, week3)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week3))
println(io,"\n pvalue for week 1 vs 3: ", p)

HypothesisTests.MannWhitneyUTest(week1, week4)
p = pvalue(HypothesisTests.MannWhitneyUTest(week1, week4))
println(io,"\n pvalue for week 1 vs 4: ", p)



### close txt file
close(io)
