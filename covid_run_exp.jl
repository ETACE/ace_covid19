# === HowTo ===
# > julia -p <P> covid_run_exp.jl path/to/config-folder/ <N> [--append]
# P: Number of processes run in parallel
# N: Number of runs
# config-folder has to contain covid_par_ini_.jl-file
# if "--append", existing baseline.dat will be extended.

using Distributed
using Serialization

@everywhere using Agents, Serialization, Statistics,Random



filename_prefix = ARGS[1]
no_runs = parse(Int64, ARGS[2])
append = false
if length(ARGS)[1] > 2
	if ARGS[3] == "--append"
		append = true
	end
end

@everywhere function launch_model(filename_prefix, number)
	println("starting run $(number)")
	flush(stdout)

	ini_file = "$(filename_prefix)covid_par_ini.jl"

	include("covid_model.jl")
	include("covid_snapshot_loader.jl")
	include(ini_file)
	include("covid_main_p.jl")

	println("finished run $(number)")
	flush(stdout)
end

all_results = []
if append
	all_results = deserialize(open("$(filename_prefix)batchdata.dat"))
end

for idx in 1:(Int(floor(no_runs / nworkers())) + 1)
	from = (idx-1)*nworkers()+1
	to = min((idx-1)*nworkers() + nworkers(), no_runs)
	if from <= to
		println("Spawning workers for runs $(from) to $(to)...")
		worker_futures = []
		lastactiveworker=0
		for idxx = 1:nworkers()
			if (idx-1)*nworkers()+idxx <= no_runs
				push!(worker_futures, @spawnat (idxx+1) launch_model("$(filename_prefix)", (idx-1)*nworkers()+idxx))
				sleep(1)
				lastactiveworker = (idxx+1)
			end
		end
		fetch.(worker_futures)

		result_futures = []
		for idx = 1:lastactiveworker
			push!(result_futures, @spawnat (idx+1) (() -> Dict(:RKIR0traj => RKIR0traj,
		                :castraj => castraj,:totcastraj => totcastraj, :unempltraj => unempltraj,
		                :pubacctraj => pubacctraj,:constraj => constraj,
		                :unempsectraj => unempsectraj,:tautraj => tautraj,
		                :conspercaptraj => conspercaptraj, :R0counttraj => R0counttraj,
		                :gdppercaptraj => gdppercaptraj, :f_av_savings => f_av_savings,
		                :f_av_workers => f_av_workers,:f_var_workers => f_var_workers,
		                :f_av_stock => f_av_stock,:f_av_demandexp => f_av_demandexp,
		                :f_var_demandexp => f_var_demandexp,:totinftraj => totinftraj,
						:inftraj => inftraj,:curinfregtrajy=>curinfregtrajy,:curinfregtrajo=>curinfregtrajo,
						:inactivefirmstraj=>inactivefirmstraj,:bailouttraj=>bailouttraj,
						:totcas=>totcas,:togdploss=>totgdploss,:totfirmtraj=>totfirmtraj,:gdplosstraj=>gdplosstraj,
						:bankrupttraj=>bankrupttraj,:contact_work_traj=>contact_work_traj,:contact_count_traj=>contact_count_traj,
						:contact_social_traj=>contact_social_traj,:contact_shop_traj=>contact_shop_traj,:RKIR0smtraj=>RKIR0smtraj,
						:polswitchcount=>polswitchcount,:badpoltime=>badpoltime))())
		end
		worker_results = fetch.(result_futures)
		global all_results = vcat(all_results, worker_results)
	end
end


println("All runs finished!")

open("$(filename_prefix)batchdata.dat", "w") do outfile
	serialize(outfile,all_results)
end
