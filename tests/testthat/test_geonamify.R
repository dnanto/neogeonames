context("Test expected geonamify results")

test_that(
  "geonamify throws error for missing query",
  expect_error(geonamify())
)

test_that(
  "geonamify throws error for empty query",
  expect_error(geonamify(""))
)

test_that(
  "geonamify returns data frame with 0 rows on no match",
  expect_equal(geonamify("#"), geoname[0, ])
)

test_that("geonamify matches to one place name given constraints", {
  # Washington (State)
  expect_equal(geonamify("Washington", where = list(country_code = "US", feature_code = "ADM1"))$admin1_code, "WA")
  # Washington (Capital)
  expect_equal(geonamify("Washington", where = list(country_code = "US", feature_code = "PPLC"))$admin1_code, "DC")
})

test_that("geonamify matches to misspelled places with threshold", {
  expect_equal(nrow(geonamify("Furfax County", n = 2)), 2)
})

test_that("geonamify matches to one misspelled place with constraints", {
  expect_equal(nrow(geonamify("Furfax County", where = list(country_code = "US", admin1_code = "VA", feature_code = "ADM2"))), 1)
})

test_that("geonamify matches to one misspelled place according to constraints order", {
  expect_equal(geonamify("Furfax County", where = list(country_code = "US", admin1_code = "VA", feature_code = akfc[["ac2"]]))$admin2_code, "059")
})

test_that("geonamify matches to one place with constraints as strings", {
  expect_equal(geonamify("Fairfax County", where = list(country_code = "US", feature_code = "ADM2"))$admin2_code, "059")
})
