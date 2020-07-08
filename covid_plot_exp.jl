using Statistics,Serialization,StatsPlots
path_to_data = "data//baseline_GER//"
filename_prefix = "figures//"

include("$(path_to_data)covid_par_ini.jl")
worker_results = deserialize(open("$(path_to_data)batchdata.dat"))

datapoint = fld(T,datat)

gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
gdpstd = std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
nn = size(gdpmean)[1]
pl1 = plot(datat*collect(2:nn),[gdpmean[2:nn], gdpmean[2:nn].-gdpstd[2:nn],gdpmean[2:nn].+gdpstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["GDP" "" ""])
savefig(pl1,"$(filename_prefix)gdpdyn.pdf")

unempmean = mean(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2)
unempstd = std(hcat((results -> results[:unempltraj]).(worker_results)...), dims=2)
pl2 = plot(datat*collect(2:nn),[unempmean[2:nn], unempmean[2:nn].-unempstd[2:nn],unempmean[2:nn].+unempstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["unemp" "" ""])
savefig(pl2,"$(filename_prefix)unempdyn.pdf")

savmean = mean(cat((results -> results[:f_av_savings]).(worker_results)...,dims=3), dims=3)
savstd = std(cat((results -> results[:f_av_savings]).(worker_results)...,dims=3), dims=3)
pl4 = plot(datat*collect(2:nn),[savmean[2:nn,1], savmean[2:nn,1].-savstd[2:nn,1],savmean[2:nn,1].+savstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["man" "" ""])
plot!(datat*collect(2:nn),[savmean[2:nn,2], savmean[2:nn,2].-savstd[2:nn,2],savmean[2:nn,2].+savstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black], label = ["ser" "" ""])
plot!(datat*collect(2:nn),[savmean[2:nn,3], savmean[2:nn,3].-savstd[2:nn,3],savmean[2:nn,3].+savstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["food" "" ""])
savefig(pl4,"$(filename_prefix)savdyn.pdf")


RKIR0mean = mean(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
RKIR0std = std(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
nn1 = size(RKIR0mean)[1]
pl3 = plot(collect(1:nn1),[RKIR0mean, RKIR0mean.-RKIR0std,RKIR0mean.+RKIR0std], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
savefig(pl3,"$(filename_prefix)RKIR0dyn.pdf")

totinfmean = mean(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstd = std(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)
include("$(path_to_data)emp_traj_100k.jl")
nzer= (Int(ceil(virustime/datat))-1)*datat+2*corlatent
emptotinftraj = vcat(zeros(nzer),emptotinf)
nne = size(emptotinf)[1]
pl5 = plot(collect(1:nn1),[totinfmean, totinfmean.-totinfstd,totinfmean.+totinfstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totinf" "" ""])
plot!(emptotinftraj, linecolor = [:green], label="GER", linewidth = [2])
savefig(pl5,"$(filename_prefix)totinfdyn.pdf")

pl5a = plot(collect(1:nne),[totinfmean[nzer+1:nzer+nne], totinfmean[nzer+1:nzer+nne].-totinfstd[nzer+1:nzer+nne],totinfmean[nzer+1:nzer+nne].+totinfstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totinf" "" ""])
plot!(emptotinftraj[nzer+1:nzer+nne], linecolor = [:green], label="GER", linewidth = [2])
savefig(pl5a,"$(filename_prefix)totinfemp.pdf")

hcapfrac = zeros(datapoint+1)
for th = 1:datapoint+1
    hcapfrac[th] = hcap / (nhh * icufrac)
end
infmean = mean(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
infstd = std(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
pl6 = plot(datat*collect(2:nn),[infmean[2:nn,1], infmean[2:nn,1].-infstd[2:nn,1],infmean[2:nn,1].+infstd[2:nn,1],hcapfrac[2:nn]], linestyle = [:solid :dot :dot :solid], linewidth = [2 1 1 1], linecolor = [:blue :black :black :black],label = ["y" "" "" "cap"])
plot!(datat*collect(2:nn),[infmean[2:nn,2], infmean[2:nn,2].-infstd[2:nn,2],infmean[2:nn,2].+infstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[infmean[2:nn,3], infmean[2:nn,3].-infstd[2:nn,3],infmean[2:nn,3].+infstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black],label = ["tot" "" ""])
savefig(pl6,"$(filename_prefix)infdyn.pdf")

concountmean = mean(hcat((results -> results[:contact_count_traj]).(worker_results)...), dims=2)
concountstd = std(hcat((results -> results[:contact_count_traj]).(worker_results)...), dims=2)
nnhc = nn1 - size(concountmean)[1]
concountmean = vcat(zeros(nnhc),concountmean)
concountstd = vcat(zeros(nnhc),concountstd)
pl17 = plot(collect(1:nn1),[concountmean, concountmean.-concountstd,concountmean.+concountstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totcont" "" ""])
savefig(pl17,"$(filename_prefix)concountdyn.pdf")

totcasmean = mean(cat((results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
totcasstd = std(cat((results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
pl7 = plot(datat*collect(2:nn),[totcasmean[2:nn,1], totcasmean[2:nn,1].-totcasstd[2:nn,1],totcasmean[2:nn,1].+totcasstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["y" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,2], totcasmean[2:nn,2].-totcasstd[2:nn,2],totcasmean[2:nn,2].+totcasstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,3], totcasmean[2:nn,3].-totcasstd[2:nn,3],totcasmean[2:nn,3].+totcasstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["tot" "" ""])
savefig(pl7,"$(filename_prefix)casdyn.pdf")

pubh = (datat/(365*gdpmean[2]))*hcat((results -> results[:pubacctraj]).(worker_results)...)
pubmean = mean(pubh, dims=2)
pubstd = std(pubh, dims=2)
pl8 = plot(datat*collect(1:nn),[pubmean, pubmean.-pubstd,pubmean.+pubstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["pubacc" "" ""])
savefig(pl8,"$(filename_prefix)pubaccdyn.pdf")

inactmean = mean(hcat((results -> results[:inactivefirmstraj]).(worker_results)...), dims=2)
inactstd = std(hcat((results -> results[:inactivefirmstraj]).(worker_results)...), dims=2)
pl9 = plot(datat*collect(1:nn),[inactmean, inactmean.-inactstd,inactmean.+inactstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["inact firms" "" ""])
savefig(pl9,"$(filename_prefix)inactf.pdf")

gdplossmean = mean(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
gdplossstd = std(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
pl10 = plot(datat*collect(1:nn),[gdplossmean, gdplossmean.-gdplossstd,gdplossmean.+gdplossstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["gdp loss" "" ""])
savefig(pl10,"$(filename_prefix)gdplossdyn.pdf")

nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0sm)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)
pl16 = plot(collect(1:nn1),[RKIR0smmean, RKIR0smmean.-RKIR0smstd,RKIR0smmean.+RKIR0smstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
plot!(empR0smtraj, linecolor = [:green], label="GER", linewidth = [2])
savefig(pl16,"$(filename_prefix)RKIR0smdyn.pdf")

pl16a = plot(collect(1:nne),[RKIR0smmean[nzer+1:nzer+nne], RKIR0smmean[nzer+1:nzer+nne].-RKIR0smstd[nzer+1:nzer+nne],RKIR0smmean[nzer+1:nzer+nne].+RKIR0smstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
plot!(empR0smtraj[nzer+1:nzer+nne], linecolor = [:green], label="GER", linewidth = [2])
savefig(pl16a,"$(filename_prefix)RKIR0smemp.pdf")

bankmean = mean(cat((results -> results[:bankrupttraj]).(worker_results)...,dims=3), dims=3)
bankstd = std(cat((results -> results[:bankrupttraj]).(worker_results)...,dims=3), dims=3)
pl8 = plot(datat*collect(2:nn),[bankmean[2:nn,1], bankmean[2:nn,1].-bankstd[2:nn,1],bankmean[2:nn,1].+bankstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["man" "" ""])
plot!(datat*collect(2:nn),[bankmean[2:nn,2], bankmean[2:nn,2].-bankstd[2:nn,2],bankmean[2:nn,2].+bankstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black], label = ["ser" "" ""])
plot!(datat*collect(2:nn),[bankmean[2:nn,3], bankmean[2:nn,3].-bankstd[2:nn,3],bankmean[2:nn,3].+bankstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["food" "" ""])
savefig(pl8,"$(filename_prefix)bankruptdyn.pdf")

unempsecmean = mean(cat((results -> results[:unempsectraj]).(worker_results)...,dims=3), dims=3)
unempsecstd = std(cat((results -> results[:unempsectraj]).(worker_results)...,dims=3), dims=3)
pl22 = plot(datat*collect(2:nn),[unempsecmean[2:nn,1], unempsecmean[2:nn,1].-unempsecstd[2:nn,1],unempsecmean[2:nn,1].+unempsecstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["man" "" ""])
plot!(datat*collect(2:nn),[unempsecmean[2:nn,2], unempsecmean[2:nn,2].-unempsecstd[2:nn,2],unempsecmean[2:nn,2].+unempsecstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black], label = ["ser" "" ""])
plot!(datat*collect(2:nn),[unempsecmean[2:nn,3], unempsecmean[2:nn,3].-unempsecstd[2:nn,3],unempsecmean[2:nn,3].+unempsecstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["food" "" ""])
savefig(pl22,"$(filename_prefix)unempsecdyn.pdf")

gdplossh = (results -> results[:togdploss]).(worker_results)
totcash = (results -> results[:totcas]).(worker_results)
pubacch = (results -> results[:pubacctraj]).(worker_results)
pubacc = []
for i = 1:size(pubacch)[1]
    push!(pubacc,pubacch[i][datapoint+1]*datat/(365*gdpmean[2]))
end

pl19 =  boxplot(gdplossh, label = "Av. GDP Loss")
savefig(pl19,"$(filename_prefix)totgdploss.pdf")

pl20 =  boxplot(totcash, label = "Tot. Cas.")
savefig(pl20,"$(filename_prefix)totcas.pdf")

pl21 =  boxplot(pubacc, label = "Pub. Acc.")
savefig(pl21,"$(filename_prefix)pubacc.pdf")

polswcounth = (results -> results[:polswitchcount]).(worker_results)
badpoltimeh = (results -> results[:badpoltime]).(worker_results)

pl23 =  boxplot(polswcounth, label = "Pol. Sw.")
savefig(pl23,"$(filename_prefix)polswitch.pdf")

pl24 =  boxplot(badpoltimeh, label = "Restr.")
savefig(pl24,"$(filename_prefix)badpol.pdf")
