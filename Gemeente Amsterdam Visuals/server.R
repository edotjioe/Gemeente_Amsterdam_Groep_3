

function(input, output, session) {
  library(ggplot2)
  library(leaflet)
  library(dplyr)
  library(RMySQL)
  
  if(!is.null(map_fact)) {
    # Data transfer to SQL datawarehouse 
    con <- dbConnect(RMySQL::MySQL(), 
                     dbname = "zbekhofl001",
                     host = "oege.ie.hva.nl", 
                     user = "bekhofl001", 
                     password = "ovv2atL4IgRBjd", 
                     client.flag = CLIENT_MULTI_STATEMENTS)
    dbListTables(con)
    
    facts <- dbGetQuery(con, "SELECT * FROM facts WHERE year = 2017 AND statistics_id = 1")
    locations <- dbGetQuery(con, "SELECT * FROM locations")
    statistics <- dbGetQuery(con, "SELECT * FROM statistics")
    
    buurten_map <- geojsonio::geojson_read("datafiles/GEBIED_BUURTEN.json", what = "sp", stringsAsFactor = FALSE)
    locations <- locations %>% slice(match(buurten_map$Buurt_code, locations$neighbourhood_code))
    temp <- facts[which(facts$year == 2017 & facts$statistics_id == 1), ]
    map_fact <- data.frame(locations, value = temp[match(locations$locations_id, temp$locations_id), "value"])
    
    dbDisconnect(con)
  }
  
  observe({
    temp <- paste("SELECT * FROM facts WHERE year = ", input$year, " AND statistics_id = ", 
                  statistics[statistics$statistics_variable == input$stat, 1])
    con <- dbConnect(RMySQL::MySQL(), 
                     dbname = "zbekhofl001",
                     host = "oege.ie.hva.nl", 
                     user = "bekhofl001", 
                     password = "ovv2atL4IgRBjd", 
                     client.flag = CLIENT_MULTI_STATEMENTS)
    dbListTables(con)
    
    stats <- dbGetQuery(con, temp)
    
    dbDisconnect(con)
    
    map_fact <- data.frame(locations, value = stats[match(locations$locations_id, stats$locations_id), "value"])
    
    leafletProxy("map", data = buurten_map) %>%
      clearShapes() %>%
      clearTiles() %>%
      clearControls() %>%
      addTiles() %>%
      addPolygons(stroke = TRUE, 
                  weight = 2, 
                  smoothFactor = 1, 
                  fillOpacity = 0.7, 
                  color = "red",
                  fillColor = ~pal(map_fact$value),
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 3,
                                                      bringToFront = TRUE), 
                  label = paste(map_fact$neighbourhood_name, " - ", map_fact$value)) %>%
      addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9,
                labFormat = labelFormat(transform = function(x) round(10^x)))
  })
  
  
  # Combine the selected variables into a new data frame
  output$map <- renderLeaflet({
    pal <- colorNumeric("viridis", NULL)
    
    leaflet(data = buurten_map) %>%
      addTiles() %>%
      addPolygons(stroke = TRUE, 
                  weight = 2, 
                  smoothFactor = 1, 
                  fillOpacity = 0.7, 
                  color = "red",
                  fillColor = ~pal(log10(map_fact$value)),
                  highlightOptions = highlightOptions(color = "white", 
                                                      weight = 3,
                                                      bringToFront = TRUE), 
                  label = paste(locations$neighbourhood_name, " - ", map_fact$value)) %>%
      addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9,
                labFormat = labelFormat(transform = function(x) round(10^x)))
  })
  
}