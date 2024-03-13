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
library(shinythemes)

# this changes prepairing all the datasets for following sections
# quarto require all inputs in shiny application to be in the same chink and 
# the chunk should be context="data"
# this section will not be visible to user
# However each part of the process will be viisble to user in their respective section


##setwd("D:/Grid3/school_lead_data")
#school_lead_data<-"Lead_Testing_in_School_Drinking_Water_Sampling_and_Results_Compliance_Year_2016.csv"
get_data<-"https://raw.githubusercontent.com/ciesin-geospatial/TOPSTSCHOOL-module-1-water/main/Lead_Testing_in_School_Drinking_Water_Sampling_and_Results_Compliance_Year_2016.csv"
school_lead_df<-readr::read_csv(url(get_data))

# extract xy coordinates
school_lead_df<-school_lead_df |> mutate(location_temp=str_extract(Location,"(?<=\\().*(?=\\))")) |> 
  tidyr::separate(location_temp,c("lat","long"),sep=",")


# remove space from fields names
names(school_lead_df) <- names(school_lead_df) |> stringr::str_replace_all("\\s","_")


# extract year fro date field. we are using Date_Results_Updated for the date
school_lead_df<-school_lead_df |>  mutate(year=format(as.Date(Date_Results_Updated, format="%d/%m/%Y"),"%Y"))

school_lead_df<-school_lead_df |>  mutate(lead_summary_by_school=case_when(
  Number_of_Outlets_above_15_ppb ==0~ "has lead < 15ppb",
  Number_of_Outlets_above_15_ppb >0~ "has lead >15ppb",
  TRUE ~ "no data"))

school_locations<-school_lead_df |> filter(!is.na(lat)) |> 
  # convert the dataset to spatial dataset by using WGS84 projection
  st_as_sf(coords = c("long", "lat"),crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") 

get_census_data<- function(state_abr){
  census_api_key("94dee3107dc86d32c8039896b244eeb4aad72eb7")
  county_census<-get_decennial(
    geography = "county", 
    variables = c("total_pop"="P1_001N","total_white"="P1_003N", "total_black"="P1_004N",
                  "total_asian"="P1_006N","total_hispanic"="P2_002N"),
    year = 2020,
    state=state_abr,
    output = "wide") |> dplyr::select(GEOID,total_pop,total_white,total_black, total_asian,total_hispanic)
  # get school age (5-17) population estimates from ACS 
  county_acs<- get_acs(
    geography = "county", 
    variables = c("white_5_9"="B01001A_004","white_10_14"="B01001A_005","white_15_17"="B01001A_006",
                  "black_5_9"="B01001B_004","black_10_14"="B01001B_005","black_15_17"="B01001B_006",
                  "asian_5_9"="B01001D_004","asian_10_14"="B01001D_005","asian_15_17"="B01001D_006",
                  "hispanic_5_9"="B01001I_004","hispanic_10_14"="B01001I_005","hispanic_15_17"="B01001I_006"),
    year = 2020,
    state=state_abr,
    output = "wide",
    geometry = TRUE) |> mutate(white_5_17=white_5_9E+white_10_14E+white_15_17E,
                               black_5_17=black_5_9E+black_10_14E+black_15_17E,
                               asian_5_17=asian_5_9E+asian_10_14E+asian_15_17E,
                               hispanic_5_17=hispanic_5_9E+hispanic_10_14E+hispanic_15_17E)
  
  county_population<-county_acs |> left_join(county_census, by="GEOID")|>  
    separate(NAME, c("county","state"),",")
  return (county_population)}


### ===== selection by dropdowns ===========###

state_list<-datasets::state.abb
list_of_counties<-school_lead_df |> pull(County) |> unique()
list_of_counties<-append(list_of_counties,"All Counties")
field_list<-c("total_white","total_black","total_asian","total_hispanic",
              "white_5_17","black_5_17","hispanic_5_17","asian_5_17")
classification_methods<-c("sd", "equal", "pretty", "quantile", "jenks")
lead_field_list<-c("school_count","outlets_under_15_ppb","outlets_above_15_ppb")
lead_data_all_fields<-names(school_lead_df ) |> unique()


select_state<-column(3, selectInput("state", label = "Select a state",
                                    choices = state_list, selected = "NY"))
select_county<-column(3, selectInput("county", label = "Select a county",
                                     choices = list_of_counties, selected = "Bronx"))
select_fields1<-column(3, selectInput("field1", label = "Select a field for map (left)",
                                      choices = field_list, selected = "total_white"))
select_fields2<-column(3, selectInput("field2", label = "Select a field for maps (right)",
                                      choices = field_list, selected = "white_5_17"))
select_classification_method<-column(3, selectInput("classification", label = "Classification method",
                                                    choices = classification_methods, selected = "jenks"))
select_fields3<-column(3, selectInput("field3", label = "Select a field",
                                      choices = lead_field_list, selected = "school_count"))
select_fields4<-  column(4, selectInput("fields", label = "Select fields",
                                        choices = lead_data_all_fields, selected = "County",multiple = TRUE))

theme<-theme(axis.text=element_text(size=12, face="bold"),
             axis.title=element_text(size=13, face="bold"),
             plot.title=element_text(size=13, face="bold"),
             panel.background = element_rect(fill = "lightblue",colour = "grey")
)


#----

# In the datasets xy coordinates of schools  are combined with school address and recorded under
# location field as 231-02 67 AVENUEQueens, NY 11364(40.74779141700003, -73.74551716499997)
# (40.74779141700003, -73.74551716499997) needs to be extracted and sparated by "," and 
# saved undr different fields names
# line below extract xy coordinates and save under "lat","long" fields
school_lead_df<-school_lead_df |> mutate(location_temp=str_extract(Location,"(?<=\\().*(?=\\))")) |> 
  separate(location_temp,c("lat","long"),sep=",")

# line below create geometry attributes by using lat long fields and 
# geographic coordinate system
# this step allow us to map the school locations and do some geospatial anaylysis
school_locations<-school_lead_df |>  filter(!is.na(lat)) |> 
  # convert the dataset to spatial dataset by using WGS84 projection
  st_as_sf(coords = c("long", "lat"),crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") 