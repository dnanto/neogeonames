context("Test expected countrify results")

test_that(
  "countrify matches to ISO 3166-1 alpha-2 code",
  expect_equal(countrify("US")$iso, "US")
)

test_that(
  "countrify matches to ISO 3166-1 alpha-3 code",
  expect_equal(countrify("USA")$iso, "US")
)

test_that("countrify matches to country name", {
  expect_equal(countrify("United States")$iso, "US")
  expect_equal(countrify("united states")$iso, "US")
  expect_equal(countrify("UNITED STATES")$iso, "US")
})

test_that(
  "countrify matches to misspelled country name",
  expect_equal(countrify("Viet Nam")$iso, "VN")
)
