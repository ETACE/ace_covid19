using Statistics,Serialization,StatsPlots, DataFrames, LaTeXStrings

### baseline scenario in Germany with figure 1 a,b,c,d
### can only be plotted with green lines if empirical data is there
include("covid_plot_baseline_GER.jl")

### comparison plots w fig 2, supp fig 3
include("covid_plot_comparison_xi06.jl")
include("covid_plot_comparison_xi05.jl")

### and with dynamics for fig 3
include("covid_plot_dynamics_xi06.jl")
include("covid_plot_dynamics_xi05.jl")

### comparison plots including bailout porgram and shorttime program, supp fig 2
include("covid_plot_comparison_xi06_bailout.jl")
include("covid_plot_comparison_xi05_bailout.jl")

### no policy scenarios for supp fig 1
include("covid_plot_no_pol.jl")
