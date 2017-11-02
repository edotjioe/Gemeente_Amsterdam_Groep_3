library(RMySQL)

load_map_neightbourhood <- function() {
  return(geojsonio::geojson_read("datafiles/GEBIED_BUURTEN.json", what = "sp", stringsAsFactor = FALSE))
}

load_map_facts <- function() {
  con <- dbConnect(RMySQL::MySQL(), 
                   dbname = "zbekhofl001",
                   host = "oege.ie.hva.nl", 
                   user = "bekhofl001", 
                   password = "ovv2atL4IgRBjd", 
                   client.flag = CLIENT_MULTI_STATEMENTS)
  dbListTables(con)
  
  facts <- dbGetQuery(con, "SELECT * FROM facts WHERE year = 2017 AND statistics_id = 1")
  locations <- load_map_locations()
  
  temp <- facts[which(facts$year == 2017 & facts$statistics_id == 1), ]
  map_fact <- data.frame(locations, value = temp[match(locations$locations_id, temp$locations_id), "value"])
  
  
  dbDisconnect(con)
  
  return(map_fact)
}

load_map_statistics <- function() {
  con <- dbConnect(RMySQL::MySQL(), 
                   dbname = "zbekhofl001",
                   host = "oege.ie.hva.nl", 
                   user = "bekhofl001", 
                   password = "ovv2atL4IgRBjd", 
                   client.flag = CLIENT_MULTI_STATEMENTS)
  dbListTables(con)
  
  statistics <- dbGetQuery(con, "SELECT * FROM statistics")
  
  dbDisconnect(con)  
  
  return(statistics)
}

load_map_locations <- function() {
  con <- dbConnect(RMySQL::MySQL(), 
                   dbname = "zbekhofl001",
                   host = "oege.ie.hva.nl", 
                   user = "bekhofl001", 
                   password = "ovv2atL4IgRBjd", 
                   client.flag = CLIENT_MULTI_STATEMENTS)
  dbListTables(con)
  
  locations <- dbGetQuery(con, "SELECT * FROM locations")
  
  temp <- load_map_neightbourhood()
  locations <- locations %>% slice(match(temp$Buurt_code, locations$neighbourhood_code))
  
  dbDisconnect(con)  
  
  return(locations)
}

load_color_scheme <- function() {
  return(colorNumeric("viridis", NULL))
}


locations <- load_map_locations()
statistics <- load_map_statistics()
map_fact <- load_map_facts()
neightbourhood_map <- load_map_neightbourhood()
pal <- load_color_scheme()
