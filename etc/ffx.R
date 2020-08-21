ggsave(
  file.path("man", "figures", "ffx.svg"),
  filter(map_data("county"), region == "virginia", subregion == "fairfax") %>%
    ggplot() +
    geom_polygon(aes(long, lat), fill = "#3F562A") +
    theme_minimal() +
    theme(
      axis.title = element_blank(),
      axis.text = element_blank(),
      panel.grid = element_blank()
    )
)
