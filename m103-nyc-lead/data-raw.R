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

get_data<-"https://raw.githubusercontent.com/ciesin-geospatial/TOPSTSCHOOL-module-1-water/main/m103-nyc-lead/Lead_Testing_in_School_Drinking_Water_Sampling_and_Results_Compliance_Year_2016.csv"
school_lead_df<-readr::read_csv(url(get_data))

# extract xy coordinates
school_lead_df<-school_lead_df |> mutate(location_temp=str_extract(Location,"(?<=\\().*(?=\\))")) |> 
  tidyr::separate(location_temp,c("lat","long"),sep=",")


# remove space from fields names
names(school_lead_df) <- names(school_lead_df) |> stringr::str_replace_all("\\s","_")

# extract year fro date field. we are using Date_Results_Updated for the date
school_lead_df<-school_lead_df |>  mutate(year=format(as.Date(Date_Results_Updated, format="%d/%m/%Y"),"%Y"))

school_lead_df<-school_lead_df |>  mutate(lead_summary_by_school=case_when(
  Number_of_Outlets_above_15_ppb ==0~ "Lead Levels < 15ppb",
  Number_of_Outlets_above_15_ppb >0~ "Lead Levels > 15ppb",
  TRUE ~ "no data"))

school_locations<-school_lead_df |> filter(!is.na(lat)) |> 
  # convert the dataset to spatial dataset by using WGS84 projection
  st_as_sf(coords = c("long", "lat"),crs = "+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0") 
school_locations_all<-school_locations %>% mutate(County="All Counties")
school_locations<-bind_rows(school_locations,school_locations_all)
# get te census data
county_census<-get_census_data("NY")
county_census$county <- gsub(" County", "", county_census$county)

county_bry <- st_transform(county_census, crs(school_locations))
school_locations_join <-
  st_join(school_locations , county_bry, join = st_intersects) %>%
  group_by(GEOID, county) %>% summarise(
    school_count = n(),
    outlets_under_15_ppb = sum(Number_of_Outlets_under_15_ppb, na.rm =
                                 TRUE),
    outlets_above_15_ppb = sum(Number_of_Outlets_above_15_ppb, na.rm =
                                 TRUE)) %>%
  dplyr::select(GEOID,
                county,
                school_count,
                outlets_under_15_ppb,
                outlets_above_15_ppb) %>% st_drop_geometry()
county_with_school <-
  county_bry %>% left_join(school_locations_join, by = "GEOID")

save(county_census, 
     school_lead_df,
     school_locations, 
     county_with_school, 
     file = file.path(getwd(), "nyc_lead_dats.RData"))