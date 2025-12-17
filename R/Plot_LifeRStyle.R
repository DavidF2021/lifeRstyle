#Function to create plots for combined CSO data
plot_combined_data <- function(data) {

#Histogram by table
  hist_plot <- ggplot2::ggplot(data, ggplot2::aes(x = value, fill = table_name)) +
    ggplot2::geom_histogram(binwidth = 10, color = "white") +
    ggplot2::facet_wrap(~ table_name, scales = "free") +
    ggplot2::labs(
      title = "Histogram of Combined Tables",
      x = "Age",
      y = "Count"
    ) +
    ggplot2::theme_minimal()

#Boxplot by table
  box_plot <- ggplot2::ggplot(data, ggplot2::aes(x = table_name, y = value, fill = table_name)) +
    ggplot2::geom_boxplot() +
    ggplot2::labs(
      title = "Boxplot of Values by Age",
      x = "Table",
      y = "Age"
    ) +
    ggplot2::theme_minimal()

#Scatter points + mean line
  scatter_plot <- ggplot2::ggplot(data, ggplot2::aes(x = table_name, y = value)) +
    ggplot2::geom_point(aes(color = value), position = position_jitter(width = 0.2)) +
    ggplot2::stat_summary(fun = mean, geom = "line", color = "red", size = 1) +
    ggplot2::labs(
      title = "Scatter of Age by Table with Mean Line",
      x = "Table",
      y = "Age",
      color = "Value"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_color_viridis_c()

  # Return all plots as a list
  return(list(
    histogram = hist_plot,
    boxplot = box_plot,
    scatter = scatter_plot
  ))
}

