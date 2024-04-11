source("nyc_lead_prep.R", local = TRUE)



state_list<-datasets::state.abb


  
ui = fluidPage(
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_fields1, select_fields2, select_classification_method),
    
    fluidRow(column(6,"", plotOutput("plot1")),
             column(6,"", plotOutput("plot2"))),
    fluidRow(column(6,"", leafletOutput("map1")),
             column(6,"", leafletOutput("map2"))))
  
  
  server = function(input, output) {
    
    
    # get total population from census 2020
    county_census<-reactive({
      req(input$state)
      get_census_data(input$state) })
    
    
    
    output$plot1<-renderPlot({
      
      county_census()%>%st_drop_geometry() %>%  
        dplyr::select(contains("total")) %>% gather(key,value) %>% 
        group_by(key) %>% summarise(Count=sum(value)) %>% 
        filter(key!="total_pop") %>% 
        mutate(percent = prop.table(Count),  prc=paste0( "%",round(percent*100, 1)," \n(", comma(Count/1000),"K)")) %>% 
        ggplot(aes(x=key,y=Count,fill=key))+
        geom_bar(stat="identity")+
        geom_text(aes(label = prc),size=5, hjust=0.7,
                  position=position_stack(0.9))+guides(fill=FALSE)+
        labs(x="",y=" ", fill="", title = "Total Population by Race")+
        coord_flip()+theme
    })
    
    output$plot2<-renderPlot({
      
      county_census() %>%st_drop_geometry() %>%  
        dplyr::select("white_5_17","black_5_17","hispanic_5_17","asian_5_17") %>%
        gather(key,value) %>% 
        group_by(key) %>% summarise(Count=sum(value)) %>% 
        mutate(percent = prop.table(Count),  prc=paste0( "%",round(percent*100, 1)," \n(", comma(Count/1000),"K)")) %>% 
        ggplot(aes(x=key,y=Count,fill=key))+
        geom_bar(stat="identity")+
        geom_text(aes(label = prc),size=5, hjust=0.7,
                  position=position_stack(0.9))+guides(fill=FALSE)+
        labs(x="",y=" ", fill="", title = "Total Populaiton age 5-17 by Race")+
        coord_flip()+theme
    })  
    
    
    output$map1<-renderLeaflet({
      
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_census(), name="NYS counties") +
        tm_polygons(col=input$field1,style=input$classification, palette="RdYlGn")
      tmap_leaflet(tmap)
      
    })
    
    output$map2<-renderLeaflet({
      
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_census(), name="NYS counties") +
        tm_polygons(col=input$field2,style=input$classification, n=6,palette="RdYlGn")
      tmap_leaflet(tmap)
      
    })
    
  }



# Run the application 
shinyApp(ui = ui, server = server,options = list(height = 1000))





