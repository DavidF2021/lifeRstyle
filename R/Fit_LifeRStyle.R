

##Modelling
#lm to display how Sex, Year, Age Group influence values.
lm_model <- lm(value ~ Sex + Age.Group + Year, data = his15)
summary(lm_model)

#One-way ANOVA for Age Group
#Comparing age groups
anova_model <- aov(value ~ Age.Group, data = his15)
summary(anova_model)


#Mixed Effects model for fixed and random effects
mixed_model <- lmer(value ~ Sex + Age.Group + (1|table_id), data = combined_data)
summary(mixed_model)


## if we were following the format of the climr3 package, plots were made according
## to the models fitted.
#Add scatter plots?
#Test
