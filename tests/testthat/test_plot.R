library(lifeRstyle)

test_that("test that plot_combined_data returns ggplot objects", {

  data <- data.frame(
    table_name = rep(c("Table A", "Table B"), each = 10),
    value = c(20:29, 30:39)
  )

  plots <- plot_combined_data(data)

  expect_type(plots, "list")
  expect_s3_class(plots$histogram, "ggplot")
})


test_that("test that plot_combined_data errors for invalid input", {

  bad_data <- data.frame(
    age = 1:10,
    group = rep("A", 10)
  )

  expect_error(
    plot_combined_data(bad_data)
  )
})
