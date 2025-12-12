#Function to create plots for combined CSO data
plot_combined_data <- function(data) {

#Histogram by table
  hist_plot <- ggplot(data, aes(x = value, fill = table_name)) +
    geom_histogram(binwidth = 10, color = "white") +
    facet_wrap(~ table_name, scales = "free") +
    labs(
      title = "Histogram of Combined Tables",
      x = "Age",
      y = "Count"
    ) +
    theme_minimal()

#Boxplot by table
  box_plot <- ggplot(data, aes(x = table_name, y = value, fill = table_name)) +
    geom_boxplot() +
    labs(
      title = "Boxplot of Values by Age",
      x = "Table",
      y = "Age"
    ) +
    theme_minimal()

#Scatter points + mean line
  scatter_plot <- ggplot(data, aes(x = table_name, y = value)) +
    geom_point(aes(color = value), position = position_jitter(width = 0.2)) +
    stat_summary(fun = mean, geom = "line", color = "red", size = 1) +
    labs(
      title = "Scatter of Age by Table with Mean Line",
      x = "Table",
      y = "Age",
      color = "Value"
    ) +
    theme_minimal() +
    scale_color_viridis_c()

  # Return all plots as a list
  return(list(
    histogram = hist_plot,
    boxplot = box_plot,
    scatter = scatter_plot
  ))
}

