# To create all plots execute this file from within this folder
# "julia create_plots.jl"
# Figures will be created in the 'figures' folder

include("plot_baseline_empirical.jl") # Fig. 1
include("plot_dynamics_no_policy.jl") # Fig. 2
include("plot_variation_policy_mutation.jl") # Fig. 3
include("plot_dynamics_policies.jl") # Fig. 4
include("plot_variation_policy_no_mutation.jl") # Fig. 5a
include("plot_variation_policy_no_mutation_pinf125.jl") # Fig. 5b
include("plot_boxplots_policy_A.jl") # Fig. 6a,b
include("plot_boxplots_policy_D.jl") # Fig. 6c,d
include("plot_vaccination_rollout.jl") # Fig. 7
