# Render initial map
render_map <- function(year, stat) {
  stat_id <- statistics[which(statistics$statistics_variable == stat),]$statistics_id
  map_facts <- facts[which(facts$year == year & facts$statistics_id == stat_id),]
  
  map_facts <- map_facts %>%
    right_join(locations, by = "locations_id")
  print(head(map_facts))

  map <- leaflet(data = neightbourhood_map) %>%
    addTiles(group = "OSM",
             options = providerTileOptions(minZoom = 12, maxZoom = 14)) %>%
    addPolygons(
      stroke = TRUE,
      weight = 2,
      smoothFactor = 1,
      fillOpacity = 0.7,
      color = "white",
      fillColor = ~ pal(map_facts$value),
      highlightOptions = highlightOptions(
        color = "red",
        weight = 4,
        bringToFront = TRUE
      ),
      label = paste(locations$neighbourhood_name, " - ", map_facts$value),
      layerId = ~ Buurt_code
    ) %>%
    addLegend(
      pal = pal,
      values = ~ map_facts$value,
      opacity = 0.9,
      title = statistics[stat_id, "statistics_name"]
    )
  
  return(map)
}

# Display plot under the datatable
get_table <- function(df) {
  DT::renderDataTable(df, options = list(pageLength = 50))
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

# Render the stat dropdown based on the selected theme
update_stat_select <- function(session, theme) {
  return(updateSelectInput(session, "stat", choices = split(statistics[statistics$theme_name == theme,]$statistics_variable, statistics[statistics$theme_name == theme,]$statistics_name)))
}

# Map selection code
# add_to_map_selection <- function(click) {
#   if(click$id %in% selected_locations) {
#     assign("selected_locations", selected_locations[which(click$id != selected_locations)], envir = globalenv())
#   } else {
#     assign("selected_locations", c(selected_locations, click$id), envir = globalenv())
#   }
#   
#   update_seleted_polys(click$id, year, stat)
# }

# update_seleted_polys <- function(id, year, stat) {
#   leaflet_map_index <- as.numeric(match(id, locations$neighbourhood_code))
# 
#   stat_id <- statistics[which(statistics$statistics_variable == stat)]$statistics_id
#   map_facts <- facts[which(facts$year == year && facts$statistics_id == stat_id)]
# 
#   location_poly <- map_facts[leaflet_map_index,]
# 
#   if(id %in% selected_locations) {
#     color <- "blue"
#   } else {
#     color <- ~pal(map_facts$value)[leaflet_map_index]
#   }
# 
#   leafletProxy("map") %>%
#     removeShape(layerId = id) %>%
#     addPolygons(layerId = id,
#                 fillColor = color,
#                 data = neightbourhood_map[leaflet_map_index,],
#                 stroke = TRUE,
#                 weight = 2,
#                 smoothFactor = 1,
#                 fillOpacity = 0.7,
#                 color = "white",
#                 highlightOptions = highlightOptions(color = "red",
#                                                     weight = 4,
#                                                     bringToFront = TRUE),
#                 label = paste(location_poly$neighbourhood_name, " - ", location_poly$value)
#                 )
# }