server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  output$map <- render_map()
  
  output$dynamicsidebar <- renderMenu(sidebarMenu())
  
  observeEvent(input$map_shape_click, {
    output$map_graph <- render_map_graph(input$map_shape_click, input$stat)
  })

  observeEvent({
    input$stat
    input$year
  }, update_map(input$year, input$stat))
  
  output$stadsdeelchart <- renderPlotly({
  
    statistics_id <- statistics %>%
      filter(statistics_variable == input$thema) %>%
      select(statistics_id)
    
    factscompare <- get_query(paste("SELECT value, statistics_id, locations_id, year FROM facts WHERE statistics_id = ", statistics_id, ";"))
    
    chart_data <- factscompare %>% 
    inner_join(locations, by = "locations_id") %>%
    inner_join(statistics, by = "statistics_id") %>%
    group_by(year, district_name) %>%
    summarise(value = sum(value))
  
    stad1 <- chart_data %>%
      filter(district_name == input$stadsdeel1)
    stad2 <- chart_data %>%
      filter(district_name == input$stadsdeel2)
    
    final <- data.frame(unique(chart_data$year), 
                        stad1$value, 
                        stad2$value)
    
    plot_ly(final, x = final$unique.chart_data.year., y = final$stad1.value, name = input$stadsdeel1, type = 'scatter', mode = 'lines') %>%
      add_trace(y = final$stad2.value, name = input$stadsdeel2, mode = 'lines')
  })  
  # Table
  output$datatable1 <- get_table(map_fact)
}