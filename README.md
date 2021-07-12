# ETACE ACE-COVID19

Version: July 2021

This is the source code of the ace_covid19 model. The economic part is partly based on the
[EURACE@Unibi](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/Eurace_Unibi/) model, a large-scale agent-based macroeconomic model.
In light of the COVID-19 pandemic, we implement social interactions among agents to model the spread of the COVID-19 disease. This allows us to analyze the effect of the different lockdown policies and reopening strategies on economic variables like GDP, public expenditures, bankruptcies or unemployment rates, as well as epidemiological effects (number of infected individuals, casualties) in an integrated model.


## Getting Started

These instructions will allow you to run the model on your system.

### System Requirements and Installation

To run the code you need to install **[Julia](https://julialang.org/)** (v1.4.1). Additionally, the following packages need to be installed:

* [Agents](https://juliadynamics.github.io/Agents.jl/stable/) - Version 3.2.1
* [Plots](http://docs.juliaplots.org/) - Version 1.5.2
* [DataFrames](https://juliadata.github.io/) - Version 0.21.4
* [HypothesisTests](https://github.com/JuliaStats/HypothesisTests.jl) - Version 0.10.0
* [ProgressMeter](https://github.com/timholy/ProgressMeter.jl) - Version 1.3.1
* [StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) - Version 0.14.6
* [LaTeXStrings](https://github.com/stevengj/LaTeXStrings.jl) - Version 1.1.0

In order to install a package, start *julia* and execute the following command:

```
using Pkg; Pkg.add("<package name>")
```

A typical installation on desktop computer takes about 15 minutes. The code has been tested on Microsoft Windows 10, Ubuntu Server 16.04 LTS and macOS Catalina 10.15.5.

### Running The Model

The model is implemented in *covid_model.jl*. In *covid_par_ini.jl*, the initial values and parameters are set. The simulation can be started from a snapshot, which needs to be specified in the *covid_par_ini.jl*-file. A snapshot with 100.000 household agents can be found in the root folder (*snapshot100kr1.dat*).

The user can specify a set of policies that will be activated at certain point in time during the simulation. The policies have to be implemented in specific policy-files and added to *covid_par_ini.jl*. 

To run one simulation, use the command

```
julia covid_main.jl
```

A typical run on a normal desktop computer takes about 30 minutes.

To conduct different experiments and execute several runs of the model (batches) in parallel, setup your *covid_par_ini.jl*-files in a dedicated experiment folders and run

```
julia -p <no_cpus> covid_run_exp.jl <folder> <no_batches>
```

to execute a certain experiment. The simulation data of all runs will be stored in *batchdata.dat*. For an example on how to create plots from this file, see *covid_plot_exp.jl*.

## Replication

All *covid_par_ini.jl* and *batchdata.dat files* used to create the figures and tables in the [first working paper](https://dx.doi.org/10.2139/ssrn.3635329) (June 2020) and [second working paper](https://dx.doi.org/10.2139/ssrn.3799928) (February 2021) can be found in the *data/working_paper/* and *data/working_paper_2/* folders. Data Our latest results (corresponding to the version of the paper from July 2021) are located in the *data/* folder.

We use the following files located in the root folder to encode different policies (latest results):

* *policy_lockdown_2.jl* - The baseline lockdown policy.
* *policy_open_2.jl* - Baseline policy after lockdown.
* *policy_allout.jl* - Policy after vaccine becomes available (terminates all measures).

To vary the policy intensity (e.g. extend of business closures), we use the parameters *alpha_lockdown* and *alpha_open*.

For the results from the second working paper, we used the following policy files:

* *policy_lockdown_bailout.jl* - The baseline lockdown policy.
* *policy_open.jl* - Baseline policy after lockdown.
* *policy_allout.jl* - Policy after vaccine becomes available (terminates all measures).

For the results from the first working paper, we used the following policy files:

* *policy_baseline.jl* - The baseline lockdown policy.
* *policy_baseline_end.jl* - Baseline policy after lockdown.
* *policy_baseline_end_xi0.5.jl* - Baseline policy after lockdown with higher infection probability
* *policy_bailout.jl* - lockdown policy including bailout schemes.
* *policy_alpha.jl* - Lockdown policy with more or less severe restrictions on economic activity (alpha parameter).
* *policy_bailout_alpha.jl* - Lockdown policy with more or less severe restrictions on economic activity (alpha parameter) and bailout schemes.
* *policy_good_xi0.5.jl* - Policy after lockdown with partial economic restrictions and higher infection probability.
* *policy_only_xi* - Lockdown policy implementing individual preventive measures only.
* *policy_only_xi_ho* - Lockdown policy implementing individual preventive measures and working at home only.

### Data Creation

To reproduce the results from the paper by re-simulating the model use the folder structure and *covid_par_ini.jl* files in the *data* folder.
The *covid_par_ini.jl* file for e.g. the baseline is located in the *data/baseline_GER/* folder. In order to create a batch of 20 runs, execute

```
julia -p <no_cpus> covid_run_exp.jl data/baseline_GER/ 20
```

from the root folder. The simulation results will be stored in *data/baseline_GER/batchdata.dat*.

### Plotting

The plotting files are located in the *plot_files* folder. To plot all figures, use the command
```
julia create_plots.jl
```
Figures are stored in the *figures* folder. Data is taken from the folder *data*. 

### Statistical Testing

The file to perform the statistical tests is located in the *stat_tests/* folder. Use the command
```
julia execute_tests.jl
```
to create text files, which contains the results of all statistical tests.

### Empirical Data

We make use of empirical data from the [Johns Hopkins University](https://github.com/CSSEGISandData/COVID-19) for the number of infected and the number of casualties.
The number of infected and the number of casualties has been adjusted by the detection rate and has been scaled to a population of 100.000.
R0 is calculated from this data following [Robert Koch Institut's methodology](https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Situationsberichte/Archiv_Juli.html) which is available in all the daily reports.
The adjusted data is stored in *emp_traj.jl* in the root folder.


## Authors

Alessandro Basurto, Herbert Dawid, Philipp Harting, Jasper Hepp, Dirk Kohlweyer


## Further Links

* [Basurto et al. 2020](https://dx.doi.org/10.2139/ssrn.3635329) - Basurto, A., Dawid, H., Harting, P., Hepp, J., Kohlweyer, D. (2020). Economic and Epidemic Implications of Virus Containment Policies: Insights from Agent-Based Simulations
* [ETACE](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/) - Chair for Economic Theory and Computational Economics
* [EURACE@Unibi](http://www.wiwi.uni-bielefeld.de/lehrbereiche/vwl/etace/Eurace_Unibi/) - description of the EURACE@Unibi model
* [Dawid et al. 2019](https://pub.uni-bielefeld.de/record/2915598) - Dawid, H., Harting, P., van der Hoog, S., & Neugart, M. (2019). Macroeconomics with heterogeneous agent models: Fostering transparency, reproducibility and replication. Journal of Evolutionary Economics.


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
