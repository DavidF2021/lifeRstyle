library(lifeRstyle)

test_that("test that download_and_clean_cso errors for invalid table_id", {

  expect_error(
    download_and_clean_cso(123)
  )
})


test_that("test that download_clean_combine_cso errors for invalid table_ids", {

  expect_error(
    download_clean_combine_cso(123)
  )
})
