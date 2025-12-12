# Inspect column names (If table structure changes)
print(colnames(df))

#View first few rows
head(alcohol_cleaned)

#View first few rows
head(his09_cleaned)

head(health_cleaned)

# Access individual cleaned tables
his15 <- data_list$individual$HIS15
his01 <- data_list$individual$HIS01


colnames(combined_data) #View columns
head(combined_data) #View rows
View(combined_data) #View dataset



###Plots
#Usage
plots <- plot_combined_data(combined_data)

#View individual plots
plots$histogram
plots$boxplot
plots$scatter

