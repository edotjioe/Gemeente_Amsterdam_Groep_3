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
        menuSubItem("Vergelijk stadsdeel", tabName = "stadsdeel"),
        menuSubItem("Vergelijk buurten", tabName = "chart"),
        menuSubItem("Vergelijk buurten met kaart", tabName = "compare_neighbourhoods")
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
          unique(sort(locations$district_name))
        ),
        selectInput(
          "stadsdeel2",
          "Kies een stadsdeel:",
          unique(sort(locations$district_name)),
          selected = "Zuid"
        )
      ),
      conditionalPanel(
        condition = "input.sidebar == 'chart'",
        class = "filter-panel",
        selectInput(
          "themaC",
          "Kies een thema:",
          split(statistics[which(statistics$statistics_unit == 2), "statistics_variable"], statistics[which(statistics$statistics_unit == 2), "statistics_name"])
        ),
        selectInput(
          "stadsdeel1C",
          "Kies een buurt:",
          unique(sort(locations$neighbourhood_name))
        ),
        selectInput(
          "stadsdeel2C",
          "Kies een buurt:",
          unique(sort(locations$neighbourhood_name)),
          selected = "Osdorp Zuidoost"
        )
      ),
      conditionalPanel(
        condition = "input.sidebar == 'compare_neighbourhoods'",
        class = "filter-panel",
        selectInput(
          "theme_map_select",
          "Select theme",
          unique(statistics$theme_name)
        ),
        selectInput(
          "stat_map_select",
          "Select statistic",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
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
      tabItem(tabName = "datatable",
              h2("Data Explorer"),
              DT::dataTableOutput("datatable1")
      ),
      tabItem(
        tabName = "stadsdeel",
        
        h2("Vergelijk stadsdelen op leefbaarheid:"),
        plotlyOutput("stadsdeelchart")
      ),
      tabItem(
        tabName = "chart",
        
        h2("Vergelijk buurten op leefbaarheid:"),
        plotlyOutput("stadsdeelchart2")
      ),
      tabItem(
        tabName = "compare_neighbourhoods",
        
        h2("Vergelijk buurten"),
        fluidRow(
          box(
            id = "map_box",
            width = 6,
            title = "Selecteer de buurten die u wilt vergelijken",
            
            leafletOutput("mapSelectMulti", width = "100%")
          ),
          box(
            id = "map_graph_box",
            width = 6,
            
            plotlyOutput("map_graph")
          )
        )
        
      )
    )
  )
)