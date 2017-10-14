#install.packages("geojsonio")
#install.packages("leaflet")

library(geojsonio)
library(leaflet)

buurten_map <- geojsonio::geojson_read("C:/Users/edotj/Documents/R/Datasets/GEBIED_BUURTEN.json",
                                      what = "sp")

leaflet(data = buurten_map) %>%
  addTiles() %>%
  addPolygons(stroke = TRUE, weight = 1, smoothFactor = 1, fillOpacity = 0.5, color = "red",
              highlightOptions = highlightOptions(color = "white", weight = 2,
                                                  bringToFront = TRUE), label = buurten_map$Buurt)

