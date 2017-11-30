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
        sliderInput("year", "Select year", 2005, 2017, 2017, step = 1)
      ),
      menuItem(
        "Charts",
        tabName = "chart",
        icon = icon("bar-chart-o"),
        menuSubItem("Chart 1", tabName = "subchart1"),
        menuSubItem("Chart 2", tabName = "subchart2")
      ),
      menuItem("Data explorer", tabName = "datatable", icon = icon("table")),
      conditionalPanel(condition = "input.sidebar == 'chart'", h2("Test")),
      conditionalPanel(condition = "input.sidebar == 'datatable'", h3("Test"))
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
      tabItem(tabName = "subchart1",
              h2("Chart 1")),
      tabItem(tabName = "subchart2",
              h2("Chart 2")),
      tabItem(tabName = "datatable",
              h2("Data explorer"))
    )
    
  )
)