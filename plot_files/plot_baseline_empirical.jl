using Statistics,Serialization,StatsPlots

path_to_data = "../data/mutation/beta_l50/"
filename_prefix = "../figures/"

mkpath(filename_prefix)

include("$(path_to_data)covid_par_ini.jl")
worker_results = deserialize(open("$(path_to_data)batchdata.dat"))

datapoint = fld(T,datat)

include("../emp_traj.jl")

empn = 200 # number of periods for empirical plots


# Total number of infected: model vs. empirical data for Germany
totinfmean = mean(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstd = std(hcat((results -> results[:totinftraj]).(worker_results)...), dims=2)
fac = nhh/50000
nzer= (Int(ceil(virustime/datat))-1)*datat+2*corlatent
emptotinftraj = vcat(zeros(nzer),fac*emptotinf)
nne = size(emptotinf)[1]

emptotinftraj = vcat(zeros(nzer),fac*emptotinfnew1)
nnen = size(emptotinfnew1)[1]
nnen = empn
totinfmeansc = mean(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstdsc = std(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
pl5b = plot(collect(1:nnen),[totinfmeansc[nzer+1:nzer+nnen], totinfmeansc[nzer+1:nzer+nnen].-totinfstdsc[nzer+1:nzer+nnen],totinfmeansc[nzer+1:nzer+nnen].+totinfstdsc[nzer+1:nzer+nnen]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel="days", ylabel = "reported tot. inf.")
plot!(pl5b, detfrac*emptotinftraj[nzer+1:nzer+nnen], linecolor = [:green], label=false, linewidth = [2])
savefig(pl5b,"$(filename_prefix)baseline_empirical_total_infected.pdf")


# R-value: model vs. empirical data for Germany
RKIR0mean = mean(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
RKIR0std = std(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
nn1 = size(RKIR0mean)[1]

nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0sm)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
nne = size(empR0sm)[1]
RKIR0smmean = vcat(zeros(nnhc),RKIR0smmean)
RKIR0smstd = vcat(zeros(nnhc),RKIR0smstd)

nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0new1)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
nne = size(empR0new1)[1]
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

# exclude Inf values
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
savefig(pl16b,"$(filename_prefix)baseline_empirical_R-value.pdf")


# Casualites: model vs. empirical data for Germany
totcasmean = mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
totcasstd = std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
nzer= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
nzerw= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
empcastraj = vcat(zeros(datat*nzer),fac*empcasnew1)
nne = Int(ceil(size(empcasnew1)[1]/datat))
nne = Int(ceil(empn / datat))
pl7b = plot(datat*collect(1:nne),[totcasmean[nzer+1:nzer+nne,3], totcasmean[nzer+1:nzer+nne,3].-totcasstd[nzer+1:nzer+nne,3],totcasmean[nzer+1:nzer+nne,3].+totcasstd[nzer+1:nzer+nne,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black] )
plot!(pl7b, empcastraj[datat*nzer+1:empn+datat*nzer], linecolor = [:green], linewidth = [2], legend = false, xlabel = "days", ylabel = "casualties [%]")
savefig(pl7b,"$(filename_prefix)baseline_empirical_casualties.pdf")


# GDP loss: model vs. emprical data for Germany
gdplossmean = mean(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
gdplossstd = std(hcat((results -> results[:gdplosstraj]).(worker_results)...), dims=2)
nnew = Int(ceil(empn/datat))
pl10a = plot(datat*collect(1:nnew),[gdplossmean[nzerw+1:nzerw+nnew], gdplossmean[nzerw+1:nzerw+nnew].-gdplossstd[nzerw+1:nzerw+nnew],gdplossmean[nzerw+1:nzerw+nnew].+gdplossstd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "GDP loss[%]")
# calculate average GDP loss in quarters
q1loss = (10*0+sum(gdplossmean[4:6]))/13
q2loss = sum(gdplossmean[7:19])/13
q3loss = sum(gdplossmean[20:32])/13
scatter!(pl10a, [21], [0.018], markersize = 5, markercolor = [:green], label = false)
scatter!(pl10a, [112], [0.113], markersize = 5, markercolor = [:green], label = false)
scatter!(pl10a, [201], [0.037], markersize = 5, markercolor = [:green], label = false)
savefig(pl10a,"$(filename_prefix)baseline_empirical_gdploss.pdf")


# Workers on short time: model vs. empirical data for Germany
shorttimemean = mean(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)
shorttimestd = std(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)

pl26b1 = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# tatsächlich ausgezahlte kurzarbeit from april to july with workforce 33 mio
scatter!(pl26b1, [23], [0.078], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [53], [0.180], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [83], [0.179], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [114], [0.140], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [145], [0.128], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [176], [0.078], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b1, [201], [0.067], markersize = 5, markercolor = [:green], label = false)

savefig(pl26b1,"$(filename_prefix)baseline_empirical_shorttime.pdf")


# Excess household saving per GDP: model vs. empirical data for Germany
gdpmean = mean(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
gdpstd = std(hcat((results -> results[:gdppercaptraj]).(worker_results)...), dims=2)
totalsavmean = mean(hcat((results -> results[:totalsavtraj]).(worker_results)...), dims=2)
totalsavstd = std(hcat((results -> results[:totalsavtraj]).(worker_results)...), dims=2)
totalsavmean_0 = (totalsavmean/nhh .- totalsavmean[2]/nhh)./(gdpmean[2]*52)
totalsavstd_0 =totalsavstd/nhh - totalsavstd/nhh
pl28a = plot(datat*collect(1:nnew),[totalsavmean_0[nzerw+1:nzerw+nnew], (totalsavmean_0[nzerw+1:nzerw+nnew].-totalsavstd_0[nzerw+1:nzerw+nnew]/(gdpmean[2]*52)),(totalsavmean_0[nzerw+1:nzerw+nnew].+totalsavstd_0[nzerw+1:nzerw+nnew]/(gdpmean[2]*52))], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, ylabel = "Excess HH Savings per GDP per Capita", xlabel = "days")
scatter!(pl28a, [21], [0.004], markersize = 5, markercolor = [:green], label = false)
scatter!(pl28a, [112], [0.019], markersize = 5, markercolor = [:green], label = false)
scatter!(pl28a, [201], [0.026], markersize = 5, markercolor = [:green], label = false)
savefig(pl28a,"$(filename_prefix)baseline_emprical_exccess_savings.pdf")
