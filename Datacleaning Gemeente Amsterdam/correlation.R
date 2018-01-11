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

statistics <- dbGetQuery(con, "SELECT * FROM statistics")
facts <- dbGetQuery(con, "SELECT * FROM facts")
locations <- dbGetQuery(con, "SELECT * from locations")

dbDisconnect(con)

# --- Create a data frame with all ---
correlations <- data.frame(
  correlations_id = numeric(0),
  statistics_1_id = numeric(0),
  statistics_2_id = numeric(0),
  district_code = character(0),
  value = numeric(0))

stat_ids <- statistics$statistics_id
for(i in 1:length(stat_ids)) {
  statistics_1_id <- rep(stat_ids[i], length(stat_ids) - 1)
  statistics_2_id <- setdiff(stat_ids, stat_ids[i])
  
  df <- data.frame(
    correlations_id = 0,
    statistics_1_id = statistics_1_id,
    statistics_2_id = statistics_2_id,
    district_code = character(length(statistics_1_id)),
    value = numeric(length(statistics_1_id)))
  correlations <- rbind(correlations, df)
}
# --- ---

# --- Duplicate the earlier created data frame for every district ---
location_ids <- unique(locations$district_code)
copy <- correlations
correlations <- correlations[!1:nrow(correlations),]
for(i in 1:length(location_ids)) {
  copy$district_code <- as.character(location_ids[i])
  correlations <- rbind(correlations, copy)
}
# --- ---

# Assign an id to each correlation
correlations$correlations_id <- 1:nrow(correlations)

for(i in 1:1000) { #nrow(correlations)
  i <- 39
  locations_id <- locations[locations$district_code == correlations[i,]$district_code,]$locations_id

  if(!(correlations[i,]$statistics_1_id %in% facts$statistics_id) | !(correlations[i,]$statistics_1_id %in% facts$statistics_id)) {next}
  
  cor1 <- facts[facts$statistics_id == correlations[i,]$statistics_1_id,]
  cor2 <- facts[facts$statistics_id == correlations[i,]$statistics_2_id,]
  
  cor1 <- cor1[locations_id %in% cor1$locations_id,]
  cor2 <- cor2[locations_id %in% cor2$locations_id,]

  if(nrow(cor1) > nrow(cor2)) {
    cor1 <- cor1[cor2$locations_id %in% cor1$locations_id,]
  } else if(nrow(cor1) < nrow(cor2)) {
    cor2 <- cor2[cor1$locations_id %in% cor2$locations_id,]
  }
  
  if(nrow(cor1) == 0 | nrow(cor2) == 0) {next}
  
  cor1 %>%
    arrange(desc(year))
  
  cor2 %>%
    arrange(desc(year))

  if(nrow(cor1) > nrow(cor2)) {
    cor1 <- cor1[cor2$year %in% cor1$year,]
  } else if(nrow(cor1) < nrow(cor2)) {
    cor2 <- cor2[cor1$year %in% cor2$year,]
  }
  
  print(cor(x = cor1$value, y = cor2$value))
  correlations[i, "value"] <- cor(x = cor1$value, y = cor2$value)
}


# Old code
corr_ma <- matrix(ncol = length(statistics$statistics_id), nrow = length(statistics$statistics_id))

f1 <- facts %>% 
  filter(locations_id == 164) %>% 
  arrange(desc(year))

for (i in 1:nrow(statistics)) {
  df1 <- f1[which(statistics[i,"statistics_id"] == f1$statistics_id), "value"]
  for (j in 1:nrow(statistics)) {
    df2 <- f1[which(statistics[j,"statistics_id"] == f1$statistics_id), "value"]
    if(length(df1) ==  length(df2)) {
      corr_ma[i,j] <- cor(x = df1, y = df2)
    }
  }
}

# cor(c(1,2,3,4), c(1,2,3,4))
# f1[f1$statistics_id == 104, "value"]
# df1 <- statistics[match(statistics[1,"statistics_id"], f1$statistics_id, nomatch = 0), "value"]
# df2 <- statistics[match(statistics[4,"statistics_id"], f1$statistics_id, nomatch = 0), "value"]
# cor(x = df1$value, y = df2$value)
