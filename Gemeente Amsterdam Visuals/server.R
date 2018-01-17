server <- function(input, output, session) {       
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat))
  output$map <- renderLeaflet(map())
  output$mapSelectCorr <- renderLeaflet(correlation_map())
  output$mapSelectMulti <- renderLeaflet(render_select_map())
  
  # ObserveEvent for updating the variable list at "Interactieve map" page
  observeEvent({
    input$theme_map_select
  }, update_stat_select(session, input$theme, "stat"))
  
  # ObserveEvent for updating the map at "Vergelijk buurten met kaart" page
  observeEvent({
    input$mapSelectMulti_shape_click
  }, add_to_map_selection(input$mapSelectMulti_shape_click))
  
  # ObserveEvent for updating the variable list at "Vergelijk buurten met kaart" page
  observeEvent({
    input$theme_map_select
  }, update_stat_select(session, input$theme_map_select, "stat_map_select"))
  
  # ObserveEvent for updating the plot at "Vergelijk buurten met kaart" page 
  observeEvent({
    input$mapSelectMulti_shape_click
    input$stat_map_select
  }, {
    output$map_graph <- render_select_map_plot(input$stat_map_select)
  })
  
  # ObserveEvent for updating the variable list by theme at "Correlatie" page
  observeEvent({
    input$theme_corr_select_1
    input$theme_corr_select_2
  }, 
  {
    update_stat_select(session, input$theme_corr_select_1, "stat_corr_select_1")
    update_stat_select(session, input$theme_corr_select_2, "stat_corr_select_2")
  })
  
  # ObserveEvent for updating the map, selectInput and graphs at "Correlatie" page by selectInput "neighbourhood_corr"
  observeEvent({
    input$neighbourhood_corr
  }, {
    if(!is.na(input$neighbourhood_corr)) {
       update_correlation_map(input$neighbourhood_corr)
    }
    
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_message <- get_corr_message(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
  })

  # OberveEvent for updating the map, selectInput and graphs at "Correlatie" page   by selectInput "mapSelectCorr_shape_click"
  observeEvent({
    input$mapSelectCorr_shape_click
  }, {
    click <- input$mapSelectCorr_shape_click
    if(click$id != selected_district_corr_map) {
      updateSelectInput(session = session, inputId = "neighbourhood_corr", selected = click$id)
    }
  })
  
  # ObserverEvent for updating the graph at the "Correlatie" page
  observeEvent({
    input$stat_corr_select_1
    input$stat_corr_select_2
  }, {
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
    output$corr_message <- get_corr_message(input$stat_corr_select_1, input$stat_corr_select_2, input$neighbourhood_corr)
  })
  
  # ObserveEvent for updating variable list by theme at "Correlatie" page
  observeEvent({
    input$theme_corr_select_2
  }, update_stat_select(session, input$theme_corr_select_2, "stat_corr_select_2"))
  
  # ObserveEvent for updating the graph at "Vergelijk stadsdeel" page
  observeEvent({
    input$thema
    input$stadsdeel1
    input$stadsdeel2
  }, output$stadsdeelchart <- render_graph(input$thema, input$stadsdeel1, input$stadsdeel2))
  
  # ObserveEvent for updating the graph at "Vergelijk buurten" page
  observeEvent({
    input$themaC
    input$stadsdeel1C
    input$stadsdeel2C
  }, output$stadsdeelchart2 <- render_graph2(input$themaC, input$stadsdeel1C, input$stadsdeel2C))
  
  # Dashboard Buttons redirecting to different pages
  observeEvent(
    input$button_map, updateTabItems(session, "sidebar", selected = "map")
  )
  observeEvent(
    input$button_chart, updateTabItems(session, "sidebar", selected = "compare_neighbourhoods")
  )
  observeEvent(
    input$button_data, updateTabItems(session, "sidebar", selected = "datatable")
  )
  
  # Table
  output$datatable1 <- facts_merged
  output$corr_table_data <- corr_table
}