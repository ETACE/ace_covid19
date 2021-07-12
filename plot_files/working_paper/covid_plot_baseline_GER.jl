using Statistics,Serialization,StatsPlots
filename_prefix = "..//..//data//working_paper//baseline_GER//"
plotname_prefix = "..//..//figures//working_paper//baseline_GER_"
mkpath(plotname_prefix)

include("$(filename_prefix)covid_par_ini.jl")
worker_results = deserialize(open("$(filename_prefix)batchdata.dat"))

empirical_data = true # add green emipircal data lines
datapoint = fld(T,datat)

gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
gdpstd = std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
nn = size(gdpmean)[1]
pl1 = plot(datat*collect(2:nn),[gdpmean[2:nn], gdpmean[2:nn].-gdpstd[2:nn],gdpmean[2:nn].+gdpstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["GDP" "" ""])
savefig(pl1,"$(plotname_prefix)gdpdyn.pdf")

unempmean = mean(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2)
unempstd = std(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2)
pl2 = plot(datat*collect(2:nn),[unempmean[2:nn], unempmean[2:nn].-unempstd[2:nn],unempmean[2:nn].+unempstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["unemp" "" ""])
savefig(pl2,"$(plotname_prefix)unempdyn.pdf")


RKIR0mean = mean(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
RKIR0std = std(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
nn1 = size(RKIR0mean)[1]
pl3 = plot(collect(1:nn1),[RKIR0mean, RKIR0mean.-RKIR0std,RKIR0mean.+RKIR0std], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
savefig(pl3,"$(plotname_prefix)RKIR0dyn.pdf")

totinfmean = mean(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstd = std(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)

nzer= (Int(ceil(virustime/datat))-1)*datat+2*corlatent
pl5 = plot(collect(1:nn1),[totinfmean, totinfmean.-totinfstd,totinfmean.+totinfstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totinf" "" ""])
savefig(pl5,"$(plotname_prefix)totinfdyn.pdf")

# scale here to reported numbers
totinfmeansc = mean(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstdsc = std(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
nne = 61
pl5a = plot(collect(1:nne),[totinfmeansc[nzer+1:nzer+nne], totinfmeansc[nzer+1:nzer+nne].-totinfstdsc[nzer+1:nzer+nne],totinfmeansc[nzer+1:nzer+nne].+totinfstdsc[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel="Day", ylabel = "Reported tot. inf.")
ylims!(pl5a,0,260)
if empirical_data
    include("$(filename_prefix)emp_traj_100k.jl")
    emptotinftraj = vcat(zeros(nzer),emptotinf)
    nne = size(emptotinf)[1]
    plot!(detfrac*emptotinftraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
end
savefig(pl5a,"$(plotname_prefix)fig_1a_totinfemp.pdf")


hcapfrac = zeros(datapoint+1)
for th = 1:datapoint+1
    hcapfrac[th] = hcap / (nhh * icufrac)
end
infmean = mean(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
infstd = std(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
pl6 = plot(datat*collect(2:nn),[infmean[2:nn,1], infmean[2:nn,1].-infstd[2:nn,1],infmean[2:nn,1].+infstd[2:nn,1],hcapfrac[2:nn]], linestyle = [:solid :dot :dot :solid], linewidth = [2 1 1 1], linecolor = [:blue :black :black :black],label = ["y" "" "" "cap"])
plot!(datat*collect(2:nn),[infmean[2:nn,2], infmean[2:nn,2].-infstd[2:nn,2],infmean[2:nn,2].+infstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[infmean[2:nn,3], infmean[2:nn,3].-infstd[2:nn,3],infmean[2:nn,3].+infstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black],label = ["tot" "" ""])
savefig(pl6,"$(plotname_prefix)infdyn.pdf")


totcasmean = mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
totcasstd = std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
pl7 = plot(datat*collect(2:nn),[totcasmean[2:nn,1], totcasmean[2:nn,1].-totcasstd[2:nn,1],totcasmean[2:nn,1].+totcasstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["y" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,2], totcasmean[2:nn,2].-totcasstd[2:nn,2],totcasmean[2:nn,2].+totcasstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,3], totcasmean[2:nn,3].-totcasstd[2:nn,3],totcasmean[2:nn,3].+totcasstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["tot" "" ""])
savefig(pl7,"$(plotname_prefix)casdyn.pdf")

nzer= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
nne = 9
pl7a = plot(datat*collect(1:nne),[totcasmean[nzer+1:nzer+nne,3], totcasmean[nzer+1:nzer+nne,3].-totcasstd[nzer+1:nzer+nne,3],totcasmean[nzer+1:nzer+nne,3].+totcasstd[nzer+1:nzer+nne,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], legend = false)
if empirical_data
    include("$(filename_prefix)emp_traj_100k.jl")
    empcastraj = vcat(zeros(datat*nzer),empcas)
    nne = Int(ceil(size(empcas)[1]/datat))
    plot!(empcastraj[datat*nzer+1:size(empcastraj)[1]], linecolor = [:green], linewidth = [2], legend = false, xlabel = "Day", ylabel = "Casualties [%]")
end
ylims!(pl7a,0,0.012)
savefig(pl7a,"$(plotname_prefix)fig_1c_casemp.pdf")


pubh = (datat/(365*gdpmean[2]))*hcat((results -> results[:pubacctraj]).(worker_results)...)
pubmean = mean(pubh, dims=2)
pubstd = std(pubh, dims=2)
pl8 = plot(datat*collect(1:nn),[pubmean, pubmean.-pubstd,pubmean.+pubstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["pubacc" "" ""])
savefig(pl8,"$(plotname_prefix)pubaccdyn.pdf")




gdplossmean = mean(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
gdplossstd = std(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
pl10 = plot(datat*collect(1:nn),[gdplossmean, gdplossmean.-gdplossstd,gdplossmean.+gdplossstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["gdp loss" "" ""])
savefig(pl10,"$(plotname_prefix)gdplossdyn.pdf")


nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)
pl16 = plot(collect(1:nn1),[RKIR0smmean, RKIR0smmean.-RKIR0smstd,RKIR0smmean.+RKIR0smstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
if empirical_data
    empR0smtraj = vcat(zeros(nzer),empR0sm)
    nne = size(empR0sm)[1]
    plot!(empR0smtraj, linecolor = [:green], label="GER", linewidth = [2])
end
savefig(pl16,"$(plotname_prefix)RKIR0smdyn.pdf")

if empirical_data
    pl16a = plot(collect(1:nne),[RKIR0smmean[nzer+1:nzer+nne], RKIR0smmean[nzer+1:nzer+nne].-RKIR0smstd[nzer+1:nzer+nne],RKIR0smmean[nzer+1:nzer+nne].+RKIR0smstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel = "Day", ylabel = "R0")
    for i = 1:7
        empR0smtraj[nzer+i] = 1/0
        RKIR0smmean[nzer+i] = 1/0
    end
    plot!(empR0smtraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
    ylims!(pl16a,0,3.75)
    savefig(pl16a,"$(plotname_prefix)fig_1b_RKIR0smemp.pdf")
end



shorttimemean = mean(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)
shorttimestd = std(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)
pl26 = plot(datat*collect(1:nn),[shorttimemean, shorttimemean.-shorttimestd,shorttimemean.+shorttimestd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["shorttime" "" ""])
savefig(pl26,"$(plotname_prefix)shorttime.pdf")

if empirical_data
    nnew = Int(ceil(nne/datat))
    nzerw = Int(ceil(nzer/datat))
    pl26a = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "Day", ylabel = "Short time [%]")
    scatter!(pl26a, [49], [0.22696629213], markersize = 10, markercolor = [:green], label = false)
    scatter!(pl26a, [21], [0.05842696629], markersize = 10, markercolor = [:green], label = false)
    savefig(pl26a,"$(plotname_prefix)fig_1d_shorttimeemp.pdf")
end

bankmean = mean(cat((results -> results[:bankrupttraj]).(worker_results)...,dims=3), dims=3)
bankstd = std(cat((results -> results[:bankrupttraj]).(worker_results)...,dims=3), dims=3)
pl8 = plot(datat*collect(2:nn),[bankmean[2:nn,1], bankmean[2:nn,1].-bankstd[2:nn,1],bankmean[2:nn,1].+bankstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["man" "" ""])
plot!(datat*collect(2:nn),[bankmean[2:nn,2], bankmean[2:nn,2].-bankstd[2:nn,2],bankmean[2:nn,2].+bankstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black], label = ["ser" "" ""])
plot!(datat*collect(2:nn),[bankmean[2:nn,3], bankmean[2:nn,3].-bankstd[2:nn,3],bankmean[2:nn,3].+bankstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["food" "" ""])
savefig(pl8,"$(plotname_prefix)bankruptdyn.pdf")

unempsecmean = mean(cat((results -> results[:unempsectraj]).(worker_results)...,dims=3), dims=3)
unempsecstd = std(cat((results -> results[:unempsectraj]).(worker_results)...,dims=3), dims=3)
pl22 = plot(datat*collect(2:nn),[unempsecmean[2:nn,1], unempsecmean[2:nn,1].-unempsecstd[2:nn,1],unempsecmean[2:nn,1].+unempsecstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["man" "" ""])
plot!(datat*collect(2:nn),[unempsecmean[2:nn,2], unempsecmean[2:nn,2].-unempsecstd[2:nn,2],unempsecmean[2:nn,2].+unempsecstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black], label = ["ser" "" ""])
plot!(datat*collect(2:nn),[unempsecmean[2:nn,3], unempsecmean[2:nn,3].-unempsecstd[2:nn,3],unempsecmean[2:nn,3].+unempsecstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["food" "" ""])
savefig(pl22,"$(plotname_prefix)unempsecdyn.pdf")

R0countmean = mean(hcat((results -> results[:R0counttraj]).(worker_results)...), dims=2)
R0countstd = std(hcat((results -> results[:R0counttraj]).(worker_results)...), dims=2)
pl23 = plot(datat*collect(2:nn),[R0countmean[2:nn], R0countmean[2:nn].-R0countstd[2:nn],R0countmean[2:nn].+R0countstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["R0" "" ""])
savefig(pl23,"$(plotname_prefix)R0countdyn.pdf")
