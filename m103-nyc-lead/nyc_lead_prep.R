library(tidyverse)
library(readr)
library(scales)
library (sf)
library(tmap)
library(leaflet)
library(tools)
library(raster)
library(shiny)
library(tidycensus)
library(DT)
library(datasets)
library(shinyWidgets)
library(mapview)
library(bslib)
# this changes prepairing all the datasets for following sections
# quarto require all inputs in shiny application to be in the same chink and 
# the chunk should be context="data"
# this section will not be visible to user
# However each part of the process will be visble to user in their respective section


### ===== selection by dropdowns ===========###

state_list <- datasets::state.abb
list_of_counties <- school_lead_df |> dplyr::pull(County) |> unique()
list_of_counties <- append("All Counties", sort(list_of_counties))
field_list <-
  c("total_white",
    "total_black",
    "total_asian",
    "total_hispanic",
    "white_5_17",
    "black_5_17",
    "hispanic_5_17",
    "asian_5_17")
classification_methods <-
  c("sd", "equal", "pretty", "quantile", "jenks")
lead_field_list <-
  c("school_count",
    "outlets_under_15_ppb",
    "outlets_above_15_ppb")
lead_data_all_fields <- names(school_lead_df) |> unique()
out_map_field_list <- c(field_list, lead_field_list)

theme <-
  ggplot2::theme(
    axis.text = ggplot2::element_text(size = 12, face = "bold"),
    axis.title = ggplot2::element_text(size = 13, face = "bold"),
    plot.title = ggplot2::element_text(size = 13, face = "bold"),
    panel.background = ggplot2::element_rect(fill = "lightblue", colour = "grey"))


#----

# In the datasets xy coordinates of schools  are combined with school address and recorded under
# location field as 231-02 67 AVENUEQueens, NY 11364(40.74779141700003, -73.74551716499997)
# (40.74779141700003, -73.74551716499997) needs to be extracted and sparated by "," and 
# saved undr different fields names
# line below extract xy coordinates and save under "lat","long" fields
#school_lead_df<-school_lead_df |> mutate(location_temp=str_extract(Location,"(?<=\\().*(?=\\))")) |> 
  #separate(location_temp,c("lat","long"),sep=",")






