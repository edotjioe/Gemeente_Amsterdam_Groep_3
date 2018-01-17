# install all packages here!
# install.packages("shiny")
# install.packages("shinydashboard")
# install.packages("ggplot2")
# install.packages("leaflet")
# install.packages("dplyr")
# install.packages("RMySQL")
# install.packages("geojsonio")
# install.packages("plotly")
# install.packages("shinyjs")
# install.packages("DT")
# install.packages("data.table")

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
library(data.table)

load_map_neighbourhood <- function() {
  print("Loading GeoJson Data...")
  
  return(geojsonio::geojson_read("datafiles/GEBIED_BUURTEN.json", what = "sp", stringsAsFactor = FALSE))
}

load_map_districts <- function() {
  return(geojsonio::geojson_read("datafiles/GEBIED_STADSDELEN.json", what = "sp", stringsAsFactor = FALSE))
}

load_facts <- function() {
  print("Loading facts...")
  
  return(get_query("SELECT * FROM facts"))
}

load_statistics <- function() {
  print("Loading statistics...")
  
  return(get_query("SELECT * FROM statistics"))
}

load_locations <- function() {
  print("Loading locations...")
  
  locations <- get_query("SELECT * FROM locations")
  
  temp <- load_map_neighbourhood()
  locations <- locations %>% slice(match(temp$Buurt_code, locations$neighbourhood_code))
  
  return(locations)
}

load_correlations <- function() {
  print("Loading correlations...")
  
  correlations <- get_query("SELECT * FROM correlations")
  
  return(correlations)
}

load_color_scheme <- function() {
  return(colorNumeric("viridis", NULL))
}

create_various_variables <- function() {
  return(as.numeric(leaflet_map_index <- 1))
}

create_merge_facts <- function() {
  print("Merging facts, statistics and locations...")
  
  df <- data.table(facts)
  
  df <- merge(df, data.table(locations), by = "locations_id")
  df <- merge(df, data.table(statistics), by = "statistics_id")
  units <- data.table("unit_id" = c(1, 2, 3, 4, 5, 6, 7, 8), "unit_name" = c("%", "Absoluut", "Rapport", "Index", "Gemiddelde", "Per 1000", "5-puntsschaal", "Coefficient"))
  df <- merge(df, units, by.x = "statistics_unit", by.y = "unit_id")
  
  df <- data.frame(df)
  
  selectedCols <- c("statistics_name", "neighbourhood_name", "year", "value", "unit_name")
  
  df <- df[, selectedCols]
  
  return(DT::renderDataTable(df,
                             filter = "top",
                             options = list(pageLength = 50),
                             colnames = c("Statestiek", "Buurt", "Jaar", "Waarde", "Eenheid")))
}

create_corr_table <- function() {
  print("Merging correlations, statistics and locations...")
  
  district_locations <- data.frame(district_code = unique(locations$district_code), district_name = unique(locations$district_name))
  statistics_list <- statistics[statistics$theme_name %in% correlation_themes,]
  
  df <- data.frame(correlations[correlations$value > -1 & correlations$value < 1,])
  df <- data.frame(df[df$value > 0.7 | df$value < -0.7,])
  df <- data.table(filter(df, df$statistics_1_id %in% statistics_list$statistics_id & df$statistics_2_id %in% statistics_list$statistics_id))
  
  df$value <- formatC(abs(df$value * 100000) / 1000, digits = 5)
  df <- merge(df, data.table(statistics[, c("statistics_id", "statistics_name", "theme_name")]), by.x = "statistics_1_id", by.y = "statistics_id", allow.cartesian = TRUE)
  df <- merge(df, data.table(statistics[, c("statistics_id", "statistics_name", "theme_name")]), by.x = "statistics_2_id", by.y = "statistics_id", allow.cartesian = TRUE)
  df <- merge(df, data.table(district_locations), by = "district_code", allow.cartesian = TRUE)
  
  df <- data.frame(df)
  
  # selected_cols <- c("district_name", "statistics_name.x", "theme_name.x", "statistics_name.y", "theme_name.y","value")
  selected_cols <- c("district_name", "statistics_name.x", "statistics_name.y","value")
  df <- df[, selected_cols]

  return(DT::renderDataTable(df,
                             filter = "top",
                             options = list(pageLength = 6),
                             colnames = c("Stadsdeel", "Statestiek 1", "Statestiek 2", "Verband in %")))
}

# Create environment variables
print("Running init.R")
correlation_themes <- sort(c("Bevolking", "Bevolking leeftijd", "Veiligheid", 
                             "Verkeer", "Werk", "Inkomen", "Onderwijs", "Welzijn en zorg", 
                             "Wonen", "Openbare ruimte"))
locations <- load_locations()
statistics <- load_statistics()
facts <- load_facts()
correlations <- load_correlations()
neighbourhood_map <- load_map_neighbourhood()
district_map <- load_map_districts()
pal <- load_color_scheme()
leaflet_map_index <- create_various_variables()
selected_locations <- c()
corr_table <- create_corr_table()
facts_merged <- create_merge_facts()
selected_district_corr_map <- "A"
variableByTheme <- c()

