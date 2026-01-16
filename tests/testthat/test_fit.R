library(lifeRstyle)

test_that("Fit_LifeRStyle produces valid model fits", {
  expect_error(fit_lifeRstyle(HIS15_cleaned, fit_type = "smooth.spline"))
})

