library(lifeRstyle)

test_that("test that fit_lifeRstyle errors when required columns are missing", {

  bad_data <- data.frame(
    Year = 2020,
    Sex = "Male"
  )

  expect_error(
    fit_lifeRstyle(bad_data, fit_type = "lm")
  )
})


test_that("test that anova_table errors for non st403_fit objects", {

  expect_error(
    anova_table(data.frame(x = 1:5))
  )
})

