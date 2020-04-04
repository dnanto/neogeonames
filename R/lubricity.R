# geonames ata download, parsing, and setup

geonames_download <- function(root = getwd(), url = "http://download.geonames.org/export/dump")
{
  c("countryInfo.txt", "admin1CodesASCII.txt", "admin2Codes.txt") %>%
  sapply(function(target) {
    dest <- file.path(root, target)
    utils::download.file(file.path(url, target), dest)
    dest
  })
}

geonames_read_country <- function(path)
{
  read_lines(path) %>%
  enframe(name = NULL) %>%
  filter(!startsWith(value, "#")) %>%
  pull(value) %>%
  read_tsv(col_names = c(
    "iso", "iso3",	"iso_num", "fips", "country", "capital", "area", "population","continent",
    "tld",	"currency_code", "currency_name", "phone", "postal_code_format", "postal_code_regex",
    "languages", "geonameid", "neighbours", "equivalent_fips_code"
  ))
}

geonames_read_admin_1 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci") %>%
    separate("code", c("iso", "lvl.1"), sep = "\\.", remove = F)
}

geonames_read_admin_2 <- function(path)
{
  read_tsv(path, col_names = c("code", "name", "name_ascii", "geonameid"), col_types = "ccci") %>%
  separate("code", c("iso", "lvl.1", "lvl.2"), sep = "\\.", remove = F)
}

geonames_install <- function(url = "http://download.geonames.org/export/dump")
{
  result <- geonames_download(url = url)
  country <-
    geonames_read_country(result["countryInfo.txt"]) %>%
    rename(name = country) %>%
    select(iso, iso3, name)
  admin1 <-
    geonames_read_admin_1(result["admin1CodesASCII.txt"]) %>%
    select(-name) %>%
    rename(name = name_ascii) %>%
    separate("code", c("iso", "lvl.1"), sep = "\\.", remove = F) %>%
    select(code, iso, lvl.1, name)
  admin2 <-
    geonames_read_admin_2(result["admin2Codes.txt"]) %>%
    select(-name) %>%
    rename(name = name_ascii) %>%
    separate("code", c("iso", "lvl.1", "lvl.2"), sep = "\\.", remove = F) %>%
    select(code, iso, lvl.1, lvl.2, name)
  usethis::use_data(country, admin1, admin2, overwrite = T, compress = "gzip", version = 3)
  null <- file.remove(result)
}
