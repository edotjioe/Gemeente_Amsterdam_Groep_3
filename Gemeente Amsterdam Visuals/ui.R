
navbarPage("Gemeente Amsterdam Statistieken", id="nav",
   tabPanel("Interactieve map",
        leafletOutput("map", width = "100%", height = "900px"),

        absolutePanel(top = 300, right = 50, class = "panel panel-default",
                      selectInput("stat", "Select statistic", statistics[, 3]),
                      sliderInput("year", "Select year", 2005, 2017, 2017, step = 1)
        )
    )
)
