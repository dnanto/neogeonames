library(ggplot2)
ggsave(
  file.path("man", "figures", "ffx.svg"),
  ggplot(dplyr::filter(map_data("county"), region == "virginia", subregion == "fairfax")) +
  geom_polygon(aes(long, lat), fill = "#A53A2B") +
  theme_minimal() +
  theme(
    axis.title = element_blank(),
    axis.text = element_blank(),
    panel.grid = element_blank()
  )
)
