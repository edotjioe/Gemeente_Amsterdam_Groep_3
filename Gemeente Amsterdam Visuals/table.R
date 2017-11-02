install.packages('DT')
library(DT)

setwd("C:/Users/Bram/Documents/Gemeente_Amsterdam_Groep_3/Gemeente Amsterdam Visuals")

get_table <- function(df) {
  DT::renderDataTable(
    df,
    options = list(
      pageLength = 50
    )
  )
}