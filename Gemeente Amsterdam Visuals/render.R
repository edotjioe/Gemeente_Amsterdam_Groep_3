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
        layerId = ~ Buurt_code
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
  query <-
    paste("SELECT * FROM facts WHERE year = ",
          year,
          " AND statistics_id = ",
          statistics[statistics$statistics_variable == stat, 1])
  stats <- get_query(query)
  
  map_fact <-
    data.frame(locations, value = stats[match(locations$locations_id, stats$locations_id), "value"])
  
  map <- leafletProxy("map", data = neightbourhood_map) %>%
    clearShapes() %>%
    clearControls() %>%
    addPolygons(
      stroke = TRUE,
      weight = 2,
      smoothFactor = 1,
      fillOpacity = 0.7,
      color = "white",
      fillColor = ~ pal(map_fact$value),
      highlightOptions = highlightOptions(
        color = "red",
        weight = 4,
        bringToFront = TRUE
      ),
      label = paste(map_fact$neighbourhood_name, " - ", map_fact$value),
      layerId = ~ Buurt_code
    ) %>%
    addLegend(
      pal = pal,
      values = ~ map_fact$value,
      opacity = 0.9,
      title = stat
    )
  
  return(map)
}

# Display plot under the datatable
get_table <- function(df) {
  DT::renderDataTable(df,
                      options = list(pageLength = 50))
}

# Display graph based on selected area on map
render_map_graph <- function(mouse, stat) {
  if (is.null(mouse))
    return()
  
  query <-
    paste0(
      "SELECT * FROM facts WHERE locations_id = ",
      locations[locations$neighbourhood_code == mouse$id, ]$locations_id,
      " AND statistics_id = ",
      statistics[statistics$statistics_variable == stat, ]$statistics_id
    )
  fact <- get_query(query)
  
  plot <- ggplot() +
    geom_line(data = fact, aes(x = year, y = value))
  
  return(renderPlot(plot))
}

render_graph <- function(theme, city_district1, city_district2) {
  plot <- renderPlotly({
    # 1 - percentage
    # 2 - absoluut
    # 3 - rapportcijfer
    # 4 - index
    # 5 - gemiddelde
    # 6 - per 1000
    # 7 - 5-puntsschaal
    # 8 - coefficient
    
    statistics_id <- statistics %>%
      filter(statistics_variable == theme) %>%
      select(statistics_id)
    
    factscompare <- get_query(paste("SELECT value, statistics_id, locations_id, year FROM facts WHERE statistics_id = ", statistics_id, ";"))
    
    chart_data <- factscompare %>% 
      inner_join(locations, by = "locations_id") %>%
      inner_join(statistics, by = "statistics_id") %>%
      group_by(year, district_name) %>%
      summarise(value = sum(value))
    
    stad1 <- chart_data %>%
      filter(district_name == city_district1)
    stad2 <- chart_data %>%
      filter(district_name == city_district2)
    
    final <- data.frame(unique(chart_data$year), 
                        stad1$value, 
                        stad2$value)
    
    return(plot_ly(final, x = final$unique.chart_data.year., y = final$stad1.value, name = city_district1, type = 'scatter', mode = 'lines') %>%
      add_trace(y = final$stad2.value, name = city_district2, mode = 'lines') %>%
      config(displayModeBar = FALSE))
  })
  
  return(plot)
}
