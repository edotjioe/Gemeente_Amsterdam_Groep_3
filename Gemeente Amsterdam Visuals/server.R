library(ggplot2)

function(input, output, session) {
  
  # Combine the selected variables into a new data frame
  output$plot1 <- renderPlot({
    
    if(is.na(input)){
      itemx <- statistics[statistics$variable == input$xcol, ]
      itemy <- statistics[statistics$variable == input$ycol, ]
      location <- locations[locations$neighbourhood_name == input$lcol, ]
      
      av_variables_id <- unique(facts[which(facts$locations_id == location$location_id), 1])
      av_variables <- statistics[av_variables_id, 3]
      
      result <- data.frame(x = facts[which(facts$statistics_id == itemx$statistic_id & facts$locations_id == location$location_id), 3])
      result <- cbind(result, y = facts[which(facts$statistics_id == itemy$statistic_id & facts$locations_id == location$location_id), 3])
      
      ggplot(result, aes(x = x, y = y)) +
        geom_point() +
        xlab(itemx$variable) +
        ylab(itemy$variable) +
        ggtitle(location$neighbourhood_name)
    
    }
    
  })
  
}