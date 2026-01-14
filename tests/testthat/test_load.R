library(lifeRstyle)

test_that("Load_LifeRstyle produces valid data",{
          expect_error(download_clean_combine_cso(ST403))
})
