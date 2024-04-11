source("nyc_lead_prep.R", local = TRUE)




  
  ui = fluidPage(
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_fields1,select_fields3, select_classification_method),
    
    fluidRow(column(6,"", leafletOutput("map1")),
             column(6,"", leafletOutput("map2"))))
  
  
  server = function(input, output) {
    
    # get total population from census 2020
    county_bry<-reactive({
      req(input$state)
      get_census_data(input$state)})
    
    
    output$map1<-renderLeaflet({
      
      county_bry<- st_transform(county_bry(), crs(school_locations))
      school_locations_join<-st_join(school_locations,county_bry,join = st_intersects) %>% 
        group_by(GEOID,county) %>% summarise(school_count=n(),
                                             outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                             outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
        dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school<-county_bry%>% left_join(school_locations_join, by="GEOID")
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_with_school, name="county boundaries") +
        tm_polygons(col=input$field1,style=input$classification, n=6,palette="YlOrRd")
      tmap_leaflet(tmap)
      
    })
    
    
    output$map2<-renderLeaflet({
      
      county_bry<- st_transform(county_bry(), crs(school_locations))
      school_locations_join<-st_join(school_locations,county_bry,join = st_intersects) %>% 
        group_by(GEOID,county) %>% summarise(school_count=n(),
                                             outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                             outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
        dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school<-county_bry%>% left_join(school_locations_join, by="GEOID")
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_with_school, name="county boundaries") +
        tm_polygons(col=input$field3,style=input$classification, n=6,palette="YlOrRd")
      tmap_leaflet(tmap)
      
    })
  }


# Run the application 
shinyApp(ui = ui, server = server,options = list(height = 800))





