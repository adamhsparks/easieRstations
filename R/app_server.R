#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # List the first level callModules here

  shiny::shinyServer(
    function(input, output, session) {
      #nocov start
      isd_history <-
        providers <-
        JSONurl_site_list.rda <-
        current_stations_site_list.rda <-  NULL
      load(system.file("extdata", "isd_history.rda",
                       package = "GSODR"))

      load(system.file("extdata", "JSONurl_site_list.rda",
                       package = "bomrang"))

      load(system.file("extdata", "current_stations_site_list.rda",
                       package = "bomrang"))
      #nocov end

      GSODR_sites <-
        sf::st_as_sf(x = isd_history,
                     coords = c("LON", "LAT"),
                     crs = 4326)

      bom_historical_current_sites <-
        sf::st_as_sf(x = JSONurl_site_list,
                     coords = c("lon", "lat"),
                     crs = 4326)

      bom_ag_bulletin_sites <-
        sf::st_as_sf(x = stations_site_list,
                     coords = c("lon", "lat"),
                     crs = 4326)

    # Start Shiny Server ---------------------------------------------------------
    # show markers only on zoom and extract based on bounding box
    options(shiny.sanitize.errors = F)
    options(shiny.maxRequestSize = 30 * 1024 ^ 2)

    # leaflet --------------------------------------------------------------------
    output$mymap <- leaflet::renderLeaflet({
      leaflet::leaflet() %>%
        leaflet::addProviderTiles(providers$CartoDB.Positron) %>%
        leaflet.extras::addDrawToolbar(
          polylineOptions = F,
          circleOptions = T,
          markerOptions = F,
          circleMarkerOptions = F,
          polygonOptions = T
        )
    })

    shiny::observeEvent(input$map_draw_new_feature, {
      feat <- input$map_draw_new_feature
      coords <- unlist(feat$geometry$coordinates)
      coords <- matrix(coords, ncol = 2, byrow = T)
      poly <-
        sf::st_sf(sf::st_sfc(sf::st_polygon(list(coords))), crs = 4326)
    })

    #Substations <-
    # sf::st_intersection(stations, poly)
    #browser()

    pop_up_text <- paste(
      "ID: ",
      paste0(stations$STNID),
      "<br>",
      "Name: ",
      paste0(stations$NAME),
      "<br>",
      "Start Records: ",
      paste0(stations$BEGIN),
      "<br>",
      "End Records: ",
      paste0(stations$END),
      "<br>"
    )

    leaflet::leafletProxy("mymap") %>%
      leaflet::clearMarkers() %>%
      leaflet::clearMarkerClusters() %>%
      leaflet::addCircleMarkers(
        data = stations["STNID"],
        popup = pop_up_text,
        stroke = FALSE,
        radius = 5,
        fillColor = "#bb0000",
        fillOpacity = 0.5,
        clusterOptions = leaflet::markerClusterOptions()
      )


    # Handle Selector Based Events --------------------------------------------
    # TS <- shiny::eventReactive(input$data, {
    #   ObtainTimeSeries(
    #     StationID = input$StatID,
    #     Start = input$Start,
    #     End = input$End
    #   )
    # })
    #
    # shiny::observeEvent(input$data, {
    #   if (is.data.frame(TS())) {
    #     output$WeatherOUT <- DT::renderDataTable({
    #       DT::datatable(TS(), options = list(scrollX = T))
    #     })
    #   }
    # })
    #
    # output$down.csv <- shiny::downloadHandler(
    #   filename = function() {
    #     paste0(
    #       "Weather_Station",
    #       input$StatID,
    #       "_Start",
    #       input$Start,
    #       "_End",
    #       input$End,
    #       ".csv"
    #     )
    #   },
    #
    #   content = function(file) {
    #     write_csv(TS(), file)
    #   }
    #)
  })
}
