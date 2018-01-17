# Load all source files here!
source("mysql.R")
source("init.R")
source("render.R")

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Amsterdam Statistiek", titleWidth = 300),
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
      # Map Filter Panel -----------------------------------------------------------------------------------
      conditionalPanel(
        condition = "input.sidebar == 'map'",
        class = "filter-panel",
        selectInput(
          "theme_map_select",
          "Kies een thema:",
          unique(statistics$theme_name)
        ),
        selectInput(
          "stat_map_select",
          "Kies een statistiek:",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        ),
        sliderInput("year", "Kies een jaar:", 2005, 2017, 2017, step = 1, sep = "")
      ),
      # Menu ------------------------------------------------------------------------------------------------------------
      menuItem(
        "Grafieken",
        tabName = "chart",
        icon = icon("bar-chart-o"),
        menuSubItem("Vergelijk stadsdeel", tabName = "district"),
        menuSubItem("Vergelijk buurten", tabName = "neighbourhood"),
        menuSubItem("Vergelijk buurten met kaart", tabName = "compare_neighbourhoods"),
        menuSubItem("Correlatie tussen stadsdelen", tabName = "correlation")
      ),
      # Compare district Filter Panel -----------------------------------------------------------------------------------
      conditionalPanel(
        condition = "input.sidebar == 'district'",
        class = "filter-panel",
        selectInput(
          "theme_compare_district",
          "Kies een thema:",
          unique(statistics$theme_name)
        ),
        selectInput(
          "statistic_compare_district",
          "Kies een statistiek:",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        ),
        selectInput(
          "district_compare_one",
          "Kies een stadsdeel:",
          unique(sort(locations$district_name))
        ),
        selectInput(
          "district_compare_two",
          "Kies een stadsdeel:",
          unique(sort(locations$district_name)),
          selected = "Zuid"
        )
      ),
      # Compare neighbourhood Filter Panel -----------------------------------------------------------------------------------
      conditionalPanel(
        condition = "input.sidebar == 'neighbourhood'",
        class = "filter-panel",
        selectInput(
          "theme_compare_neighbourhood",
          "Kies een thema:",
          unique(statistics$theme_name)
        ),
        selectInput(
          "statistic_compare_neighbourhood",
          "Kies een statistiek:",
          split(statistics[which(statistics$statistics_unit == 2), "statistics_variable"], statistics[which(statistics$statistics_unit == 2), "statistics_name"])
        ),
        selectInput(
          "neighbourhood_compare_one",
          "Kies een buurt:",
          unique(sort(locations$neighbourhood_name))
        ),
        selectInput(
          "neighbourhood_compare_two",
          "Kies een buurt:",
          unique(sort(locations$neighbourhood_name)),
          selected = "Osdorp Zuidoost"
        )
      ),
      # Compare neighbourhood by map Filter Panel -----------------------------------------------------------------------------------
      conditionalPanel(
        condition = "input.sidebar == 'compare_neighbourhoods'",
        class = "filter-panel",
        selectInput(
          "theme_map_select",
          "Kies een thema:",
          unique(statistics$theme_name)
        ),
        selectInput(
          "stat_map_select",
          "Kies een statistiek:",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        )
      ),
      # Correlation Filter Panel ----------------------------------------------------------------------------------------------------
      conditionalPanel(
        condition = "input.sidebar == 'correlation'",
        class = "filter-panel",
        selectInput(
          "theme_corr_select_1",
          "Kies een thema:",
          correlation_themes
        ),
        selectInput(
          "stat_corr_select_1",
          "Kies een statistiek:",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        ),
        selectInput(
          "theme_corr_select_2",
          "Kies een thema:",
          correlation_themes
        ),
        selectInput(
          "stat_corr_select_2",
          "Kies een statistiek:",
          choices = c("Bevolking totaal" = "BEVTOTAAL")
        ),
        selectInput(
          "neighbourhood_corr",
          "Kies een stadsdeel:",
          choices = split(district_map$Stadsdeel_code, district_map$Stadsdeel),
          selected = "Centrum"
        )
      ),
      menuItem("Data explorer", tabName = "datatable", icon = icon("table")),
      sidebarMenuOutput("dynamicsidebar")
    )
  ),
  # Dashboard body -----------------------------------------------------------------------------------------------------------------
  dashboardBody(
    useShinyjs(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "theme.css")
    ),
    # Dashboard tab ----------------------------------------------------------------------------------------------------------------
    tabItems(
      tabItem(tabName = "dashboard",
        fluidPage(
          fluidRow(
            column(1,
                  img(src = "amsterdam.png", height = "100px")
                   )
          ),
          fluidRow(
            h5("Welkom, Amsterdammer!"),
            
            h5("Voor u ziet u de totaal vernieuwde applicatie van de afdeling Onderzoek, Informatie en Statistiek van de Gemeente Amsterdam. Deze applicatie voorziet u van verschillende kerncijfers en informatie over de stadsdelen en buurten in Amsterdam. Deze informatie is gericht op het informeren van de inwoners van Amsterdam op het gebied van leefbaarheid."),
            
            h5("De volgende drie dingen kunnen in de applicatie worden gedaan:"),
            
            h5("1. Informatie over alle buurten van Amsterdam met betrekking tot de leefbaarheid in de buurt."),
            
            h5("2. Vergelijken van verschillende buurten, waarbij je statistieken kan vergelijken en verbanden kunt vinden."),
            
            h5("3. Datatabel om alle data te bekijken."),
            
            h5("De afdeling Onderzoek, Informatie en Statistiek (OIS) voorziet Amsterdam van informatie over de stad. Het vergaren van informatie gebeurt door middel van eigen onderzoek en door het raadplegen van onderzoek en kennis van buiten. Zij adviseren en faciliteren bij de totstandkoming van de gegevens data en de toegankelijkheid daarvan. Op de website van OIS is het mogelijk om informatie over de stad terug te vinden en op te halen. Er zijn verschillende feiten en cijfers te vinden over de stad welke ook gevisualiseerd zijn. Door op een van deze visualisaties te klikken opent er een scherm waarin het mogelijk is om informatie op te vragen over het gekozen onderwerp.")
          ),
          tags$head(
            tags$style(HTML('#run{background-color: #f2f2f2}'))
          ),
          fillRow(
            style = "margin-top: 50px;",
            
            column(12, align = "center",
              actionButton("button_map", label = img(src = "map.png", height = "100px")),
              h5("Interactieve Map")
            ),
            
            column(12, align = "center",
             actionButton("button_chart", label = img(src = "chart.png", height = "100px")),
             h5("Grafieken")
            ),
            
            column(12, align = "center",
             actionButton("button_data", label = img(src = "dataexplorer.png", height = "100px")),
             h5("Data Explorer")
            )
          )
        )     
      ),
      tabItem(
        tabName = "map",
        
        fluidRow(
          tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
          leafletOutput("map", width = "100%"),
          
          tags$style(type = 'text/css', ".selectize-dropdown-content {max-height: 150px; }")
        )
      ),
      # Data explorer tab ---------------------------------------------------------------------------------------------------------
      tabItem(tabName = "datatable",
              h2("Data Explorer"),
              DT::dataTableOutput("datatable")
      ),
      # District tab ---------------------------------------------------------------------------------------------------------------
      tabItem(
        tabName = "district",
        
        h2("Vergelijk stadsdelen:"),
        plotlyOutput("district_chart")
      ),
      # Chart tab ---------------------------------------------------------------------------------------------------------------
      tabItem(
        tabName = "neighbourhood",
        
        h2("Vergelijk buurten:"),
        plotlyOutput("neighbourhood_chart")
      ),
      # Compare_neighbourhoods --------------------------------------------------------------------------------------------------
      tabItem(
        tabName = "compare_neighbourhoods",
        
        h2("Vergelijk buurten op kaart"),
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
      ),
      # Correlation tab ------------------------------------------------------------------------------------------------------
      tabItem(
        tabName = "correlation",
        
        h2("Correlatie tussen stadsdelen"),
        fluidPage(
          column(
            6,
            box(
              id = "corr_table",
              width = 12,
              
              DT::dataTableOutput("corr_table_data")
            ),
            box(
              id = "map_box",
              width = 12,
              
              leafletOutput("mapSelectCorr", width = "100%")
            )
          ),
          column(
            6,
            box(
              id = "corr_message_box",
              width = 12,
              
              h4(textOutput("corr_message"))
            ),
            box(
              id = "corr_graph_box_1",
              width = 12,
              
              plotlyOutput("corr_graph_1")
            ),
            box(
              id = "corr_graph_box_2",
              width = 12,
              
              plotlyOutput("corr_graph_2")
            )
          )
        )
        
      )
    )
  )
)