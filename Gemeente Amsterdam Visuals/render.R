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
        label = paste(locations$neighbourhood_name, " - ", map_fact$value)
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
                label = paste(map_fact$neighbourhood_name, " - ", map_fact$value)) %>%
    addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9, title = stat)
  
  return(map)
}

# Display graph based on selected area on map
show_map_graph <- function(mouse) {
  if(is.null(mouse))
    return()
  text<-paste("Lattitude ", mouse$lat, "Longtitude ", mouse$lng)
  text2<-paste("You've selected point ", mouse$id)
  map <- leafletProxy("map") %>%
    clearPopups() %>%
    addPopups(mouse$lng, mouse$lat, text)
  
  return(map)
}