# Install all libraries here!
# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("ggplot2")
# install.packages("leaflet")
# install.packages("dplyr")
# install.packages("RMySQL")
# install.packages("geojsonio")
# install.packages("plotly")
# install.packages("shinyjs")

# Load all libraries here!
library(shiny)
library(shinydashboard)
library(ggplot2)
library(leaflet)
library(dplyr)
library(RMySQL)
library(geojsonio)
library(plotly)
library(shinyjs)

load_map_neightbourhood <- function() {
  return(geojsonio::geojson_read("datafiles/GEBIED_BUURTEN.json", what = "sp", stringsAsFactor = FALSE))
}

load_map_facts <- function() {
  facts <- get_query("SELECT * FROM facts WHERE year = 2017 AND statistics_id = 1")
  locations <- load_map_locations()
  
  temp <- facts[which(facts$year == 2017 & facts$statistics_id == 1), ]
  map_fact <- data.frame(locations, value = temp[match(locations$locations_id, temp$locations_id), "value"])
  
  return(map_fact)
}

load_map_statistics <- function() {
  return(get_query("SELECT * FROM statistics"))
}

load_map_locations <- function() {
  locations <- get_query("SELECT * FROM locations")
  
  temp <- load_map_neightbourhood()
  locations <- locations %>% slice(match(temp$Buurt_code, locations$neighbourhood_code))

  return(locations)
}

load_color_scheme <- function() {
  return(colorNumeric("viridis", NULL))
}

# Create environment variables
locations <- load_map_locations()
statistics <- load_map_statistics()
map_fact <- load_map_facts()
neightbourhood_map <- load_map_neightbourhood()
pal <- load_color_scheme()
