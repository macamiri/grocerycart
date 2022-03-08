test_that("empty string converted to NA", {
  expect_equal(empty_to_na(""), NA)
})

test_that("null string converted to NA", {
  expect_equal(empty_to_na(NULL), NA)
})

test_that("NA remains NA", {
  expect_equal(empty_to_na(NA), NA)
})
