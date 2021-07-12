# To execute all statistical tests execute this file from within this folder
# "julia execute_tests_from_paper.jl"

include("stat_tests_mutation.jl") # Mutation scenario
include("stat_tests_between_scenarios.jl") # Mutation vs. no mutation
include("stat_tests_no_mutation.jl") # No mutation scenario
include("stat_tests_no_mutation_pinf125.jl") # Higer infection probability scenario
