
<!-- README.md is generated from README.Rmd. Please edit that file -->

# lifeRstyle

<!-- badges: start -->

<!-- badges: end -->

## Description

**lifeRstyle** Is an R package which downloads data about smoking
habits, alcohol consumption and general health from the Central
Statistics Office (CSO). Plots can be created and basic modelling can be
performed of said data. The package focuses on indicators such as smoking habits,
alcohol consumption, and general health and wellbeing. 
Three functions are provided:

## Features

1.  `Load_LifeRStyle`:
     Download, clean, and combine CSO datasets
     Output data in a tidy format suitable for analysis

2.  `Visualisation`
    `plot()` method: for producing visualisations of the data based on
    `ggplot()`

3.  `Statistical modelling`
    `fit()` method: for fitting statistical models (linear regression,
     ANOVA, mixed models) to said data.

## Installation

You can install the development version of lifeRstyle from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("DavidF2021/lifeRstyle")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(lifeRstyle)
## basic example code
```
