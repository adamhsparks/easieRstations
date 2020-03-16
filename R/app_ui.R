
#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {

  header <- providers <- sidebar <- NULL #nocov
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here
    shinydashboard::dashboardHeader(
      # dashboard header -------------------------------------------------------
      title = paste(
        "easieRstations v",
        utils::packageVersion("easieRstations"),
        sep = "",
        collapse = ""
      ),
      titleWidth = 300
    ),

    shinydashboard::dashboardSidebar(
      # dashboard sidebar ------------------------------------------------------
      shinydashboard::sidebarMenu(
        id = "tab_menu",
        shinydashboard::menuItem(
          "Map",
          tabName = "map",
          icon = shiny::icon("map-marked-alt"),
          selected = TRUE
        ),
        shinydashboard::menuItem(
          "Download",
          icon = shiny::icon("book-open"),
          tabName = "download"
        )
      ),
      width = 150
    ),

    shinydashboard::dashboardBody(
      # content tab map viewer -------------------------------------------------
      shinydashboard::tabItems(
        shinydashboard::tabItem(tabName = "map",
                                #h2("Dashboard tab content")
                                shiny::fluidRow(
                                  shinydashboard::box(
                                    width = 12,
                                    solidHeader = TRUE,
                                    leaflet::leafletOutput("mymap",
                                                           height = 1000)
                                  )
                                )),
        shinydashboard::tabItem(
          tabName = "download",
          shiny::fluidRow(
            shinydashboard::box(width = 3,
                                shiny::textInput("StatID",
                                                 "Station ID")),
            shinydashboard::box(width = 3,
                                shiny::numericInput("Start",
                                                    "Start",
                                                    value = 2000)),
            shinydashboard::box(width = 3,
                                shiny::numericInput("End",
                                                    "End",
                                                    value = 2018)),
            shinydashboard::box(width = 3,
                                shiny::actionButton("data",
                                                    "Create Time-Series:"))
          ),
          shiny::fluidRow(DT::dataTableOutput("WeatherOUT")),
          shiny::fluidRow(shinydashboard::box(
            width = 3,
            shiny::downloadButton("down.csv", "Download CSV")
          ))
        )
      ),
      shinybusy::add_busy_spinner()
    ),

    shinydashboard::dashboardPage(header,
                                  sidebar,
                                  body)
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path('www', app_sys('app/www'))

  tags$head(favicon(),
            bundle_resources(path = app_sys('app/www'),
                             app_title = 'easieRstations')
            # Add here other external resources
            # for example, you can add shinyalert::useShinyalert()
            )
}
