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
    input$stat_corr_select_1
    input$stat_corr_select_2
    input$neighboorhoud_corr
  }, {
    output$corr_graph_1 <- render_graph3(input$stat_corr_select_1, input$stat_corr_select_2, input$neighboorhoud_corr)
    output$corr_graph_2 <- render_graph4(input$stat_corr_select_1, input$stat_corr_select_2, input$neighboorhoud_corr)
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
  output$datatable1 <- get_table(facts)
}