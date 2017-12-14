server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat))
  output$map <- renderLeaflet(map())
  
  output$mapSelectMulti <- renderLeaflet(render_select_map())
  observeEvent({
    input$mapSelectMulti_shape_click
  }, add_to_map_selection(input$mapSelectMulti_shape_click))

  observeEvent({
    input$theme
  }, update_stat_select(session, input$theme))
  
  observeEvent({
    input$thema
    input$stadsdeel1
    input$stadsdeel2
  }, output$stadsdeelchart <- render_graph(input$thema, input$stadsdeel1, input$stadsdeel2))
  # Table
  output$datatable1 <- get_table(facts)
}