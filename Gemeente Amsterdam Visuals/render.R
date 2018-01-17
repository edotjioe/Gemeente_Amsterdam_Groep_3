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
  colNames <- c("Statestiek", "Buurt", "Jaar", "Waarde", "Eenheid")
  
  return(DT::renderDataTable(facts_merged, filter = "top", options = list(pageLength = 50), colnames = c("Statestiek", "Buurt", "Jaar", "Waarde", "Eenheid")))
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
    
    district_data_one <- chart_data %>%
      filter(district_name == district_one)
    district_data_two <- chart_data %>%
      filter(district_name == district_two)
    
    final <- data.frame(unique(chart_data$year), 
                        district_data_one$value, 
                        district_data_two$value)
    
    return(plot_ly(final, x = final$unique.chart_data.year, y = final$district_data_one.value, name = district_data_one$district_name, type = 'scatter', mode = 'lines') %>%
             add_trace(y = final$district_data_two.value, name = district_data_two$district_name, mode = 'lines') %>%
             config(displayModeBar = FALSE))
  })
  
  return(plot)
}

# Comparing neighbourhoods per theme (line graph)
render_graph2 <- function(theme, neighbourhood_one, neighbourhood_two) {
  plot <- renderPlotly({
    
    theme_id <- statistics %>%
      filter(statistics_variable == theme) %>%
      select(statistics_id)

    factscompare <- facts %>%
      filter(statistics_id == as.numeric(theme_id)) %>%
      select(value, statistics_id, locations_id, year)
    
    chart_data <- factscompare %>% 
      inner_join(locations, by = "locations_id") %>%
      inner_join(statistics, by = "statistics_id")
    
    neighbourhood_data_one <- chart_data %>%
      filter(neighbourhood_name == neighbourhood_one)
    neighbourhood_data_two <- chart_data %>%
      filter(neighbourhood_name == neighbourhood_two)
    
    final <- data.frame(unique(chart_data$year), 
                        neighbourhood_data_one$value, 
                        neighbourhood_data_two$value)
    
    return(
      plot_ly(final, x = final$unique.chart_data.year, y = final$neighbourhood_data_one, name = neighbourhood_data_one$neighbourhood_name, type = 'scatter', mode = 'lines') %>%
      add_trace(y = final$neighbourhood_data_two.value, name = neighbourhood_data_two$neighbourhood_name, mode = 'lines') %>%
      config(displayModeBar = FALSE))
  })
  
  return(plot)
}

render_graph3 <- function(statistic_one, statistic_two, location) {
  plot <- renderPlotly({
    statistic_id_one <- statistics[statistics$statistics_variable == statistic_one, "statistics_id"]
    statistic_id_two <- statistics[statistics$statistics_variable == statistic_two, "statistics_id"]
    
    neighbourhood_ids <- locations[locations$district_code == location, "locations_id"] %>%
      as.data.frame()
    
    statistic_one_df <- facts %>%
      filter(statistics_id == statistic_id_one) %>%
      filter(locations_id %in% neighbourhood_ids$locations_id) %>%
      group_by(year) %>%
      summarise(
        value = sum(value)
      ) %>%
      as.data.frame()
<<<<<<< Updated upstream
    
    statistic_two_df <- facts %>%
      filter(statistics_id == statistic_id_two) %>%
      filter(locations_id %in% neighbourhood_ids$locations_id) %>%
      group_by(year) %>%
      summarise(
        value = sum(value)
      ) %>%
      as.data.frame()

    print(neighbourhood_ids)
    str(statistic_one_df)
    print(statistic_two_df)
    
=======
    
    statistic_two_df <- facts %>%
      filter(statistics_id == statistic_id_two) %>%
      filter(locations_id %in% neighbourhood_ids$locations_id) %>%
      group_by(year) %>%
      summarise(
        value = sum(value)
      ) %>%
      as.data.frame()

    print(neighbourhood_ids)
    str(statistic_one_df)
    print(statistic_two_df)
    
>>>>>>> Stashed changes
    # statistic_one_df <- facts[facts$statistics_id == statistic_id_one & facts$locations_id == neighbourhood_id, c(4, 5)]
    # statistic_two_df <- facts[facts$statistics_id == statistic_id_two & facts$locations_id == neighbourhood_id, c(4, 5)]

    # Normalisatie deel
    # s_one <- (statistic_one_df$value-min(statistic_one_df$value))/(max(statistic_one_df$value)-min(statistic_one_df$value))
    # s_two <- (statistic_two_df$value-min(statistic_two_df$value))/(max(statistic_two_df$value)-min(statistic_two_df$value))

    statistic_name_one <- statistics[statistics$statistics_variable == statistic_one, "statistics_name"]
    statistic_name_two <- statistics[statistics$statistics_variable == statistic_two, "statistics_name"]

    return(
         plot_ly(x = statistic_one_df$year, y = statistic_one_df$value, name = statistic_name_one, type = 'scatter', mode = 'lines') %>%
         add_trace(x = statistic_two_df$year, y = statistic_two_df$value, name = statistic_name_two, mode = 'lines') %>%
         layout(legend = list(orientation = 'h'), title = "Vergelijking lijngrafiek")
       )
  })
  return(plot)
}

