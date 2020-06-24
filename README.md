# ETACE ACE-COVID19

Version: June 2020

This is the source code of the ace_covid19 model.
The economic part is partly based on the [EURACE@Unibi](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/Eurace_Unibi/), a large-scale agent-based macroeconomic model.
In light of the COVID-19 pandemic, we implement social interactions among agents to model the spread of the COVID-19 disease. This allows us to analyze the effect of the different lockdown policies and reopening strategies on economic variables like GDP, public expenditures, bankruptcies or unemployment rates, as well as  epidemological effects (number of infected individuals, casulties) in an integrated model.


## Getting Started

These instructions will allow you to run the model on your system.

### Prerequisites

To run the code you need to install **Julia** (v1.4.1). Additionnally, we make use of the following packages:
Agents, Random, Plots, Serialization, ProgressMeter, Statistics, StatsPlots, DataFrames.

For the package **Agents**, we use the **version 3.2.1**, which can be installed via

```
Pkg.add(Pkg.PackageSpec(;name="Agents", version="3.2.1"))
```

### Running The Model

The model is implemented in *covid_model.jl*. In *covid_par_ini.jl*, the inital values and parameters are set. The simulation can be started from a snapshot (for example *snapshot100kr1.jl*). This needs to be specified in the *covid_par_ini.jl*-file.

The user can specify a set of policies that will be activated at certain point in time during the simulation. The policies have to be implemented in specific policy-files and added to *covid_par_ini.jl*. In our baseline simulation, we use the following policy files:
* *policy2.jl* - lockdown measures
* *policy2_end1.jl* - reopening measures
* *policy_allout.jl* - reset all values (used to end the pandemic)


To run one simulation, use the command

```
julia covid_main.jl
```

To conduct different experiments and execute several runs of the model (batches) in parallel, setup your *covid_par_ini.jl*-files in a dedicated experiment folders and run

```
julia -p <no_cpus> covid_run_exp.jl <folder> <no_batches>
```

to execute a certain experiment. The simulation data of all runs will be stored in *batchdata.dat*. For an example on how to create plots from this file, see *covid_plot_exp.jl*.


## Built With

* [Julia](https://julialang.org/) - Version 1.4.1
* [Agents](https://juliadynamics.github.io/Agents.jl/stable/) - Version 3.1.2


## Authors

Alessandro Basurto, Herbert Dawid, Philipp Harting, Jasper Hepp, Dirk Kohlweyer


## Further Links

* [ETACE](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/) - Chair for Economic Theory and Computational Economics
* [EURACE@Unibi](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/Eurace_Unibi/) - description of the EURACE@Unibi model
* [Dawid et al 2019](https://pub.uni-bielefeld.de/record/2915598) - Dawid, H., Harting, P., van der Hoog, S., & Neugart, M. (2019). Macroeconomics with heterogeneous agent models: Fostering transparency, reproducibility and replication. Journal of Evolutionary Economics.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
