getwd()
list.files()
file.exists("HIS01_cleaned.csv")

library(readr)
library(dplyr)

# These are to load the helper,modelling and to plot codes.
source("Load_LifeRstyle.R")
source("Fit_LifeRstyle.R")
source("Plot_LifeRstyle.R")

# 1. Load cleaned datasets

his01    <- read_csv("HIS01_cleaned.csv",    show_col_types = FALSE)
his09    <- read_csv("HIS09_cleaned.csv",    show_col_types = FALSE)
his15    <- read_csv("HIS15_cleaned.csv",    show_col_types = FALSE)
health   <- read_csv("health_cleaned.csv",   show_col_types = FALSE)
smoking  <- read_csv("smoking_cleaned.csv",  show_col_types = FALSE)
alcohol  <- read_csv("alcohol_cleaned.csv",  show_col_types = FALSE)
combined_data <- read_csv("combined_cleaned.csv", show_col_types = FALSE)

# These are to quick sanity checks
str(his15)
str(combined_data)

# 2. Fit models on HIS15 (drinking frequency)

# Linear regression model
his15_lm_fit <- fit(his15, fit_type = "lm")
print(his15_lm_fit)
summary(his15_lm_fit)

his15_anova_fit <- fit(his15, fit_type = "anova")
print(his15_anova_fit)

his15_anova_tab <- anova_table(his15_anova_fit)
print(his15_anova_tab)
# View(his15_anova_tab)   # uncomment in RStudio

plot(his15_lm_fit)
plot(his15_anova_fit)

# 3. Mixed-effects model on combined_data

library(lme4)

mixed_fit <- fit(combined_data, fit_type = "mixed")

print(mixed_fit)
summary(mixed_fit)

mixed_anova_tab <- anova_table(mixed_fit)
print(mixed_anova_tab)

plot(mixed_fit)

# 4. Optional: tests on other tables

health_lm_fit <- fit(health, fit_type = "lm")
print(health_lm_fit)
plot(health_lm_fit)

smoke_lm_fit <- fit(smoking, fit_type = "lm")
print(smoke_lm_fit)
plot(smoke_lm_fit)

# Run the codes below on the console at ones, it does simply are to load the functions.
# To call them on the datasets, to produce fitted models, ANOVA tables and diagnostics.

# source("Fit_LifeRstyle.R")
# his15_lm_fit     <- fit(his15, fit_type = "lm")
# his15_anova_fit  <- fit(his15, fit_type = "anova")
# mixed_fit        <- fit(combined_data, fit_type = "mixed")

# anova_table(his15_anova_fit)
# anova_table(mixed_fit)
# plot(his15_lm_fit)
# plot(mixed_fit)
