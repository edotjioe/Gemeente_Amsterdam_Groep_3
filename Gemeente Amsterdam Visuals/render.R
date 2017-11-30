# Render intial map
render_map <- function() {
  return(renderLeaflet({
    leaflet(data = neightbourhood_map) %>%
      addTiles(group = "OSM",
               options = providerTileOptions(minZoom = 12, maxZoom = 14)) %>%
      addPolygons(
        stroke = TRUE,
        weight = 2,
        smoothFactor = 1,
        fillOpacity = 0.7,
        color = "white",
        fillColor = ~ pal(log10(map_fact$value)),
        highlightOptions = highlightOptions(
          color = "red",
          weight = 4,
          bringToFront = TRUE
        ),
        label = paste(locations$neighbourhood_name, " - ", map_fact$value),
        layerId = ~Buurt_code
      ) %>%
      addLegend(
        pal = pal,
        values = ~ map_fact$value,
        opacity = 0.9,
        title = statistics[1, "statistics_variable"]
      )
  }))
}

# Update map on a year or stat change
update_map <- function(year, stat) {
  query <- paste("SELECT * FROM facts WHERE year = ", year, " AND statistics_id = ", 
                statistics[statistics$statistics_variable == stat, "statistics_id"])
  stats <- get_query(query)
  
  map_fact <- data.frame(locations, value = stats[match(locations$locations_id, stats$locations_id), "value"])
  
  map <- leafletProxy("map", data = neightbourhood_map) %>%
    clearShapes() %>%
    clearControls() %>%
    addPolygons(stroke = TRUE, 
                weight = 2, 
                smoothFactor = 1, 
                fillOpacity = 0.7, 
                color = "white",
                fillColor = ~pal(map_fact$value),
                highlightOptions = highlightOptions(color = "red", 
                                                    weight = 4,
                                                    bringToFront = TRUE), 
                label = paste(map_fact$neighbourhood_name, " - ", map_fact$value),
                layerId = ~Buurt_code) %>%
    addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9, title = stat)
}

# Render the stat dropdown based on the selected theme
update_stat_select <- function(session, theme) {
  return(updateSelectInput(session, "stat", choices = split(statistics[statistics$theme_name == theme,]$statistics_variable, statistics[statistics$theme_name == theme,]$statistics_name)))
}

add_to_map_selection <- function(click) {
  print(click$id)
}