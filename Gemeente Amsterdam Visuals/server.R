# install.packages("ggplot2")
# install.packages("leaflet")
# install.packages("dplyr")
# install.packages("RMySQL")
# install.packages("geojsonio")

function(input, output, session) {
  library(ggplot2)
  library(leaflet)
  library(dplyr)
  library(RMySQL)
  library(geojsonio)
  
  if(!is.null(map_fact)) {
    # Data transfer to SQL datawarehouse 
  }
  
  # Combine the selected variables into a new data frame
  output$map <- renderLeaflet({
    leaflet(data = neightbourhood_map) %>%
      addTiles(group = "OSM",
               options = providerTileOptions(minZoom = 12, maxZoom = 14)) %>%
      addPolygons(stroke = TRUE, 
                  weight = 2, 
                  smoothFactor = 1, 
                  fillOpacity = 0.7, 
                  color = "white",
                  fillColor = ~pal(log10(map_fact$value)),
                  highlightOptions = highlightOptions(color = "red", 
                                                      weight = 4,
                                                      bringToFront = TRUE), 
                  label = paste(locations$neighbourhood_name, " - ", map_fact$value)) %>%
      addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9, title = statistics[1,3])
  })
  
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
    
    leafletProxy("map", data = neightbourhood_map) %>%
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
      addLegend(pal = pal, values = ~map_fact$value, opacity = 0.9, title = input$stat)
  })
  
  output$dynamicsidebar <- renderMenu({
    sidebarMenu(
      
    )
  })
  
  observeEvent(input$map_shape_click, { # update the location selectInput on map clicks
    p <- input$map_shape_click
    if(is.null(p))
      return()
    text<-paste("Lattitude ", p$lat, "Longtitude ", p$lng)
    text2<-paste("You've selected point ", p$id)
    leafletProxy("map") %>%
      clearPopups() %>%
      addPopups( p$lat, p$lng, text)
  })
  
}