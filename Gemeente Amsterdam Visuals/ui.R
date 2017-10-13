pageWithSidebar(
  headerPanel('Genre data graph'),
  sidebarPanel(
      selectInput('lcol', 'Buurt', locations[, 7]),
      selectInput('xcol', 'Variabele 1', av_variables),
      selectInput('ycol', 'Variable 2', av_variables),
                  selected=statistics[[1]]
  ),
  mainPanel(
    plotOutput('plot1')
  )
)

