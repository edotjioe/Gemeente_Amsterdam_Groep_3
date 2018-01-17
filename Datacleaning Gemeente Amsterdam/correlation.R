#install.packages("readxl")
#install.packages("dplyr")
#install.packages("stringr")
#install.packages("DBI")
#install.packages("RMySQL")
# library(readxl)
library(dplyr)
# library(stringr)
library(DBI)
library(RMySQL)

con <- dbConnect(RMySQL::MySQL(), 
                 dbname = "zbekhofl001",
                 host = "oege.ie.hva.nl", 
                 user = "bekhofl001", 
                 password = "ovv2atL4IgRBjd", 
                 client.flag = CLIENT_MULTI_STATEMENTS)

# --- Get all the data needed to create the correlations ---
statistics <- dbGetQuery(con, "SELECT * FROM statistics")
facts <- dbGetQuery(con, "SELECT * FROM facts")
locations <- dbGetQuery(con, "SELECT * from locations")

dbDisconnect(con)

# --- Create the correlation data frame ---
correlations <- data.frame(
  correlations_id = numeric(0),
  statistics_1_id = numeric(0),
  statistics_2_id = numeric(0),
  district_code = character(0),
  value = numeric(0))

temp_correlations <- data.frame(
  correlations_id = numeric(0),
  statistics_1_id = numeric(0),
  statistics_2_id = numeric(0),
  district_code = character(0),
  value = numeric(0))
# --- ---

# --- Get all statistic ids where the statistic unit is a number
stat_ids <- statistics[statistics$statistics_unit == 2,]$statistics_id
# --- ---

# --- Create fill the data frame for all statistic combinations (excluding 1-1, 2-2, 3-3, etc...)
for(i in 1:length(stat_ids)) {
  for(j in i:length(stat_ids)) {
    if(i == j) {next}
    
    row <- data.frame(
      correlations_id = numeric(1),
      statistics_1_id = stat_ids[i],
      statistics_2_id = stat_ids[j],
      district_code = character(1),
      value = numeric(1))
    
    temp_correlations <- rbind(temp_correlations, row)
  }
}
# --- ---

# --- Get all district codes ---
district_codes <- unique(locations$district_code)
# --- ---

# --- Duplicate the earlier created data frame for every district ---
for(i in 1:length(district_codes)) {
  temp_correlations$district_code <- district_codes[i]
  
  correlations <- rbind(correlations, temp_correlations)
}
# --- ---

# --- Assign an id to each correlation ---
correlations$correlations_id <- 1:nrow(correlations)
# --- ---

# --- Calculate the values for every row in correlations ---
for(i in 1:nrow(correlations)) {
  # Get the location ids for the district code
  location_ids <- locations[locations$district_code == correlations[i,]$district_code,]$locations_id
  
  # Get the statistics for both correlations
  cor_1_facts <- facts[facts$statistics_id == correlations[i,]$statistics_1_id & facts$locations_id == location_ids,]
  cor_2_facts <- facts[facts$statistics_id == correlations[i,]$statistics_2_id & facts$locations_id == location_ids,]
  
  # If there are no facts continue to the next cycle of the loop
  if(nrow(cor_1_facts) == 0 | nrow(cor_2_facts) == 0) {next}
  
  # Keep the years that exist in both facts
  cor_1_years <- unique(cor_1_facts$year)
  cor_2_years <- unique(cor_2_facts$year)
  
  years <- Reduce(intersect, list(cor_1_years, cor_2_years))
  
  # If there are no matching years continue to the next cycle of the loop
  if(length(years) == 0) {next}
  
  # Merge all neighbourhoods
  cor_1_facts_sum <- data.frame(year = numeric(0), value = numeric(0))
  for(j in 1:length(years)) {
    year_values <- cor_1_facts[cor_1_facts$year == years[j],]$value
    
    cor_1_facts_sum <- rbind(cor_1_facts_sum, data.frame(year = years[j], value = sum(year_values)))
  }
  
  cor_2_facts_sum <- data.frame(year = numeric(0), value = numeric(0))
  for(j in 1:length(years)) {
    year_values <- cor_2_facts[cor_2_facts$year == years[j],]$value
    
    cor_2_facts_sum <- rbind(cor_2_facts_sum, data.frame(year = years[j], value = sum(year_values)))
  }
  
  # Sort the data frames by year
  cor_1_facts_sum <- cor_1_facts_sum[order(cor_1_facts_sum$year),]
  cor_2_facts_sum <- cor_2_facts_sum[order(cor_2_facts_sum$year),]
  
  # Calculate and insert correlations
  correlations[i,]$value <- cor(x = cor_1_facts_sum$value, y = cor_2_facts_sum$value)
}

correlations <- correlations[!is.na(correlations$value),]

dbWriteTable(con, "correlations", correlations, overwrite = TRUE)

# i = 514294 <- start there in the above for loop
#saveRDS(correlations, "intermediate.RDS")
#correlations <- readRDS("intermediate.RDS")
