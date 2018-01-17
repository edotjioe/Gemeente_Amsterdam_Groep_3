library(RMySQL)

connect_db <- function(){
  dbConnect(RMySQL::MySQL(), 
            dbname = "zbekhofl001",
            host = "oege.ie.hva.nl", 
            user = "bekhofl001", 
            password = "ovv2atL4IgRBjd", 
            client.flag = CLIENT_MULTI_STATEMENTS)
}



get_query <- function(query) {
  con <- connect_db()
  
  result <- dbGetQuery(con, query)

  dbDisconnect(con)  

  return(result)
}