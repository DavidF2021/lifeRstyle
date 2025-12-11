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

# like said above, i think these tables need to be renamed, calling them by the table code on CSO is too confusing

# Access combined dataset
combined_data <- data_list$combined

colnames(combined_data) #View columns
head(combined_data) #View rows
View(combined_data) #View dataset
