using Statistics,Serialization,StatsPlots

experiment = ARGS[1] #e.g. "baseline_GER"
path_to_data = "data/$experiment/"
filename_prefix = "figures/$experiment/"

mkpath(filename_prefix)

include("$(path_to_data)covid_par_ini.jl")
worker_results = deserialize(open("$(path_to_data)batchdata.dat"))

datapoint = fld(T,datat)

empn = 200 # number of periods for empirical plots

gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
gdpstd = std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
gdpall = hcat((results -> results[:gdppercaptraj]).(worker_results)...)
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
include("emp_traj.jl")
fac = nhh/50000
nzer= (Int(ceil(virustime/datat))-1)*datat+2*corlatent
emptotinftraj = vcat(zeros(nzer),fac*emptotinf)
nne = size(emptotinf)[1]
pl5 = plot(collect(1:nn1),[totinfmean, totinfmean.-totinfstd,totinfmean.+totinfstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totinf" "" ""])
plot!(emptotinftraj, linecolor = [:green], label="GER", linewidth = [2])
savefig(pl5,"$(filename_prefix)totinfdyn.pdf")

#scale here to reported numbers
totinfmeansc = mean(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstdsc = std(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
pl5a = plot(collect(1:nne),[totinfmeansc[nzer+1:nzer+nne], totinfmeansc[nzer+1:nzer+nne].-totinfstdsc[nzer+1:nzer+nne],totinfmeansc[nzer+1:nzer+nne].+totinfstdsc[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel="days", ylabel = "reported tot. inf.")
plot!(detfrac*emptotinftraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
savefig(pl5a,"$(filename_prefix)totinfemp.pdf")

emptotinftraj = vcat(zeros(nzer),fac*emptotinfnew)
nnen = size(emptotinfnew)[1]
nnen = empn
totinfmeansc = mean(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstdsc = std(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
pl5b = plot(collect(1:nnen),[totinfmeansc[nzer+1:nzer+nnen], totinfmeansc[nzer+1:nzer+nnen].-totinfstdsc[nzer+1:nzer+nnen],totinfmeansc[nzer+1:nzer+nnen].+totinfstdsc[nzer+1:nzer+nnen]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel="days", ylabel = "reported tot. inf.")

plot!(pl5b, detfrac*emptotinftraj[nzer+1:nzer+nnen], linecolor = [:green], label=false, linewidth = [2])
savefig(pl5b,"$(filename_prefix)totinfempnew.pdf")

totinfvec = 100000/nhh*hcat((results -> results[:totinftraj]).(worker_results)...)

pl5c = plot(collect(1:nnen), detfrac*totinfvec[:,1][nzer+1:nzer+nnen], linecolor = [:grey], label=false, linewidth = [0.5])
for i in 2:length(totinfvec[1,:])
    plot!(pl5c, detfrac*totinfvec[:,i][nzer+1:nzer+nnen], linecolor = [:grey], label=false, linewidth = [0.5])
end

plot!(pl5c,[totinfmeansc[nzer+1:nzer+nnen], totinfmeansc[nzer+1:nzer+nnen].-totinfstdsc[nzer+1:nzer+nnen],totinfmeansc[nzer+1:nzer+nnen].+totinfstdsc[nzer+1:nzer+nnen]], linestyle= [:solid :dot :dot], linewidth = [2 2 2], linecolor = [:blue :black :black],label = false, xlabel="days", ylabel = "reported tot. inf.")
plot!(pl5c, detfrac*emptotinftraj[nzer+1:nzer+nnen], linecolor = [:green], label=false, linewidth = [2])
savefig(pl5c,"$(filename_prefix)totinfempnew_single.pdf")

hcapfrac = zeros(datapoint+1)
for th = 1:datapoint+1
    hcapfrac[th] = hcap / (nhh * icufrac)
end
infmean = mean(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
infstd = std(cat((results -> results[:inftraj]).(worker_results)...,dims=3), dims=3)
infall = cat((results -> results[:inftraj]).(worker_results)...,dims=3)
pl6 = plot(datat*collect(2:nn),[infmean[2:nn,1], infmean[2:nn,1].-infstd[2:nn,1],infmean[2:nn,1].+infstd[2:nn,1],hcapfrac[2:nn]], linestyle = [:solid :dot :dot :solid], linewidth = [2 1 1 1], linecolor = [:blue :black :black :black],label = ["y" "" "" "cap"])
plot!(datat*collect(2:nn),[infmean[2:nn,2], infmean[2:nn,2].-infstd[2:nn,2],infmean[2:nn,2].+infstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[infmean[2:nn,3], infmean[2:nn,3].-infstd[2:nn,3],infmean[2:nn,3].+infstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black],label = ["tot" "" ""])
savefig(pl6,"$(filename_prefix)infdyn.pdf")

inf = cat((results -> results[:inftraj]).(worker_results)...,dims=3)
inf_total = inf[:,3,:] .*nhh
inf_young = inf[:,1,:] .*nhhy
inf_old = inf[:,2,:] .*nhho
# (inf_old .+ inf_young) - inf_total
#inf_old  = accumulate(+,inf_old, dims = 1)
#inf_young  = accumulate(+,inf_young, dims = 1)
#inf_total  = accumulate(+,inf_total, dims = 1)
inf_old_perc = inf_old ./ inf_total
inf_old_mean = mean(inf_old_perc, dims=2)
inf_old_std = std(inf_old_perc, dims=2)
inf_young_perc = inf_young ./ inf_total
inf_young_mean = mean(inf_young_perc, dims=2)
inf_young_std = std(inf_young_perc, dims=2)
pl6y = plot(datat*collect(2:nn),[inf_old_mean[2:nn,1], inf_old_mean[2:nn,1].-inf_old_std[2:nn,1],inf_old_mean[2:nn,1].+inf_old_std[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["old perc" "" ""])
#plot!(pl6y, datat*collect(2:nn),[inf_young_mean[2:nn,1], inf_young_mean[2:nn,1].-inf_young_std[2:nn,1],inf_young_mean[2:nn,1].+inf_young_std[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["young perc" "" ""])
savefig(pl6y,"$(filename_prefix)totinf_old_perc.pdf")

pl6x = plot(datat*collect(2:nn),[inf_young_mean[2:nn,1], inf_young_mean[2:nn,1].-inf_young_std[2:nn,1],inf_young_mean[2:nn,1].+inf_young_std[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["young perc" "" ""])
savefig(pl6x,"$(filename_prefix)totinf_young_perc.pdf")

inf_old_mean = mean(inf_old, dims=2)
inf_old_std = std(inf_old, dims=2)
inf_young_mean = mean(inf_young, dims=2)
inf_young_std = std(inf_young, dims=2)
pl6 =  plot(datat*collect(2:nn),[inf_old_mean[2:nn,1], inf_old_mean[2:nn,1].-inf_old_std[2:nn,1],inf_old_mean[2:nn,1].+inf_old_std[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["old" "" ""])
plot!(pl6, datat*collect(2:nn),[inf_young_mean[2:nn,1], inf_young_mean[2:nn,1].-inf_young_std[2:nn,1],inf_young_mean[2:nn,1].+inf_young_std[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["young" "" ""])
savefig(pl6,"$(filename_prefix)totinf_oy.pdf")


concountmean = mean(hcat((results -> results[:contact_count_traj]).(worker_results)...), dims=2)
concountstd = std(hcat((results -> results[:contact_count_traj]).(worker_results)...), dims=2)
nnhc = nn1 - size(concountmean)[1]
concountmean = vcat(zeros(nnhc),concountmean)
concountstd = vcat(zeros(nnhc),concountstd)
pl17 = plot(collect(1:nn1),[concountmean, concountmean.-concountstd,concountmean.+concountstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["totcont" "" ""])
savefig(pl17,"$(filename_prefix)concountdyn.pdf")

totcasmean = mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
totcasstd = std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
pl7 = plot(datat*collect(2:nn),[totcasmean[2:nn,1], totcasmean[2:nn,1].-totcasstd[2:nn,1],totcasmean[2:nn,1].+totcasstd[2:nn,1]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label = ["y" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,2], totcasmean[2:nn,2].-totcasstd[2:nn,2],totcasmean[2:nn,2].+totcasstd[2:nn,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(2:nn),[totcasmean[2:nn,3], totcasmean[2:nn,3].-totcasstd[2:nn,3],totcasmean[2:nn,3].+totcasstd[2:nn,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black], label = ["tot" "" ""])
savefig(pl7,"$(filename_prefix)casdyn.pdf")

nzer= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
empcastraj = vcat(zeros(datat*nzer),fac*empcas)
nne = Int(ceil(size(empcas)[1]/datat))
pl7a = plot(datat*collect(1:nne),[totcasmean[nzer+1:nzer+nne,3], totcasmean[nzer+1:nzer+nne,3].-totcasstd[nzer+1:nzer+nne,3],totcasmean[nzer+1:nzer+nne,3].+totcasstd[nzer+1:nzer+nne,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black] )
plot!(empcastraj[datat*nzer+1:size(empcastraj)[1]], linecolor = [:green], linewidth = [2], legend = false, xlabel = "days", ylabel = "casualties [%]")
savefig(pl7a,"$(filename_prefix)casemp.pdf")

nzer= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
empcastraj = vcat(zeros(datat*nzer),fac*empcasnew)
nne = Int(ceil(size(empcasnew)[1]/datat))
nne = Int(ceil(empn / datat))
pl7b = plot(datat*collect(1:nne),[totcasmean[nzer+1:nzer+nne,3], totcasmean[nzer+1:nzer+nne,3].-totcasstd[nzer+1:nzer+nne,3],totcasmean[nzer+1:nzer+nne,3].+totcasstd[nzer+1:nzer+nne,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black] )
plot!(pl7b, empcastraj[datat*nzer+1:empn+datat*nzer], linecolor = [:green], linewidth = [2], legend = false, xlabel = "days", ylabel = "casualties [%]")
savefig(pl7b,"$(filename_prefix)casempnew.pdf")


pubh = (datat/(365*gdpmean[2]))*hcat((results -> results[:pubacctraj]).(worker_results)...)
pubmean = mean(pubh, dims=2)
pubstd = std(pubh, dims=2)
pl8 = plot(datat*collect(1:nn),[pubmean, pubmean.-pubstd,pubmean.+pubstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["pubacc" "" ""])
savefig(pl8,"$(filename_prefix)pubaccdyn.pdf")

inactmean = mean(hcat((results -> results[:inactivefirmstraj]).(worker_results)...), dims=2)
inactstd = std(hcat((results -> results[:inactivefirmstraj]).(worker_results)...), dims=2)
pl9 = plot(datat*collect(1:nn),[inactmean, inactmean.-inactstd,inactmean.+inactstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["inact firms" "" ""])
savefig(pl9,"$(filename_prefix)inactf.pdf")

totfirmmean = mean(hcat((results -> results[:totfirmtraj]).(worker_results)...), dims=2)
totfirmstd = std(hcat((results -> results[:totfirmtraj]).(worker_results)...), dims=2)
pl9a = plot(datat*collect(1:nn),[totfirmmean, totfirmmean.-totfirmstd,totfirmmean.+totfirmstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["tot. firms" "" ""])
savefig(pl9a,"$(filename_prefix)totfirmdyn.pdf")

gdplossmean = mean(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
gdplossstd = std(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
pl10 = plot(datat*collect(1:nn),[gdplossmean, gdplossmean.-gdplossstd,gdplossmean.+gdplossstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["gdp loss" "" ""])
savefig(pl10,"$(filename_prefix)gdplossdyn.pdf")

tautrajmean = mean(hcat((results -> results[:tautraj]).(worker_results)...), dims=2)
tautrajstd = std(hcat((results -> results[:tautraj]).(worker_results)...), dims=2)
pl25 = plot(datat*collect(1:nn),[tautrajmean, tautrajmean.-tautrajstd,tautrajmean.+tautrajstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["gdp loss" "" ""])
savefig(pl25,"$(filename_prefix)taudyn.pdf")

#pl10 = plot(datat*collect(1:nn),[gdplossmean, gdplossmean.-gdplossstd,gdplossmean.+gdplossstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["gdp loss" "" ""])
#savefig(pl10,"$(filename_prefix)gdplossdynemp.pdf")

nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0sm)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
nne = size(empR0sm)[1]
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)
pl16 = plot(collect(1:nn1),[RKIR0smmean, RKIR0smmean.-RKIR0smstd,RKIR0smmean.+RKIR0smstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["RKIR0" "" ""])
plot!(empR0smtraj, linecolor = [:green], label="GER", linewidth = [2])
savefig(pl16,"$(filename_prefix)RKIR0smdyn.pdf")
for i=1:7
    RKIR0smmean[nzer+i] = 1/0
    empR0smtraj[nzer+i] = 1/0
end

pl16a = plot(collect(1:nne),[RKIR0smmean[nzer+1:nzer+nne], RKIR0smmean[nzer+1:nzer+nne].-RKIR0smstd[nzer+1:nzer+nne],RKIR0smmean[nzer+1:nzer+nne].+RKIR0smstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel = "days", ylabel = "R0")
plot!(empR0smtraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
savefig(pl16a,"$(filename_prefix)RKIR0smemp.pdf")


nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0new)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
nne = size(empR0new)[1]
nne = empn
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)
for i=1:7
    RKIR0smmean[nzer+i] = 1/0
    empR0smtraj[nzer+i] = 1/0
end

for i in 1:length(RKIR0smmean)
    if RKIR0smmean[i] == Inf
        RKIR0smmean[i] = RKIR0smmean[i-1]
        RKIR0smstd[i] = 0.0
    end
end
for i=1:7
    RKIR0smmean[nzer+i] = 1/0
    empR0smtraj[nzer+i] = 1/0
end
pl16a = plot(collect(1:nne),[RKIR0smmean[nzer+1:nzer+nne], RKIR0smmean[nzer+1:nzer+nne].-RKIR0smstd[nzer+1:nzer+nne],RKIR0smmean[nzer+1:nzer+nne].+RKIR0smstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel = "days", ylabel = "R0")
plot!(empR0smtraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
savefig(pl16a,"$(filename_prefix)RKIR0smemp_new.pdf")

### exclude Inf values
RKIR0s = hcat((results -> results[:RKIR0smtraj]).(worker_results)...)
x = 0
for i in 1:length(RKIR0s)
    if RKIR0s[i] == Inf
        RKIR0s[i] = NaN
        global x = i
    end
end

nanmean1(x) = mean(filter(!isnan,x))
nanstd1(x) = std(filter(!isnan,x))

RKIR0smmean= []
RKIR0smstd= []
for i in 1:length(RKIR0s[:,1])
    RKIR0s_row = RKIR0s[i,:]
    push!(RKIR0smmean,nanmean1(RKIR0s_row))
    push!(RKIR0smstd,nanstd1(RKIR0s_row))
end
nnhc = nn1 - size(RKIR0smmean)[1]
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)
pl16b = plot(collect(1:nne),[RKIR0smmean[nzer+1:nzer+nne], RKIR0smmean[nzer+1:nzer+nne].-RKIR0smstd[nzer+1:nzer+nne],RKIR0smmean[nzer+1:nzer+nne].+RKIR0smstd[nzer+1:nzer+nne]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel = "days", ylabel = "R0")
plot!(pl16b, empR0smtraj[nzer+1:nzer+nne], linecolor = [:green], label=false, linewidth = [2])
savefig(pl16b,"$(filename_prefix)RKIR0smemp_new_2.pdf")

# incidence per 100K

nwork = length(totinfvec[1,:])
inzmean = []
inzstd = []
inzall = zeros(length(totinfvec[:,1]),nwork)
for i =1:7
    push!(inzmean,0)
    push!(inzstd,0)
end
for i in 1:length(totinfvec[:,1])-7
    inzall[i+7,:] = detfrac*(totinfvec[i+7,:].-totinfvec[i,:])
    push!(inzmean,mean(detfrac*(totinfvec[i+7,:].-totinfvec[i,:])))
    push!(inzstd,std(detfrac*(totinfvec[i+7,:].-totinfvec[i,:])))
end
pl16c = plot(collect(1:length(totinfvec[:,1])),[inzmean, inzmean.-inzstd,inzmean.+inzstd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel = "days", ylabel = "Inc")
savefig(pl16c,"$(filename_prefix)incidence.pdf")

shorttimemean = mean(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)
shorttimestd = std(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)

pl26 = plot(datat*collect(1:nn),[shorttimemean, shorttimemean.-shorttimestd,shorttimemean.+shorttimestd], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = "shorttime")
savefig(pl26,"$(filename_prefix)shorttime.pdf")


nzerw= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
nnew = Int(ceil(size(empcasnew)[1]/datat))
nnew = Int(ceil(empn/datat))
#nnew = Int(ceil(nne/datat))
#nzerw = Int(ceil(nzer/datat))
pl26a = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# angezeigt kurzarbeit
scatter!(pl26a, [21], [0.05842696629], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [51], [0.236888889], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [83], [0.203555556], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [112], [0.033933333], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [143], [0.014244444], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [171], [0.009733333], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26a, [201], [0.005977778], markersize = 5, markercolor = [:green], label = false)

savefig(pl26a,"$(filename_prefix)shorttimeemp_angezeigte_kurzarbeit.pdf")


pl26b = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# tatsächlich ausgezahlte kurzarbeit with workforce 45 mio
scatter!(pl26b, [23], [0.057333333], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [51], [0.132222222], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [83], [0.131555556], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [114], [0.102888889], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [145], [0.094222222], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [176], [0.057], markersize = 5, markercolor = [:green], label = false)

savefig(pl26b,"$(filename_prefix)shorttimeemp_2.pdf")

pl26b1 = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# tatsächlich ausgezahlte kurzarbeit from april to july with workforce 33 mio
scatter!(pl26b1, [23], [0.078], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [53], [0.180], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [83], [0.179], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [114], [0.140], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [145], [0.128], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [176], [0.078], markersize = 5, markercolor = [:green], label = false)

savefig(pl26b1,"$(filename_prefix)shorttimeemp_tatsaechliche_kurzarbeit.pdf")


pl26c = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# ifo kurzarbeit absolut numbers from may to sept
#scatter!(pl26b, [21], [0.057333333], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [82], [0.161694444], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [112], [0.149366444], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [143], [0.1233842], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [171], [0.103415978], markersize = 5, markercolor = [:green], label = false)
# scatter!(pl26c, [201], [0.082955756], markersize = 5, markercolor = [:green], label = false)

savefig(pl26c,"$(filename_prefix)shorttimeemp_ifo.pdf")



pl26c = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# ifo kurzarbeit percent from may to sept
scatter!(pl26c, [82], [0.216507054], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [112], [0.2], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [143], [0.165210065], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [171], [0.138472839], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26c, [201], [0.11107683], markersize = 5, markercolor = [:green], label = false)

savefig(pl26c,"$(filename_prefix)shorttimeemp_ifo_perc.pdf")

pl2a = plot(datat*collect(1:nnew),[unempmean[nzerw+1:nzerw+nnew], unempmean[nzerw+1:nzerw+nnew].-unempstd[nzerw+1:nzerw+nnew],unempmean[nzerw+1:nzerw+nnew].+unempstd[nzerw+1:nzerw+nnew]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["unemp" "" ""])
# FRED Registered Unemployment Rate
scatter!(pl2a, [21], [0.05], markersize = 5, markercolor = [:green], label = false)
scatter!(pl2a, [51], [0.058], markersize = 5, markercolor = [:green], label = false)
scatter!(pl2a, [83], [0.063], markersize = 5, markercolor = [:green], label = false)
scatter!(pl2a, [112], [0.064], markersize = 5, markercolor = [:green], label = false)
scatter!(pl2a, [143], [0.064], markersize = 5, markercolor = [:green], label = false)
scatter!(pl2a, [171], [0.063], markersize = 5, markercolor = [:green], label = false)
#scatter!(pl2a, [201], [0.063], markersize = 5, markercolor = [:green], label = false)
savefig(pl2a,"$(filename_prefix)unempdyn_emp.pdf")




pl10a = plot(datat*collect(1:nnew),[gdplossmean[nzerw+1:nzerw+nnew], gdplossmean[nzerw+1:nzerw+nnew].-gdplossstd[nzerw+1:nzerw+nnew],gdplossmean[nzerw+1:nzerw+nnew].+gdplossstd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "GDP loss[%]")
# calculate average GDP loss in quarters
q1loss = (10*0+sum(gdplossmean[1:3]))/13
q2loss = sum(gdplossmean[4:16])/13
q3loss = sum(gdplossmean[17:29])/13
scatter!(pl10a, [21], [0.018], markersize = 5, markercolor = [:green], label = false)
scatter!(pl10a, [112], [0.113], markersize = 5, markercolor = [:green], label = false)
scatter!(pl10a, [201], [0.037], markersize = 5, markercolor = [:green], label = false)
scatter!(pl10a, [21], [q1loss], markersize = 5, markercolor = [:blue], label = false)
scatter!(pl10a, [112], [q2loss], markersize = 5, markercolor = [:blue], label = false)
scatter!(pl10a, [201], [q3loss], markersize = 5, markercolor = [:blue], label = false)
savefig(pl10a,"$(filename_prefix)gdplossemp.pdf")

pl6b = plot(datat*collect(1:nnew),[infmean[nzerw+1:nzerw+nnew,1], infmean[nzerw+1:nzerw+nnew,1].-infstd[nzerw+1:nzerw+nnew,1],infmean[nzerw+1:nzerw+nnew,1].+infstd[nzerw+1:nzerw+nnew,1],hcapfrac[nzerw+1:nzerw+nnew]], linestyle = [:solid :dot :dot :solid], linewidth = [2 1 1 1], linecolor = [:blue :black :black :black],label = ["y" "" "" "cap"])
plot!(datat*collect(1:nnew),[infmean[nzerw+1:nzerw+nnew,2], infmean[nzerw+1:nzerw+nnew,2].-infstd[nzerw+1:nzerw+nnew,2],infmean[nzerw+1:nzerw+nnew,2].+infstd[nzerw+1:nzerw+nnew,2]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:red :black :black],label = ["o" "" ""])
plot!(datat*collect(1:nnew),[infmean[nzerw+1:nzerw+nnew,3], infmean[nzerw+1:nzerw+nnew,3].-infstd[nzerw+1:nzerw+nnew,3],infmean[nzerw+1:nzerw+nnew,3].+infstd[nzerw+1:nzerw+nnew,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:green :black :black],label = ["tot" "" ""])
savefig(pl6b,"$(filename_prefix)infdynemp.pdf")

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

R0countmean = mean(hcat((results -> results[:R0counttraj]).(worker_results)...), dims=2)
R0countstd = std(hcat((results -> results[:R0counttraj]).(worker_results)...), dims=2)
pl23 = plot(datat*collect(2:nn),[R0countmean[2:nn], R0countmean[2:nn].-R0countstd[2:nn],R0countmean[2:nn].+R0countstd[2:nn]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = ["R0" "" ""])
savefig(pl23,"$(filename_prefix)R0countdyn.pdf")

gdplossh = (results -> results[:togdploss]).(worker_results)
totcash = 100*(results -> results[:totcas]).(worker_results)
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