render_graph4 <- function(statistic_one, statistic_two, location) {
  plot <- renderPlotly({
    
    # Sort the data frames by year
    cor_1_facts_sum <- cor_1_facts_sum[order(cor_1_facts_sum$year),]
    cor_2_facts_sum <- cor_2_facts_sum[order(cor_2_facts_sum$year),]
    
    statistic_id_one <- statistics[statistics$statistics_variable == statistic_one, "statistics_id"]
    statistic_id_two <- statistics[statistics$statistics_variable == statistic_two, "statistics_id"]
    
    neighbourhood_id <- as.numeric(locations[locations$neighbourhood_name == location, "locations_id"])
    
    statistic_one_df <- facts[facts$statistics_id == statistic_id_one & facts$locations_id == neighbourhood_id, c(4, 5)]
    statistic_two_df <- facts[facts$statistics_id == statistic_id_two & facts$locations_id == neighbourhood_id, c(4, 5)]
    
    min_index <- max(min(statistic_one_df$year), min(statistic_two_df$year))
    max_index <- min(max(statistic_one_df$year), max(statistic_two_df$year))
    
    statistic_one_df <- statistic_one_df[statistic_one_df$year > min_index & statistic_one_df$year < max_index,]
    statistic_two_df <- statistic_two_df[statistic_two_df$year > min_index & statistic_two_df$year < max_index,]
    
    statistic_name_one <- list(title = statistics[statistics$statistics_variable == statistic_one, "statistics_name"])
    statistic_name_two <- list(title = statistics[statistics$statistics_variable == statistic_two, "statistics_name"])
    
    return(
      plot_ly(x = statistic_one_df$value, y = statistic_two_df$value, type = 'scatter') %>%
      layout(xaxis = statistic_name_one, yaxis = statistic_name_two, title = "Correlatie grafiek")
    )
  })
  return(plot)
}

# Initiate correlation map 
correlation_map <- function() {
  leaflet_map_index <- as.numeric(match(selected_district_corr_map, district_map$Stadsdeel_code))
  
  map <- leaflet(data = district_map) %>%
    addTiles(group = "OSM",
             options = providerTileOptions(minZoom = 10, maxZoom = 26)) %>%
    addPolygons(
      stroke = TRUE,
      weight = 2,
      smoothFactor = 1,
      fillOpacity = 0.7,
      color = "white",
      highlightOptions = highlightOptions(
        color = "red",
        weight = 4,
        bringToFront = TRUE
      ),
      label = paste(district_map$Stadsdeel),
      layerId = ~ Stadsdeel_code
     ) %>%
     removeShape(layerId = selected_district_corr_map) %>%
     addPolygons(layerId = selected_district_corr_map,
                fillColor = "red",
                data = district_map[leaflet_map_index,],
                stroke = TRUE,
                weight = 2,
                smoothFactor = 1,
                fillOpacity = 0.7,
                color = "white",
                highlightOptions = highlightOptions(color = "red",
                                                    weight = 4,
                                                    bringToFront = TRUE),
                label = paste(district_map[leaflet_map_index, ]$Stadsdeel)
    )
  return(map)
}


update_correlation_map <- function(code) {
  new_selected_district_map <- code

  leaflet_map_index_new <- as.numeric(match(new_selected_district_map, district_map$Stadsdeel_code))
  leaflet_map_index <- as.numeric(match(selected_district_corr_map, district_map$Stadsdeel_code))

  leafletProxy("mapSelectCorr") %>%
    removeShape(layerId = selected_district_corr_map) %>%
    removeShape(layerId = new_selected_district_map) %>%
    addPolygons(layerId = selected_district_corr_map,
                fillColor = "white",
                data = district_map[leaflet_map_index,],
                stroke = TRUE,
                weight = 2,
                smoothFactor = 1,
                fillOpacity = 0.7,
                color = "white",
                highlightOptions = highlightOptions(color = "red",
                                                    weight = 4,
                                                    bringToFront = TRUE),
                label = paste(district_map[leaflet_map_index,]$Stadsdeel)
    ) %>%
    addPolygons(layerId = new_selected_district_map,
                fillColor = "red",
                data = district_map[leaflet_map_index_new,],
                stroke = TRUE,
                weight = 2,
                smoothFactor = 1,
                fillOpacity = 0.7,
                color = "grey",
                highlightOptions = highlightOptions(color = "red",
                                                    weight = 4,
                                                    bringToFront = TRUE),
                label = paste(district_map[leaflet_map_index_new,]$Stadsdeel)
    )

  assign("selected_district_corr_map", new_selected_district_map, envir = globalenv())
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

# Rendering the plot with muliple neighbourhoods
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

get_corr_message <- function(stat1, stat2, neighbourhood) {
  if(stat1 == stat2) {
    return(renderText("Selecteer twee verschillende statestieken om te vergelijken"))
  }
  print(stat1)
  print(stat2)
  stat1_row <- statistics[statistics$statistics_variable == stat1,]
  stat2_row <- statistics[statistics$statistics_variable == stat2,]
  print(stat1_row)
  print(stat2_row)
  corr <- correlations[
    (correlations$statistics_1_id == stat1_row$statistics_id & correlations$statistics_2_id == stat2_row$statistics_id)
    |
    (correlations$statistics_1_id == stat2_row$statistics_id & correlations$statistics_2_id == stat1_row$statistics_id),]
  print(corr)
  if(nrow(corr) == 0) {
    return(renderText(paste("Voor", stat1_row$statistics_name, "en", stat2_row$statistics_name, "kan geen correlatie berkend worden")))
  }
  
  if(corr$value >= 0.8) {
    return(renderText(paste(stat1_row$statistics_name, "en", stat2_row$statistics_name, "hebben een verband met elkaar")))
  } else {
    return(renderText(paste("Er is geen verband tussen", stat1_row$statistics_name, "en", stat2_row$statistics_name)))
  }
}
