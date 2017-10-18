install.packages()

library(ggplot2)
library(leaflet)
library(dplyr)
library(RMySQL)

# Data transfer to SQL datawarehouse 
con <- dbConnect(RMySQL::MySQL(), 
                 dbname = "zbekhofl001",
                 host = "oege.ie.hva.nl", 
                 user = "bekhofl001", 
                 password = "ovv2atL4IgRBjd", 
                 client.flag = CLIENT_MULTI_STATEMENTS)
dbListTables(con)

facts <- dbGetQuery(con, "SELECT * FROM facts")
locations <- dbGetQuery(con, "SELECT * FROM locations")
statistics <- dbGetQuery(con, "SELECT * FROM statistics")

function(input, output, session) {
  
  # Combine the selected variables into a new data frame
  output$plot1 <- renderLeaflet({
    
    buurten_map <- geojsonio::geojson_read("C:/Users/edotj/Documents/R/Datasets/GEBIED_BUURTEN.json", what = "sp")
    
    locations <- locations %>% slice(match(buurten_map$Buurt_code, locations$neighbourhood_code))
    
    temp <- facts[which(facts$year == 2017 & facts$statistics_id == 1), ]
    
    map_fact <- data.frame(locations, value = temp[match(locations$locations_id, temp$locations_id), "value"])
    
    rm(temp)
    
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
      addLegend(pal = pal, values = ~log10(map_fact$value), opacity = 1.0,
                labFormat = labelFormat(transform = function(x) round(10^x)))
    
  })
  
}