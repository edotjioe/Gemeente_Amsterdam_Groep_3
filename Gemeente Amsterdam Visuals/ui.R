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
        fluidPage(
          fluidRow(
            column(1,
                  img(src = "amsterdam.png", height = "100px")
                   )
          ),
          fluidRow(
            h5("Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Aenean commodo ligula eget dolor. Aenean massa. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Donec quam felis, ultricies nec, pellentesque eu, pretium quis, sem. Nulla consequat massa quis enim. Donec pede justo, fringilla vel, aliquet nec, vulputate eget, arcu. In enim justo, rhoncus ut, imperdiet a, venenatis vitae, justo. Nullam dictum felis eu pede mollis pretium. Integer tincidunt. Cras dapibus. Vivamus elementum semper nisi. Aenean vulputate eleifend tellus. Aenean leo ligula, porttitor eu, consequat vitae, eleifend ac, enim. Aliquam lorem ante, dapibus in, viverra quis, feugiat a, tellus. Phasellus viverra nulla ut metus varius laoreet. Quisque rutrum. Aenean imperdiet. Etiam ultricies nisi vel augue. Curabitur ullamcorper ultricies nisi. Nam eget dui.

               Etiam rhoncus. Maecenas tempus, tellus eget condimentum rhoncus, sem quam semper libero, sit amet adipiscing sem neque sed ipsum. Nam quam nunc, blandit vel, luctus pulvinar, hendrerit id, lorem. Maecenas nec odio et ante tincidunt tempus. Donec vitae sapien ut libero venenatis faucibus. Nullam quis ante. Etiam sit amet orci eget eros faucibus tincidunt. Duis leo. Sed fringilla mauris sit amet nibh. Donec sodales sagittis magna. Sed consequat, leo eget bibendum sodales, augue velit cursus nunc, quis gravida magna mi a libero. Fusce vulputate eleifend sapien. Vestibulum purus quam, scelerisque ut, mollis sed, nonummy id, metus. Nullam accumsan lorem in dui. Cras ultricies mi eu turpis hendrerit fringilla. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; In ac dui quis mi consectetuer lacinia.")
          ),
          
          fillRow(
            style = "margin-top: 50px;",
            column(12, align = "center",
              tags$button(
                id = "a",
                class = "btn action_button",
                img(src = "map.png", height = "100px")
              ),
              h5("Map")
            ),
            
            column(12, align = "center",
             tags$button(
               id = "a",
               class = "btn action_button",
               img(src = "chart.png", height = "100px")
             ),
             h5("Chart")
            ),
            
            column(12, align = "center",
             tags$button(
               id = "a",
               class = "btn action_button",
               img(src = "dataexplorer.png", height = "100px")
             ),
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