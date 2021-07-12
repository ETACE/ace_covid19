using Statistics,Serialization,StatsPlots

path_to_data = "../../data/working_paper_2/baseline_GER/"
filename_prefix = "../../figures/working_paper_2/"

mkpath(filename_prefix)

include("$(path_to_data)covid_par_ini.jl")
worker_results = deserialize(open("$(path_to_data)batchdata.dat"))

datapoint = fld(T,datat)

include("../../emp_traj.jl")

fac = nhh/50000
nzer= (Int(ceil(virustime/datat))-1)*datat+2*corlatent
emptotinftraj = vcat(zeros(nzer),fac*emptotinf)
nne = size(emptotinf)[1]

# Total number of infected: model vs. empirical data for Germany
emptotinftraj = vcat(zeros(nzer),fac*emptotinfnew)
nnen = size(emptotinfnew)[1]
nnen = 180
totinfmeansc = mean(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
totinfstdsc = std(hcat(detfrac*(results -> results[:totinftraj]).(worker_results)...), dims=2)
pl5b = plot(collect(1:nnen),[totinfmeansc[nzer+1:nzer+nnen], totinfmeansc[nzer+1:nzer+nnen].-totinfstdsc[nzer+1:nzer+nnen],totinfmeansc[nzer+1:nzer+nnen].+totinfstdsc[nzer+1:nzer+nnen]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black],label = false, xlabel="days", ylabel = "reported tot. inf.")
plot!(pl5b, detfrac*emptotinftraj[nzer+1:nzer+nnen], linecolor = [:green], label=false, linewidth = [2])
savefig(pl5b,"$(filename_prefix)baseline_total_number_infected.pdf")

# R-value: model vs. model vs. empirical data for Germany
RKIR0mean = mean(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
RKIR0std = std(hcat((results -> results[:RKIR0traj]).(worker_results)...), dims=2)
nn1 = size(RKIR0mean)[1]

nzer=(Int(ceil(virustime/datat))-1)*datat+2*corlatent
empR0smtraj = vcat(zeros(nzer),empR0new)
RKIR0smmean = mean(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
RKIR0smstd = std(hcat((results -> results[:RKIR0smtraj]).(worker_results)...), dims=2)
nnhc = nn1 - size(RKIR0smmean)[1]
nne = size(empR0new)[1]
nne = 180
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
savefig(pl16b,"$(filename_prefix)baseline_R-value.pdf")

# Casualites: model vs. empirical data for Germany
totcasmean = mean(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)
totcasstd = std(cat(100*(results -> results[:totcastraj]).(worker_results)...,dims=3), dims=3)

nzer= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
empcastraj = vcat(zeros(datat*nzer),fac*empcasnew)
nne = Int(ceil(size(empcasnew)[1]/datat))
nne = Int(ceil(180 / datat))
pl7b = plot(datat*collect(1:nne),[totcasmean[nzer+1:nzer+nne,3], totcasmean[nzer+1:nzer+nne,3].-totcasstd[nzer+1:nzer+nne,3],totcasmean[nzer+1:nzer+nne,3].+totcasstd[nzer+1:nzer+nne,3]], linestyle = [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black] )
plot!(pl7b, empcastraj[datat*nzer+1:180+datat*nzer], linecolor = [:green], linewidth = [2], legend = false, xlabel = "days", ylabel = "casualties [%]")
savefig(pl7b,"$(filename_prefix)baseline_casualties.pdf")


# Workers on short time: model vs. empirical data for Germany
shorttimemean = mean(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)
shorttimestd = std(hcat((results -> results[:shorttimetraj]).(worker_results)...), dims=2)

nzerw= (Int(ceil(virustime/datat+2*corlatent/datat))-1)
nnew = Int(ceil(size(empcasnew)[1]/datat))
nnew = Int(ceil(180/datat))

pl26b = plot(datat*collect(1:nnew),[shorttimemean[nzerw+1:nzerw+nnew], shorttimemean[nzerw+1:nzerw+nnew].-shorttimestd[nzerw+1:nzerw+nnew],shorttimemean[nzerw+1:nzerw+nnew].+shorttimestd[nzerw+1:nzerw+nnew]], linestyle= [:solid :dot :dot], linewidth = [2 1 1], linecolor = [:blue :black :black], label=false, xlabel = "days", ylabel = "short time [%]")
# tatsächlich ausgezahlte kurzarbeit from april to july
scatter!(pl26b, [23], [0.078], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [53], [0.180], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [83], [0.179], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [114], [0.140], markersize = 5, markercolor = [:green], label = false)
scatter!(pl26b, [145], [0.128], markersize = 5, markercolor = [:green], label = false)
savefig(pl26b,"$(filename_prefix)baseline_shorttime.pdf")
