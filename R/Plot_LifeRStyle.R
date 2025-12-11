##Plots
# Histogram by table
ggplot(combined_data, aes(x = value, fill = table_id)) +
  geom_histogram(binwidth = 10, color = "white") +
  facet_wrap(~table_id, scales = "free") +
  labs(title = "Histogram of Combined Tables",
       x = "Value",
       y = "Count") +
  theme_minimal()

#Boxplot of combined dataset
ggplot(combined_data, aes(x = table_id, y = value, fill = table_id)) +
  geom_boxplot() +
  labs(title = "Boxplot of Values by Table",
       x = "Table",
       y = "Value") +
  theme_minimal()


## what are we trying to show with these plots?? again i think the table_id's need to be changed
## because it makes the plots quite unreadable
