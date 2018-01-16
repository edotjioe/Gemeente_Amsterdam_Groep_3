# install all libraries here!
# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("ggplot2")
# install.packages("leaflet")
# install.packages("dplyr")
# install.packages("RMySQL")
# install.packages("geojsonio")
# install.packages("plotly")
# install.packages("shinyjs")
# install.packgess("DT")

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
library(DT)

load_map_neighbourhood <- function() {
  return(geojsonio::geojson_read("datafiles/GEBIED_BUURTEN.json", what = "sp", stringsAsFactor = FALSE))
}

load_facts <- function() {
  return(get_query("SELECT * FROM facts"))
}

load_statistics <- function() {
  return(get_query("SELECT * FROM statistics"))
}

load_locations <- function() {
  locations <- get_query("SELECT * FROM locations")
  
  temp <- load_map_neighbourhood()
  locations <- locations %>% slice(match(temp$Buurt_code, locations$neighbourhood_code))
  
  return(locations)
}

load_color_scheme <- function() {
  return(colorNumeric("viridis", NULL))
}

create_various_variables <- function() {
  return(as.numeric(leaflet_map_index <- 1))
}

# Create environment variables
print("Running init.R")
locations <- load_locations()
statistics <- load_statistics()
facts <- load_facts()
neighbourhood_map <- load_map_neighbourhood()
pal <- load_color_scheme()
leaflet_map_index <- create_various_variables()
selected_locations <- c()
selected_neighbourhood_corr_map <- "F81e"
variableByTheme <- c()
correlation_themes <- sort(c("Bevolking", "Bevolking leeftijd", "Veiligheid", 
                             "Verkeer", "Werk", "Inkomen", "Onderwijs", "Welzijn en zorg", 
                             "Wonen", "Openbare ruimte"))
