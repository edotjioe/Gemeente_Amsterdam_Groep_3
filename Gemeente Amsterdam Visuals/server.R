library(ggplot2)

function(input, output, session) {
  
  # Combine the selected variables into a new data frame

  
  output$plot1 <- renderPlot({
    palette(c("#E41A1C", "#377EB8", "#4DAF4A", "#984EA3",
              "#FF7F00", "#FFFF33", "#A65628", "#F781BF", "#999999"))
    
    itemx <- statistics[which(statistics$variable == input$xcol), ]
    itemy <- statistics[which(statistics$variable == input$ycol), ]
    location <- locations[which(locations$neighbourhood_name == input$lcol), ]
    
    av_variables_id <- unique(facts[which(facts$locations_id == location$location_id), 1])
    av_variables <- statistics[av_variables_id, 3]
    
    result <- data.frame(x = facts[which(facts$statistics_id == itemx$statistic_id & facts$locations_id == location$location_id), 3])
    result <- cbind(result, y = facts[which(facts$statistics_id == itemy$statistic_id & facts$locations_id == location$location_id), 3])
    
    ggplot(result, aes(x = x, y = y)) +
      geom_point() +
      xlab(itemx$variable) +
      ylab(itemy$variable) +
      ggtitle(location$neighbourhood_name)
    
  })
  
}