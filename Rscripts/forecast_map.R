# script to scrape, map, and save CyAN

library(dplyr)
library(stringr)
library(readr)
library(leaflet)
library(rvest)
library(htmltools)

# source map function
source("Rscripts/plot_map.R")

# define page and location of table
forecast_page = "https://www.epa.gov/water-research/cyanobacterial-harmful-algal-blooms-forecasting-research"
table_id = '//*[@id="datatable"]'

# get the table
forecast_table = forecast_page |> 
  read_html() |> 
  html_nodes(xpath = table_id) |> 
  html_table() |> 
  first()

# see if the data are new
prev_dates = list.files("Data") |> 
  str_remove(".csv")
cur_date = forecast_table$Date[1]
if(!cur_date %in% prev_dates){
  library(gh)
  library(pandoc)
  
  pandoc::pandoc_install()
  rmarkdown::find_pandoc()
  # format table
  forecast_table = forecast_table |> 
    rename(lake = `Lake Name`,
           chance_cyanoHAB = `% Chance of CyanoHAB`,
           lat = `Latitude of Centroid`,
           lon = `Longitude of Centroid`,
           state = State) |> 
    mutate(date_start = as.Date(str_split_i(Date, " to ", 1), format="%b-%d-%Y"),
           date_end = as.Date(str_split_i(Date, " to ", 2), format="%b-%d-%Y"),
           label = paste(lake, paste0(chance_cyanoHAB, "%"), sep=" </br> ")) |> 
    rename(date_range = Date)
  # save table
  write_csv(forecast_table, file.path("Data", paste0(cur_date, ".csv")))
  
  # make and save map
  plot_map(forecast_table, cur_date)
  
  # re-render the index file to push to pages
  rmarkdown::render("index.Rmd")
}
