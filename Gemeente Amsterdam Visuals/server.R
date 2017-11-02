server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  output$map <- render_map()
  
  observeEvent({
    input$stat
    input$year
    }, update_map(input$year, input$stat))
  
  output$dynamicsidebar <- renderMenu({
    sidebarMenu()
  })
  
  observeEvent(input$map_shape_click, show_map_graph(input$map_shape_click))
}