server <- function(input, output, session) {       
  # Combine the selected variables into a new data frame
  map <- reactive(render_map(input$year, input$stat_map_select))
  output$map <- renderLeaflet(map())
  output$mapSelectCorr <- renderLeaflet(correlation_map())
  output$mapSelectMulti <- renderLeaflet(render_select_map())
  
  # ObserveEvent for updating the variable list at "Interactieve map" page
  observeEvent({
    input$theme_map_select
  }, update_stat_select(session, input$theme_map_select, "stat_map_select"))
  
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
    update_stat_select_quantitative(session, input$theme_corr_select_1, "stat_corr_select_1")
    update_stat_select_quantitative(session, input$theme_corr_select_2, "stat_corr_select_2")
  })
  
  # ObserveEvent for updating the map, selectInput and graphs at "Correlatie" page by selectInput "district_corr"
  observeEvent({
    input$district_corr
  }, {
    if(!is.na(input$district_corr)) {
       update_correlation_map(input$district_corr)
    }
    
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
    output$corr_message <- get_corr_message(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
  })

  # OberveEvent for updating the map, selectInput and graphs at "Correlatie" page by selectInput "mapSelectCorr_shape_click"
  observeEvent({
    input$mapSelectCorr_shape_click
  }, {
    click <- input$mapSelectCorr_shape_click
    if(click$id != selected_district_corr_map) {
      updateSelectInput(session = session, inputId = "district_corr", selected = click$id)
    }
  })
  
  # ObserverEvent for updating the graph at the "Correlatie" page
  observeEvent({
    input$stat_corr_select_1
    input$stat_corr_select_2
  }, {
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
    output$corr_message <- get_corr_message(input$stat_corr_select_1, input$stat_corr_select_2, input$district_corr)
  })
  
  # ObserveEvent for updating the graph at "Vergelijk stadsdeel" page
  observeEvent({
    input$statistic_compare_district
    input$district_compare_one
    input$district_compare_two
  }, output$district_chart <- render_graph(input$statistic_compare_district, input$district_compare_one, input$district_compare_two))
  
  # ObserveEvent for updating the select at "Vergelijk stadsdeel" page with theme 
  observeEvent({
    input$theme_compare_district
  }, update_stat_select_quantitative(session, input$theme_compare_district, "statistic_compare_district"))
  
  # ObserveEvent for updating the graph at "Vergelijk buurten" page  
  observeEvent({
    input$statistic_compare_neighbourhood
    input$neighbourhood_compare_one
    input$neighbourhood_compare_two
  }, output$neighbourhood_chart <- render_graph2(input$statistic_compare_neighbourhood, input$neighbourhood_compare_one, input$neighbourhood_compare_two))
  
  # ObserveEvent for updating the select at "Vergelijk buurten" page with theme 
  observeEvent({
    input$theme_compare_neighbourhood
  }, update_stat_select(session, input$theme_compare_neighbourhood, "statistic_compare_neighbourhood"))
  
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
  output$datatable <- facts_merged
  output$corr_table_data <- corr_table
}