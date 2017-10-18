navbarPage("Gemeente Amsterdam Statistieken", id="nav",
   tabPanel("Interactieve map",
        leafletOutput("map", width = "100%", height = "900px"),
        leafletOutput("popup"),

        absolutePanel(id = "control", bottom = 50, right = 50, 
                      selectInput("stat", "Select statistic", statistics[, 3]),
                      sliderInput("year", "Select year", 2005, 2017, 2017, step = 1)
        ),
        tags$style(type='text/css', ".selectize-dropdown-content {max-height: 150px; }")
    )
)
