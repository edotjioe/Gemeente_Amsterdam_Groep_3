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
  
  observeEvent({
    input$thema
    input$stadsdeel1
    input$stadsdeel2
  }, output$stadsdeelchart <- render_graph(input$thema, input$stadsdeel1, input$stadsdeel2))
  # Table
  output$datatable1 <- get_table(map_fact)
}