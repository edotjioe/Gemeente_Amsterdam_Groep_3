# Render initial map
render_map <- function(year, stat) {
  stat_id <- statistics[which(statistics$statistics_variable == stat),]$statistics_id
  map_facts <- facts[which(facts$year == year & facts$statistics_id == stat_id),]
  
  map_facts <- map_facts %>%
    right_join(locations, by = "locations_id")
  
  map <- leaflet(data = neighbourhood_map) %>%
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

colorPicker <- function(neighbourhood_code) {
  colors <- data.frame(code = neighbourhood_code)
  colors$color <- "grey"
  
  colors[which(colors$code == selected_locations), "color"] = "blue"
  
  return(colors$color)
}

render_select_map <- function(click) {
  map <- leaflet(data = neighbourhood_map) %>%
    addTiles(group = "OSM",
             options = providerTileOptions(minZoom = 10, maxZoom = 14)) %>%
    addPolygons(
      stroke = TRUE,
      weight = 2,
      smoothFactor = 1,
      fillOpacity = 0.7,
      color = colorPicker(neighbourhood_map$Buurt_code),
      highlightOptions = highlightOptions(
        color = "red",
        weight = 4,
        bringToFront = TRUE
      ),
      label = neighbourhood_map$Buurt,
      layerId = ~ Buurt_code
    )
  
  return(map)
}

# Display plot under the datatable
get_facts_table <- function() {
  df <- facts
  
  df <- merge(df, locations, by = "locations_id")
  df <- merge(df, statistics, by = "statistics_id")
  units <- data.frame("unit_id" = c(1, 2, 3, 4, 5, 6, 7, 8), "unit_name" = c("%", "Absoluut", "Rapport", "Index", "Gemiddelde", "Per 1000", "5-puntsschaal", "Coefficient"))
  df <- merge(df, units, by.x = "statistics_unit", by.y = "unit_id")
  
  selectedCols <- c("statistics_name", "neighbourhood_name", "year", "value", "unit_name")
  colNames <- c("Statestiek", "Buurt", "Jaar", "Waarde", "Eenheid")
  
  df <- df[, selectedCols]
  
  return(DT::renderDataTable(df, filter = "top", options = list(pageLength = 50), colnames = colNames))
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

render_graph2 <- function(theme, city_district1, city_district2) {
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
      inner_join(statistics, by = "statistics_id")
    
    stad1 <- chart_data %>%
      filter(neighbourhood_name == city_district1)
    stad2 <- chart_data %>%
      filter(neighbourhood_name == city_district2)
    
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
update_stat_select <- function(session, theme, theme_map_select) {
  updateSelectInput(session,
                    "stat",
                    choices = split(statistics[statistics$theme_name == theme,]$statistics_variable,
                                    statistics[statistics$theme_name == theme,]$statistics_name))
  updateSelectInput(session,
                    "stat_map_select",
                    choices = split(statistics[statistics$theme_name == theme_map_select,]$statistics_variable,
                                    statistics[statistics$theme_name == theme_map_select,]$statistics_name))
}

# Map selection code
add_to_map_selection <- function(click) {
  if(click$id %in% selected_locations) {
    assign("selected_locations", selected_locations[which(click$id != selected_locations)], envir = globalenv())
  } else {
    assign("selected_locations", c(selected_locations, click$id), envir = globalenv())
  }
  
  update_seleted_polys(click$id)
}

update_seleted_polys <- function(id) {
  leaflet_map_index <- as.numeric(match(id, locations$neighbourhood_code))
  location_poly <- locations[leaflet_map_index,]
  
  if(id %in% selected_locations) {
    color <- "blue"
  } else {
    color <- "grey"
  }
  
  leafletProxy("mapSelectMulti") %>%
    removeShape(layerId = id) %>%
    addPolygons(layerId = id,
                fillColor = color,
                data = neighbourhood_map[leaflet_map_index,],
                stroke = TRUE,
                weight = 2,
                smoothFactor = 1,
                fillOpacity = 0.7,
                color = "grey",
                highlightOptions = highlightOptions(color = "red",
                                                    weight = 4,
                                                    bringToFront = TRUE),
                label = location_poly$neighbourhood_name
    )
}

render_select_map_plot <- function(stat) {
  if(length(selected_locations) <= 0) return(renderPlotly(plot_ly()))
  
  location_ids <- locations[match(selected_locations, locations$neighbourhood_code),]$locations_id
  statistic_id <- as.numeric(statistics[statistics$statistics_variable == stat, "statistics_id"])
  
  plot_facts <- data.frame()
  
  for(i in location_ids){
    plot_facts <- rbind(plot_facts, facts[facts$locations_id == i & facts$statistics_id == statistic_id, ])
  }
  
  plot_facts <- left_join(plot_facts, locations)
  
  plot <- plot_facts %>%
    group_by(locations_id) %>%
    plot_ly(
      x = ~year, 
      y = ~value, 
      name = ~neighbourhood_name,
      color = ~neighbourhood_name,
      type = "scatter",
      mode = "lines"
    ) %>%
    layout(yaxis = list(title = statistics[statistic_id,]$statistics_name), xaxis = list(title = "Year"))
  
  return(renderPlotly(plot))
}
