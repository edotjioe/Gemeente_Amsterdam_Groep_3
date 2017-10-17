#install.packages("readxl")
#install.packages("dplyr")
#install.packages("stringr")
#install.packages("DBI")
#install.packages("RMySQL")
library(readxl)
library(dplyr)
library(stringr)
library(DBI)
library(RMySQL)


# Loading data into R
bbga_data <- read.csv("data_files/bbga_data.csv", sep = ";", stringsAsFactors = FALSE) 
bbga_metadata <- read_xlsx("data_files/bbga_additional_metadata.xlsx", sheet = 2)
bbga_additional <- read_xlsx("data_files/bbga_additional_metadata.xlsx", sheet = 1)


# Filtering data 
bbga_data <- bbga_data[which(bbga_data$jaar <= 2017 & bbga_data$jaar >= 2005),]
bbga_additional <- bbga_additional[which(bbga_additional$jaar <= 2017 & bbga_additional$jaar >= 2005),]
facts <- bbga_data
# Location (unique) data, niveau: 2, 4 and 8 (8 = 'Buurten')
temp_location_data <- unique(bbga_additional[, 1:8])
temp_location_data <- temp_location_data[which(temp_location_data$niveau == 2 | temp_location_data$niveau == 4 | temp_location_data$niveau == 8),]
# Only 'location niveau; 8' and remove NA rows
temp_location_8 <- na.omit(temp_location_data[which(temp_location_data == 8),])
# Only 'gebiedscode15; Buurten' 
facts <- facts[grep('[A-Z][0-9]{2}[a-z]', facts$gebiedcode15),]


# Loading data in statistics 
statistics <- data.frame("theme_name" = bbga_metadata$THEMA,
                         "statistics_variable" = toupper(bbga_metadata$Variabele),
                         "statistics_unit" = bbga_metadata$Rekeneenheid, stringsAsFactors = FALSE)

# Loading data in locations
locations <- data.frame("district_code", 
                        "district_name",
                        "quarter_code",
                        "quarter_name",
                        "neighbourhood_code",
                        "neighbourhood_name", stringsAsFactors = FALSE)
colnames(locations) <- c("district_code", "district_name", "quarter_code", "quarter_name", "neighbourhood_code", "neighbourhood_name") 
# loop for extracting district_code and quarter_code, while also assigning the corresponding 'gebiedsnaam' 
for(i in 1:nrow(temp_location_8)) {
  district_code <- str_extract(temp_location_8[i,]$gebiedcode15, "[A-Z]")
  quarter_code <- str_extract(temp_location_8[i,]$gebiedcode15, "[A-Z][0-9]{2}")
  
  locations[i,] <- list(
    district_code <- district_code,
    district_name <- temp_location_data[which(temp_location_data$gebiedcode15 == district_code),]$gebiednaam,
    quarter_code <- quarter_code,
    quarter_name <- temp_location_data[which(temp_location_data$gebiedcode15 == quarter_code),]$gebiednaam,
    neighbourhood_code <- temp_location_8[i,]$gebiedcode15,
    neighbourhood_name <- temp_location_8[i,]$gebiednaam
  )
}

# Loading data in facts
facts <- transform(facts, variabele = match(facts$variabele, statistics$statistics_variable))
facts <- transform(facts, gebiedcode15 = match(facts$gebiedcode15, locations$neighbourhood_code))
facts$version <- 1
facts <- facts[, c(3, 2, 4, 1, 5)]
colnames(facts) <- c("statistics_id", "locations_id", "value", "year", "version")
facts <- facts[complete.cases(facts), ]


# Data transfer to SQL datawarehouse 
con <- dbConnect(RMySQL::MySQL(), 
                 dbname = "zbekhofl001",
                 host = "oege.ie.hva.nl", 
                 user = "bekhofl001", 
                 password = "ovv2atL4IgRBjd", 
                 client.flag = CLIENT_MULTI_STATEMENTS)
#dbListTables(con)
  
# Writing data to database
dbWriteTable(con, "locations", locations, overwrite = TRUE)
dbWriteTable(con, "statistics", statistics, overwrite = TRUE)
dbWriteTable(con, "facts", facts, overwrite = TRUE)
  
  
# Alteration of the tables (necessary)
dbSendQuery(con, "ALTER TABLE locations
  CHANGE COLUMN row_names locations_id BIGINT PRIMARY KEY,
  CHANGE COLUMN district_code district_code TEXT NOT NULL,
  CHANGE COLUMN district_name district_name TEXT NOT NULL,
  CHANGE COLUMN quarter_code quarter_code TEXT NOT NULL,
  CHANGE COLUMN quarter_name quarter_name TEXT NOT NULL,
  CHANGE COLUMN neighbourhood_code neighbourhood_code TEXT NOT NULL,
  CHANGE COLUMN neighbourhood_name neighbourhood_name TEXT NOT NULL")
dbSendQuery(con, "ALTER TABLE statistics
  CHANGE COLUMN row_names statistics_id BIGINT PRIMARY KEY,
  CHANGE COLUMN theme_name theme_name TEXT NOT NULL,
  CHANGE COLUMN statistics_variable statistics_variable TEXT NOT NULL,
  CHANGE COLUMN statistics_unit statistics_unit SMALLINT NOT NULL")
dbSendQuery(con, "ALTER TABLE facts
  CHANGE COLUMN row_names facts_id BIGINT PRIMARY KEY,
  CHANGE COLUMN statistics_id statistics_id BIGINT NOT NULL,
  CHANGE COLUMN locations_id locations_id BIGINT NOT NULL,
  CHANGE COLUMN value value DOUBLE NOT NULL,
  CHANGE COLUMN year year SMALLINT NOT NULL,
  ADD FOREIGN KEY (statistics_id) REFERENCES statistics(statistics_id),
  ADD FOREIGN KEY (locations_id) REFERENCES locations(locations_id)")

# Disconnect from connection
dbDisconnect(con)