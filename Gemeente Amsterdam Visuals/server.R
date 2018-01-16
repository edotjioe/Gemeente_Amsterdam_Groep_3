server <- function(input, output, session) {       
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat))
  output$map <- renderLeaflet(map())
  output$mapSelectCorr <- renderLeaflet(correlation_map())
  
  output$mapSelectMulti <- renderLeaflet(render_select_map())
  observeEvent({
    input$mapSelectMulti_shape_click
  }, add_to_map_selection(input$mapSelectMulti_shape_click))

  observeEvent({
    input$mapSelectMulti_shape_click
    input$stat_map_select
  }, output$map_graph <- render_select_map_plot(input$stat_map_select))
  
  observeEvent({
    input$theme_map_select
  }, update_stat_select(session, input$theme, "stat"))
  
  observeEvent({
    input$theme_map_select
  }, update_stat_select(session, input$theme_map_select, "stat_map_select"))
  
  observeEvent({
    input$theme_corr_select_1
    input$theme_corr_select_2
  }, 
  {
    update_stat_select(session, input$theme_corr_select_1, "stat_corr_select_1")
    update_stat_select(session, input$theme_corr_select_2, "stat_corr_select_2")
  })
  
  observeEvent({
    input$neighbourhood_corr
  }, {
    code <- as.character(locations[locations$neighbourhood_name == input$neighbourhood_corr, "neighbourhood_code"])
    update_correlation_map(code)
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
  })

  
  observeEvent({
    input$mapSelectCorr_shape_click
  }, {
    click <- input$mapSelectCorr_shape_click
    if(click$id != selected_neighbourhood_corr_map) {
      location_name <- as.character(locations[locations$neighbourhood_code == click$id, "neighbourhood_name"])
      updateSelectInput(session = session, inputId = "neighbourhood_corr", selected = location_name)
      update_correlation_map(click$id)
    }
  })
  
  observeEvent({
    input$stat_corr_select_1
    input$stat_corr_select_2
  }, {
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
  })
  
  
  observeEvent({
    input$theme_corr_select_2
  }, update_stat_select(session, input$theme_corr_select_2, "stat_corr_select_2"))
  
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