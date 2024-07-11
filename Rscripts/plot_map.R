# function to make and optionally save a leaflet map of the forecast
plot_map <- function(forecast_df, dates, save_map = T){
  # define color palette 
  pal_use = colorNumeric("viridis", 0:100)
  # html tag for map title
  tag.map.title = htmltools::tags$style(HTML("
                                  .leaflet-control.map-title {
                                  transform: translate(50%,50%);
                                  position: fixed !important;
                                  left: 50%;
                                  text-align: center;
                                  padding-left: 10px;
                                  padding-right: 10px;
                                  background: rbga(255,255,255,0.75);
                                  font-weight: bold;
                                  font-size: 28px;
                                  }
                                  "))
  title = htmltools::tags$div(tag.map.title, HTML(dates))
  
  #make the map
  map_out = leaflet(data= forecast_table) %>% 
    addProviderTiles("OpenStreetMap.Mapnik") %>% 
    addCircleMarkers(lng=~lon, lat=~lat, color=~pal_use(chance_cyanoHAB), label = lapply(forecast_table$label, htmltools::HTML)) %>% 
    addControl(title, position="topleft", className = "map-title")
  
  # save the map
  if(save_map == TRUE){
    htmlwidgets::saveWidget(map_out,
                            file.path("Maps", paste0("CyAN_forecast_map_", dates, ".html")),
                            selfcontained = T,
                            title = dates)
  }
  
}