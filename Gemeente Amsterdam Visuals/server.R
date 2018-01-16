server <- function(input, output, session) {
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat))
  output$map <- renderLeaflet(map())
  
  output$mapSelectMulti <- renderLeaflet(render_select_map())
  observeEvent({
    input$mapSelectMulti_shape_click
  }, add_to_map_selection(input$mapSelectMulti_shape_click))

  observeEvent({
    input$mapSelectMulti_shape_click
    input$stat_map_select
  }, output$map_graph <- render_select_map_plot(input$stat_map_select))
  
  observeEvent({
    input$theme
    input$theme_map_select
  }, update_stat_select(session, input$theme, input$theme_map_select))
  
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
  output$datatable1 <- get_facts_table()
  
  # Dashboard Buttons
  observeEvent(
    input$button_map, {
      updateTabItems(session, "sidebar", selected = "map")
    }
  )
  observeEvent(
    input$button_chart, {
      updateTabItems(session, "sidebar", selected = "compare_neighbourhoods")
    }
  )
  observeEvent(
    input$button_data, {
      updateTabItems(session, "sidebar", selected = "datatable")
    }
  )
}