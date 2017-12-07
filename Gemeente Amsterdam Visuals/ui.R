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
          "theme",
          "Select theme",
          unique(statistics$theme_name)
        ),
        selectInput(
          "stat",
          "Select statistic",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        ),
        sliderInput("year", "Select year", 2005, 2017, 2017, step = 1, sep = "")
      ),
      menuItem(
        "Charts",
        tabName = "chart",
        icon = icon("bar-chart-o"),
        menuSubItem("Vergelijk leefbaarheid", tabName = "stadsdeel")
      ),
      conditionalPanel(
        condition = "input.sidebar == 'stadsdeel'",
        class = "filter-panel",
        selectInput(
          "thema",
          "Kies een thema:",
          split(statistics[which(statistics$statistics_unit == 2), "statistics_variable"], statistics[which(statistics$statistics_unit == 2), "statistics_name"])
        ),
        selectInput(
          "stadsdeel1",
          "Kies een stadsdeel:",
          unique(locations$district_name)
        ),
        selectInput(
          "stadsdeel2",
          "Kies een stadsdeel:",
          unique(locations$district_name),
          selected = "Zuid"
        )
      ),
      menuItem("Data explorer", tabName = "datatable", icon = icon("table")),
      sidebarMenuOutput("dynamicsidebar")
    )
  ),
  dashboardBody(
    useShinyjs(),
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

          tags$style(type = 'text/css', ".selectize-dropdown-content {max-height: 150px; }")
        )
      ),
      tabItem(
        tabName = "subchart1",
        h2("Chart 1"),
        selectInput(
          "variable",
          "Kies een bevolkingsgroep:",
          statistics[which(grepl("BEV", statistics$statistics_variable)), ]$statistics_variable
        ),
        
        
        plotlyOutput("barchart")
      ),
      tabItem(tabName = "subchart2",
              h2("Chart 2")),
      tabItem(tabName = "datatable",
              h2("Data Explorer"),
              DT::dataTableOutput("datatable1")
              ),
      tabItem(
        tabName = "stadsdeel",
        
        h2("Vergelijk stadsdelen op leefbaarheid:"),
        plotlyOutput("stadsdeelchart")
      )
    )
  )
)