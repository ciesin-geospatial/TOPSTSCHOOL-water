source("nyc_lead_prep.R", local = TRUE)




  
  ui = fluidPage(
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,out_map_field, select_classification_method),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             column(3, textInput("title", "add map title", "")),
             column(3, textInput("legendtitle", "add legend title", "")), 
             column(3, downloadButton("download_map",label = "Download map"))),
    
    fluidRow(column(10,"", leafletOutput("map"))))
  
  
  server = function(input, output) {
    
    # get total population from census 2020
    county_bry<-reactive({
      req(input$state)
      get_census_data(input$state)})
    
    
    output$map<-renderLeaflet({
      
      county_bry<- st_transform(county_bry(), crs(school_locations))
      school_locations_join<-st_join(school_locations,county_bry,join = st_intersects) %>% 
        group_by(GEOID,county) %>% summarise(school_count=n(),
                                             outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                             outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
        dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school<-county_bry%>% left_join(school_locations_join, by="GEOID")
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_with_school, name="county boundaries") +
        tm_polygons(col=input$fields_map,style=input$classification, n=6,palette="YlOrRd")
      tmap_leaflet(tmap)

      
    })
    
  
    map_expr <- reactive({  county_bry<- st_transform(county_bry(), crs(school_locations))
    school_locations_join<-st_join(school_locations,county_bry,join = st_intersects) %>% 
      group_by(GEOID,county) %>% summarise(school_count=n(),
                                           outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                           outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
      dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
    county_with_school<-county_bry%>% left_join(school_locations_join, by="GEOID")
    tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
      tmap::tm_shape(county_with_school, name="county boundaries") +
      tm_polygons(col=input$fields_map,style=input$classification, n=6,palette="YlOrRd", title=input$legendtitle)+
      tm_scale_bar(position=c("center", "bottom"))+tm_compass(position=c("right", "top"))+
      tm_layout(legend.position = c("left", "bottom"),
                main.title = input$title, 
                main.title.position = "center")
   
    })
    
    
    output$download_map <- downloadHandler(
      filename =paste0(input$state,"_",input$fields_map,"_",input$classification,"_classification.png"),
      content = function(file) {
        tmap_save(map_expr(), file = file)
      })
    
  }


# Run the application 
shinyApp(ui = ui, server = server,options = list(height = 800))





