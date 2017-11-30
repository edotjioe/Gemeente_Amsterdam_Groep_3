server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  output$map <- render_map()

  observeEvent({
    input$stat
    input$year
  }, update_map(input$year, input$stat))
  
  observeEvent({
    input$theme
  }, update_stat_select(session, input$theme))
  
  observeEvent({
    input$map_shape_click
  }, add_to_map_selection(input$map_shape_click))
}