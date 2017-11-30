# Load all source files here!
source("mysql.R")
source("init.R")
source("render.R")

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Amsterdam Statistieken", titleWidth = 300),
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      id = "sidebar",
      menuItem(
        "Dashboard",
        tabName = "dashboard",
        icon = icon("dashboard")
      ),
      menuItem(
        "Interactieve map",
        tabName = "map",
        icon = icon("map")
      ),
      conditionalPanel(
        condition = "input.sidebar == 'map'",
        class = "filter-panel",
        selectInput(
          "stat",
          "Select statistic",
          split(statistics$statistics_variable, statistics$statistics_name)
        ),
        sliderInput("year", "Select year", 2005, 2017, 2017, step = 1)
      ),
      menuItem("Charts", tabName = "chart", icon = icon("bar-chart-o"),
               menuSubItem("Chart 1", tabName = "subchart1"),
               menuSubItem("Chart 2", tabName = "subchart2"),
               menuSubItem("Vergelijk leefbaarheid", tabName = "stadsdeel"),
               menuSubItem("Chart 2", tabName = "subchart2")
      ),
      menuItem("Data explorer", tabName = "datatable", icon = icon("table")),
      conditionalPanel(condition = "input.sidebar == 'chart'", h2("Test")),
      conditionalPanel(condition = "input.sidebar == 'datatable'", h3("Test"))
    )
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "theme.css")
    ),
    tabItems(
      tabItem(tabName = "dashboard",
              h2("Dashboard")),
      tabItem(
        tabName = "map",
        
        fluidRow(
          tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
          leafletOutput("map", width = "100%"),
          
          absolutePanel(
            id = "map_graph_panel",
            bottom = "20",
            left = "320",
            width = 500,
            height = 400,
            plotOutput("map_graph")
          ),
          tags$style(type = 'text/css', ".selectize-dropdown-content {max-height: 150px; }")
        )
      ),
      tabItem( tabName = "subchart1",
               h2("Chart 1"),
               selectInput("variable", "Kies een bevolkingsgroep:",
                           statistics[which(grepl("BEV",statistics$statistics_variable)),]$statistics_variable),
               
               
               plotlyOutput("barchart")
      ),
      tabItem( tabName = "subchart2",
               h2("Chart 2")
               
      ),
      tabItem( tabName = "datatable",
               h2("Data explorer"),
               tableOutput("table")
      ),
      tabItem(tabName = "stadsdeel",
              
              h2("Vergelijk stadsdelen op leefbaarheid:"), 
              
              wellPanel(
                fluidRow(
                  column(width = 5,
                         selectInput("stadsdeel1", "Kies een stadsdeel:", width = 150,
                                     unique(locations$district_name)),
                         selectInput("stadsdeel2", "Kies een stadsdeel:", width = 150,
                                     unique(locations$district_name))
                  ),
                  column(width = 5,
                         selectInput("thema", "Kies een thema:", width = 150,
                                     statistics[which(grepl("BEV",statistics$statistics_variable)),]$statistics_variable)
                         #actionButton("vergelijk", "Vergelijk!", style = 'margin-top:3.3vh ; background-color:#fff', width =  150)
                  )
                )
              ),
              plotlyOutput("stadsdeelchart")
      )
    )
    
  )
)