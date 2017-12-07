#install.packages("readxl")
install.packages("dplyr")
#install.packages("stringr")
install.packages("DBI")
install.packages("RMySQL")
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
#rm(statistics)

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
cor(c(1,2,3,4), c(1,2,3,4))
f1[f1$statistics_id == 104, "value"]
df1 <- statistics[match(statistics[1,"statistics_id"], f1$statistics_id, nomatch = 0), "value"]
df2 <- statistics[match(statistics[4,"statistics_id"], f1$statistics_id, nomatch = 0), "value"]
cor(x = df1$value, y = df2$value)
