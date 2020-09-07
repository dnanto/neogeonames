context("Test expected adminify_* results")

## adminify_delim

test_that(
  "adminify_delim throws error for missing args",
  expect_error(adminify_delim())
)

test_that(
  "adminify_delim returned values are all NA for non-match",
  {
    geo <- adminify_delim("")
    expect_equal(all(is.na(c(geo$id, geo$ac))), T)
  }
)

test_that(
  "adminify_delim matches one place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("Fairfax County")$ac), collapse = "."),
      "059"
    )
  }
)

test_that(
  "adminify_delim matches delimited, multi place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("US: Virginia, Fairfax County", "[:,]")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("US, Virginia, Fairfax County", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("Virginia, Fairfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("US, Fairfax County, Virginia", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("VA, Fairfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
  }
)

test_that(
  "adminify_delim matches delimited, misspelled, multi place name query",
  {
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("US: Virginia, Furfax County", "[:,]")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("US, Virginia, Furfax County", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("USA, Furfax County, Virginia", ",")$ac), collapse = "."),
      "US.VA.059"
    )
    expect_equal(
      paste(Filter(Negate(is.na), adminify_delim("VA, Furfax County, US", ",")$ac), collapse = "."),
      "US.VA.059"
    )
  }
)

## adminify_regex

test_that(
  "adminify_regex returned values are all NA for non-match",
  {
    geo <- adminify_regex("", list(pattern = "(.+)", names = c("ac0")))
    expect_equal(all(is.na(c(geo$id, geo$ac))), T)
  }
)

test_that(
  "adminify_regex matches one place name query",
  {
    expect_equal(
      paste(
        Filter(
          Negate(is.na),
          adminify_regex("United States", list(pattern = "(.+)", names = c("ac0")))$ac
        ),
        collapse = "."
      ),
      "US"
    )
    expect_equal(
      paste(
        Filter(
          Negate(is.na),
          adminify_regex("Fairfax County", list(pattern = "(.+)", names = c("ac2")))$ac
        ),
        collapse = "."
      ),
      "059"
    )
  }
)

test_that(
  "adminify_regex matches multi place name query",
  {
    expect_equal(
      paste(
        Filter(
          Negate(is.na),
          adminify_regex(
            "US: Fairfax County, Virginia",
            list(pattern = "(.+):\\s*(.+)\\s*,\\s*(.+)", names = c("ac0", "ac2", "ac1"))
          )$ac
        ),
        collapse = "."
      ),
      "US.VA.059"
    )
  }
)

test_that(
  "adminify_regex matches misspelled, multi place name query",
  {
    expect_equal(
      paste(
        Filter(
          Negate(is.na),
          adminify_regex(
            "USA: Furfax County, Virginia",
            list(pattern = "(.+):\\s*(.+)\\s*,\\s*(.+)", names = c("ac0", "ac2", "ac1"))
          )$ac
        ),
        collapse = "."
      ),
      "US.VA.059"
    )
  }
)
