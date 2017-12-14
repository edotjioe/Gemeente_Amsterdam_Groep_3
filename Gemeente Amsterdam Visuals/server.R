server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat))
  
  output$map <- renderLeaflet(map())

  observeEvent({
    input$theme
  }, update_stat_select(session, input$theme))
  
  observeEvent({
    input$thema
    input$stadsdeel1
    input$stadsdeel2
  }, output$stadsdeelchart <- render_graph(input$thema, input$stadsdeel1, input$stadsdeel2))
  
  observeEvent({
    input$themaC
    input$stadsdeel1C
    input$stadsdeel2C
  }, output$stadsdeelchart2 <- render_graph2(input$themaC, input$stadsdeel1C, input$stadsdeel2C))
  
  # Table
  output$datatable1 <- get_table(facts)
  
  # Map selection code
  # observeEvent({
  #   input$map_shape_click
  # }, add_to_map_selection(input$map_shape_click, input$year, input$stat))
}