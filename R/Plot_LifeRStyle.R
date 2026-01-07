#' Create plots for combined CSO data
#'
#' Generates a histogram, boxplot, and scatter plot for combined CSO data.
#'
#' @param data A cleaned combined LifeRstyle dataset.
#'
#' @return A list containing three ggplot objects: histogram, boxplot, and scatter plot.
#'
#' @importFrom ggplot2 ggplot aes geom_histogram facet_wrap labs theme_minimal
#'   geom_boxplot geom_point stat_summary scale_color_viridis_c
#'
#' @export
#'
#' @examples
#' plots <- plot_combined_data(combined_cleaned)
#' plots$histogram
plot_combined_data <- function(data) {

  hist_plot <- ggplot2::ggplot(data, ggplot2::aes(x = value, fill = table_name)) +
    ggplot2::geom_histogram(binwidth = 10, color = "white") +
    ggplot2::facet_wrap(~ table_name, scales = "free") +
    ggplot2::labs(
      title = "Histogram of Combined Tables",
      x = "Age",
      y = "Count"
    ) +
    ggplot2::theme_minimal()

  box_plot <- ggplot2::ggplot(data, ggplot2::aes(x = table_name, y = value, fill = table_name)) +
    ggplot2::geom_boxplot() +
    ggplot2::labs(
      title = "Boxplot of Values by Age",
      x = "Table",
      y = "Age"
    ) +
    ggplot2::theme_minimal()

  scatter_plot <- ggplot2::ggplot(data, ggplot2::aes(x = table_name, y = value)) +
    ggplot2::geom_point(
      ggplot2::aes(color = value),
      position = ggplot2::position_jitter(width = 0.2)
    ) +
    ggplot2::stat_summary(fun = mean, geom = "line", color = "red", size = 1) +
    ggplot2::labs(
      title = "Scatter of Age by Table with Mean Line",
      x = "Table",
      y = "Age",
      color = "Value"
    ) +
    ggplot2::theme_minimal() +
    ggplot2::scale_color_viridis_c()

  list(
    histogram = hist_plot,
    boxplot   = box_plot,
    scatter   = scatter_plot
  )
}
