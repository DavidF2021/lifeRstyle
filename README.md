---
output: github_document
---

<!-- README.md is generated from README.Rmd. Please edit that file -->

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "man/figures/README-",
  out.width = "100%"
)
```

# lifeRstyle

<!-- badges: start -->
<!-- badges: end -->

## Description

**lifeRstyle** Is an R package which downloads data about smoking habits, alcohol 
consumption and general health from the Central Statistics Office (CSO). Plots can be created 
and basic modelling can be performed of said data. Three functions are provided:

  1.  `Load_LifeRStyle`: for loading in the data in a tidy format.
  
  2. a `plot()` method: for producing visualisations of the data based on `ggplot()`
  
  3. a `fit()` method: for fitting statistical models (linear regression, ANOVA, mixed models) to said data. 

## Installation

You can install the development version of lifeRstyle from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("DavidF2021/lifeRstyle")
```

## Example

This is a basic example which shows you how to solve a common problem:

```{r example}
library(lifeRstyle)
## basic example code
```

