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
        title = statistics[1, 3]
      )
  }))
}

# Update map on a year or stat change
update_map <- function(year, stat) {
  query <- paste("SELECT * FROM facts WHERE year = ", year, " AND statistics_id = ", 
                statistics[statistics$statistics_variable == stat, 1])
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
  
  return(map)
}

# Display graph based on selected area on map
render_map_graph <- function(mouse, stat) {
  if(is.null(mouse))
    return()
  
  fact <- get_query(paste0("SELECT * FROM facts WHERE location_id = ", locations["neighbourhood_code" == mouse$id, "locations_id"], " AND statistics_id = ", stat))

  plot <- ggplot(fact, aes(x = ~year, y = ~value)) + 
    geom_point()
  
  return(renderPlot(plot))
}