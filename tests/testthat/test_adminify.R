context("Test expected adminify results")

test_that(
  "adminify throws error for missing query",
  expect_error(adminify())
)

test_that(
  "adminify returned values are all NA for non-match",
  {
    geo <- adminify("")
    expect_equal(all(is.na(c(geo$id, geo$ac))), T)
  }
)

test_that(
  "adminify matches one place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify("Fairfax County", "")$ac), collapse = "."),
      "059"
    )
})

test_that(
  "adminify matches delimited, multi place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify("US: Virginia, Fairfax County", "[:,]")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("US, Virginia, Fairfax County", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("Virginia, Fairfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("US, Fairfax County, Virginia", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("VA, Fairfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
  }
)


test_that(
  "adminify matches delimited, mispelled, multi place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify("US: Virginia, Furfax County", "[:,]")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("US, Virginia, Furfax County", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("USA, Furfax County, Virginia", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify("VA, Furfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
  }
)
