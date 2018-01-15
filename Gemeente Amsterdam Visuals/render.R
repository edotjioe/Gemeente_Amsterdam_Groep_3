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
get_table <- function(df) {
  DT::renderDataTable(df, filter = 'top', options = list(pageLength = 50))
}

# Comparing districts per theme (line graph)
render_graph <- function(theme, district_one, district_two) {
  plot <- renderPlotly({
    
    theme_id <- statistics %>%
      filter(statistics_variable == theme) %>%
      select(statistics_id)

    factscompare <- facts %>%
      filter(statistics_id == as.numeric(theme_id)) %>%
      select(value, statistics_id, locations_id, year)

    chart_data <- factscompare %>% 
      inner_join(locations, by = "locations_id") %>%
      inner_join(statistics, by = "statistics_id") %>%
      group_by(year, district_name) %>%
      summarise(value = sum(value))
    
    district_one <- chart_data %>%
      filter(district_name == district_one)
    district_two <- chart_data %>%
      filter(district_name == district_two)
    
    final <- data.frame(unique(chart_data$year), 
                        district_one$value, 
                        district_two$value)
    
    return(plot_ly(final, x = final$unique.chart_data.year., y = final$district_one.value, name = district_one$district_name, type = 'scatter', mode = 'lines') %>%
             add_trace(y = final$district_two.value, name = district_two$district_name, mode = 'lines') %>%
             config(displayModeBar = FALSE))
  })
  
  return(plot)
}

# Comparing neighbourhoods per theme (line graph)
render_graph2 <- function(theme, neighbourhood_one, neighbourhood_two) {
  plot <- renderPlotly({
    # 1 - percentage
    # 2 - absoluut
    # 3 - rapportcijfer
    # 4 - index
    # 5 - gemiddelde
    # 6 - per 1000
    # 7 - 5-puntsschaal
    # 8 - coefficient
    
    theme_id <- statistics %>%
      filter(statistics_variable == theme) %>%
      select(statistics_id)

    factscompare <- facts %>%
      filter(statistics_id == as.numeric(theme_id)) %>%
      select(value, statistics_id, locations_id, year)
    
    chart_data <- factscompare %>% 
      inner_join(locations, by = "locations_id") %>%
      inner_join(statistics, by = "statistics_id")
    
    neighbourhood_one <- chart_data %>%
      filter(neighbourhood_name == neighbourhood_one)
    neighbourhood_two <- chart_data %>%
      filter(neighbourhood_name == neighbourhood_two)
    
    final <- data.frame(unique(chart_data$year), 
                        neighbourhood_one$value, 
                        neighbourhood_two$value)
    str(neighbourhood_one)
    return(plot_ly(final, x = final$unique.chart_data.year., y = final$neighbourhood_one.value, name = neighbourhood_one$neighbourhood_name, type = 'scatter', mode = 'lines') %>%
             add_trace(y = final$neighbourhood_two.value, name = neighbourhood_two$neighbourhood_name, mode = 'lines') %>%
             config(displayModeBar = FALSE))
  })
  
  return(plot)
}

render_graph3 <- function(stat1, stat2, location) {
  plot <- renderPlotly({
    
    statistics_id_1 <- statistics[statistics$statistics_variable == stat1, "statistics_id"]
    statistics_id_2 <- statistics[statistics$statistics_variable == stat2, "statistics_id"]
    
    neighbourhood_id <- locations[locations$district_name == input$neighboorhoud_corr, "locations_id"]
    
    stat1_df <- facts[facts$statistics_id == statistics_id_1 & facts$locations_id == neighbourhood_id, c(4, 5)]
    stat2_df <- facts[facts$statistics_id == statistics_id_2 & facts$locations_id == neighbourhood_id, c(4, 5)]
    
    return(
         plot_ly(x = stat1_df$value, y = stat1_df$year) #%>%
         #add_trace(x = stat1$value, y = stat1$year, name = paste0(), mode = 'lines') #%>%
         # add_trace(x = stat2$value, y = stat2) %>%
         # config(displayModeBar = FALSE)
       )
  })
  
  return(plot)
}

# Render the stat dropdown based on the selected theme
update_stat_select <- function(session, theme, input_select) {
  updateSelectInput(session,
                    input_select,
                    choices = split(statistics[statistics$theme_name == theme,]$statistics_variable,
                                    statistics[statistics$theme_name == theme,]$statistics_name))
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