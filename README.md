# The International Model of Alcohol Harms and Policies

> *Copyright 2018 Canadian Institute for Substance Use Research. Licensed under the MIT license.*

This RStudio Shiny app provides an interface to the International Model of Alcohol Harms and Policies (InterMAHP), an R package used to compute Alcohol Attributable Fractions (AAFs), explore change in alcohol consumption scenarios, visualize the results, and download relevant computed statistics in .csv format.  Users provide statistics on drinking prevalence, average alcohol consumption, and total deaths and/or hospitalizations in their region.  A customizable table used to generate condition-specific relative risk curves is also provided. InterMAHP is [available online](#not-yet-public), or it can be [run locally](#r-interactive).

This document serves as a tutorial for the app, and complements the guides found on [InterMAHP's homepage](https://www.uvic.ca/research/centres/cisur/projects/intermahp/index.php) at the Canadian Institute for Substance Use Research.

Table of contents
=================
-   [Background](#background)
-   [Overview](#overview)
-   [Running InterMAHP locally](#running-intermahp-locally)
-   [Running InterMAHP remotely](#running-intermahp-remotely)
-   [Using InterMAHP](#using-intermahp)
    -   [Quick start](#quick-start)
    -   [Using your own data](#using-your-own-data)
        -   [Prevalence and consumption](#prevalence-and-consumption)
        -   [Morbidity and mortality](#morbidity-and-mortality)
        -   [Relative risk](#relative-risk)
    -   [Advanced settings](#advanced-settings)
        -   [Units of alcohol](#units-of-alcohol)
        -   [Binge limits](#binge-limits)
        -   [Upper limits](#upper-limits)
        -   [Dose extrapolation](#dose-extrapolation)
        -   [Drinking groups](#drinking-groups)
    -   [Analysis](#analysis)
        -   [Generate estimates](#generate-estimates)
        -   [Add new scenarios](#add-new-scenarios)
    -   [Results](#results)
        -   [High level](#high-level)
        -   [Analyst](#analyst-level)
-   [Further reading](#further-reading)
    -   [Comprehensive manual](#comprehensive-manual)
    -   [References](#references)
    -   [Not yet public](#not-yet-public)

## Background

## Overview

InterMAHP allows customization of relative risk curves, drinking status specification, and models changes in consumption to generate estimates of harms in a given population.  Results are available in a variety of forms: customizable downloadable charts, summary statistic tables, and full morbidity and mortality attributable fraction tables.

## Running InterMAHP locally

InterMAHP depends on two packages available through github.  The easiest way to install these is through the `devtools` package, available on CRAN.  You'll need `intermahpr`, the InterMAHP backend:
```sh
devtools::install_github("uvic-cisur/intermahpr")
```
and rCharts:
```sh
devtools::install_github("ramnathv/rCharts")
```

The remaining packages, available through CRAN, are
```
shiny
shinyjs
shinyWidgets
shinyalert
dplyr
purrr
tidyr
magrittr
gtools
DT
```
TODO:: Include a script that installs all necessary packages.

The easiest way to run InterMAHP locally is through the RStudio 'Run App' button, but you may also execute the command
```sh
shiny::runApp(launch.browser=TRUE)
```
in the directory containing this repository from a base R installation.

## Running InterMAHP remotely

InterMAHP is also hosted at [shinyapps.io](#not-yet-public) for remote access.

## Using InterMAHP

### Quick start

Preloaded datasets are provided to allow a quick exploration of InterMAHP's functionality.  Navigate to the 'Datasets >> Use sample datasets' tab, select desired years of study and ischaemic heart disease treatment, and load the data.  InterMAHP will use Canadian prevalence, consumption, and mortality data for the selected years.

The choice of ischaemic heart disease treatment is a choice of preferred literature. Ischaemic heart disease relative risk is stratified at the meta-analysis level by treatment of abstainer bias. Zhao explicitly controls for abstainer bias by selecting studies with no bias and other methods. Roerecke reweights relative risk results from studies which pooled former and never drinkers as abstainers using a standard methodology.

For more information, refer to the articles themselves:
-   [Zhao](https://www.jsad.com/doi/abs/10.15288/jsad.2017.78.375)
-   [Roerecke](https://onlinelibrary.wiley.com/doi/abs/10.1111/j.1360-0443.2012.03780.x)
    
When the data is loaded, advanced settings may be tinkered with or left alone.  For more information, see the section of this document on advanced [settings](#advanced-setting).

Next, generate estimates and add new scenarios if desired.  This typically takes several seconds per year of sample data.

The 'High level results' tab generates custom charts from the computed statistics.  The 'Analyst level results' tab displays generated datasets and provides a data download link.

### Using your own data

Before using local data, refer to the sample datasheets provided for download under the 'Datasets >> Upload new datasets' tab.  The variable names used in these sample sheets must be the same variable names used in the data you wish to analyze using InterMAHP.

InterMAHP currently only recognizes the values of 'Male' and 'Female' (and, in the relative risk sheet, 'All') under the 'gender' variable for the purposes of generating alcohol consumption density curves and choosing specialized relative risk curves.

#### Prevalence and consumption

The prevalence and consumption data variables provide the data necessary to estimate alcohol exposure among regional populations, stratified by region, year, gender, and age group.  The previous four variables are used to join tables, so ensure that their levels match those found in your morbidity/mortality and relative risk datasets as needed.  The following is a brief description of each variable, and refers to a Region-Year-Gender-Age group as a 'cohort'.

-   <a name = "region">*Region*</a> &ndash; Region is a variable of the prevalence/consumption and morbidity/mortality datasets.
-   <a name = "year">*Year*</a> &ndash; Year is a variable of the prevalence/consumption and morbidity/mortality datasets.
-   <a name = "gender">*Gender*</a> &ndash; Note that the relative risk sheet accepts the additional gender option of 'All', but this option merely duplicates the row over the rest of the gender levels.  Otherwise, genders must match those found in your morbidity/mortality and relative risk datasets. 
-   <a name = "age-group">*Age_group*</a> &ndash; Age group is a variable of the prevalence/consumption and morbidity/mortality datasets.  Because morbidity and mortality data is typically available for persons less than 15 years of age but alcohol consumption data is not, InterMAHP uses the next youngest age group to distribute harm in this age group for conditions wholly attributable to alcohol.  No prevalence/consumption data is needed for this age group; just ensure that sorting your age groups is alphabetical order also sorts them youngest to oldest.  This is achieved, for example, by the age groups "00-14", "15-34", "35-64", "65+".
-   *Population* &ndash; The population of the given cohort.
-   *PCC_litres_year* &ndash; The best estimate of per capita consumption in litres over the entire population within the given region over the given year.  Note that this observation is constant over genders and age groups with the same region and year.  This value is distributed over cohorts using population and relative consumption between cohorts.
-   *Correction_factor* &ndash; Per capita consumption is adjusted by the given correction factor to account for overestimation when producing consumption statistics via recorded + unrecorded consumption as the epidemiological studies that produce relative risk functions are typically subject to per capita consumption undercoverage.  The default value approved by the WHO methodological committee is 0.8 (Source).  For more details see the [comprehensive manual](#comprehensive-manual).
-   *P_LA* &ndash; Prevalence of lifetime abstainers in cohort.  A lifetime abstainer is defined as a person that has never consumed one standard drink.
-   *P_FD* &ndash; Prevelence of former drinkers in cohort.  A former drinker is defined as a person that has consumed at least one standard drink in their lifetime, but has not consumed a standard drink in the past year.
-   *P_CD* &ndash; Prevalence of current drinkers in cohort.  A current drinker is defined as a person that has consumed a standard drink in the past year.  Note that, by definition, P_LA + P_FD + P_CD = 1.00.
-   *P_BD* &ndash; Prevalence of binge drinkers among cohort.  A binge drinker is defined as a person that has consumed at or above the binge drinking level in the past month.  Binge drinking levels are user defined (see [binge limits](#binge-limits) for more details). 

**Note on prevalence values**: Prevalence values must be presented as proportions rather than percentages, i.e. use 0.50 rather than 50.0 or 50%.

#### Morbidity and mortality

The morbidity and mortality table provides data necessary to calibrate risk for conditions wholly attributable to alcohol and is necessary to display high level results.  The Region, Year, Gender, and Age_group variables are used to join this data with prevalence/consumption data, and the IM and Outcome variables are used to join this table with relative risk data.  This data is regarded as supplementary for analyst level results &mdash; i.e. one may upload a .csv file containing only a header row with the following variables, and InterMAHP will still produce analyst level results.

-   *Region* &ndash; See [above](#region)
-   *Year* &ndash; See [above](#year)
-   *Gender* &ndash; See [above](#gender)
-   *Age_group* &ndash; See [above](#age-group)
-   *IM* &ndash; InterMAHP condition coding.  A detailed list of condition codes is available in the [comprehensive manual](#comprehensive-manual).
-   *Outcome* &ndash; Either 'Morbidity' or 'Mortality'.  Typically, morbidity data is obtained from hospital records and mortality from national vital statistics agencies.
-   *Count* &ndash; The observed total number of morbidities or mortalities among the specified cohort.

#### Relative risk



### Advanced settings

#### Units of alcohol

#### Binge limits

#### Upper limits

#### Dose extrapolation

#### Drinking groups

### Analysis

#### Generate estimates

#### Add new scenarios

### Results

#### High level

#### Analyst level

## Further reading

### Comprehensive manual

### References

### Not yet public

The remotely available public version of InterMAHP hosted on shinyapps.io is not yet public.  Release date TBD.
