## -----------------------------------------------------------------------------
library(neogeonames)
df <- read.delim(system.file("extdata", "feature.tsv", package = "neogeonames"))
country <- unique(df$country)
geo <- lapply(country, adminify, delim = "[:,]")
df.ac <- data.frame(id = 1:length(geo), country = country, do.call(rbind, lapply(geo, `[[`, "ac")))
df.id <- data.frame(id = 1:length(geo), country = country, do.call(rbind, lapply(geo, `[[`, "id")))

## -----------------------------------------------------------------------------
knitr::kable(head(df.ac))

## -----------------------------------------------------------------------------
knitr::kable(head(df.id))

## -----------------------------------------------------------------------------
# remove rows with missing country_code
df.coor <- df.id[!is.na(df.id$ac0), ]
# set admin codes with no parent code to NA, since they lack support
df.coor <- apply(cbind(df.coor, NA), 1, function(row) 
  if (!is.na(j <- which(is.na(row))[1])) row[j - 1]
)

# merge coordinate data
df.coor <- merge(
  data.frame(id = names(df.coor), geonameid = df.coor),
  neogeonames::geoname[c("geonameid", "latitude", "longitude")],
  by = "geonameid",
  all.x = T
)

# merge with admin codes and original data
df.coor <- merge(df.ac, df.coor, by = "id", all.x = T)
df.geo <- merge(df, df.coor[2:ncol(df.coor)], by = "country", all.x = T)
keys <- c("country", "ac0", "ac1", "ac2", "ac3", "ac4", "latitude", "longitude")
knitr::kable(head(unique(df.geo[keys])))

