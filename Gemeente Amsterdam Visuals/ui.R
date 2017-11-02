# Load all source files here!
source("mysql.R")
source("init.R")
source("render.R")

ui <- dashboardPage( skin = "red",
  dashboardHeader(title = "Amsterdam Statistieken", titleWidth = 300),
  dashboardSidebar( width = 300,
    sidebarMenu( id = "sidebar",
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Interactieve map", tabName = "map", icon = icon("map")),
      menuItem("Charts", tabName = "chart", icon = icon("bar-chart-o"),
               menuSubItem("Chart 1", tabName = "subchart1"),
               menuSubItem("Chart 2", tabName = "subchart2")
               ),
      menuItem("Data explorer", tabName = "datatable", icon = icon("table")),
      sidebarMenuOutput("dynamicsidebar")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem( tabName = "dashboard",
               h2("Dashboard")
      ),
      tabItem( tabName = "map",
               
        fluidRow(
            tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
            leafletOutput("map", width = "100%"),
    
            absolutePanel(id = "control", top = 700, right = 50,
                          selectInput("stat", "Select statistic", statistics[, 3]),
                          sliderInput("year", "Select year", 2005, 2017, 2017, step = 1),
            absolutePanel(id = "map_graph_panel", bottom = "20", left = "20",
                          plotOutput("map_graph"))
            ),
          tags$style(type='text/css', ".selectize-dropdown-content {max-height: 150px; }")
         )
      ),
      tabItem( tabName = "subchart1",
               h2("Chart 1")
      ),
      tabItem( tabName = "subchart2",
               h2("Chart 2")
      ),
      tabItem( tabName = "datatable",
               h2("Data explorer")
      )
    )
    
  )
)