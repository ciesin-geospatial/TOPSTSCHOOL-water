



source("nyc_lead_prep.R", local = TRUE)

library(shiny)

state_list<-datasets::state.abb

list_of_counties<-school_lead_df %>% pull(County) %>% unique()

# ui
nyc_ui <- fluidPage(
    ## first ui element
    fluidRow(column(2),
             column(10, h2("Element 1")),
             column(2)),
    fluidRow(column(2),
             column(4, selectInput("county1", label = "Select a county",
                                   choices = list_of_counties, selected = "Bronx")),
             column(4, selectInput("fields1", label = "Select fields",
                                   choices = lead_data_all_fields, 
                                   selected = "County", multiple = TRUE)),
             column(2)),
    fluidRow(column(1),
             column(10, DT::dataTableOutput("table")),
             column(1)),
             
    ## second ui element
    fluidRow(column(2),
             column(10, h2("Element 2")),
             column(2)),
    fluidRow(style = "padding-bottom: 30px;background-color:#f1f2f3;",
             column(3, selectInput("county2", 
                                   label = "Select a county",
                                   choices = list_of_counties, 
                                   selected = "All counties"))),
    fluidRow(column(1),
             column(10,leafletOutput("map")),
             column(1)),
    
    #third ui element
    fluidRow(column(2),
             column(10, h2("Element 3")),
             column(2)),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_fields1, select_fields2, select_classification_method),
    
    fluidRow(column(6,"", plotOutput("plot1")),
             column(6,"", plotOutput("plot2"))),
    fluidRow(column(6,"", leafletOutput("map1")),
             column(6,"", leafletOutput("map2"))),

    #fourth ui element
    fluidRow(column(2),
             column(10, h2("Element 4")),
             column(2)),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_county),
    
    fluidRow(column(5,"", plotOutput("plot3")),
             column(7,"", leafletOutput("map3"))),

    #fifth ui element
    fluidRow(column(2),
             column(10, h2("Element 5")),
             column(2)),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_fields1,select_fields3, select_classification_method),
    
    fluidRow(column(6,"", leafletOutput("map4")),
             column(6,"", leafletOutput("map5"))),
    #sixth ui element
    fluidRow(column(2),
             column(10, h2("Element 6")),
             column(2)),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,out_map_field, select_classification_method),
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             column(3, textInput("title", "add map title", "")),
             column(3, textInput("legendtitle", "add legend title", "")), 
             column(3, downloadButton("download_map",label = "Download map"))),
    
    fluidRow(column(10,"", leafletOutput("map6")))
             )


# server
server <- function(input, output) {
    ## first ui element server code
    output$table<- DT::renderDataTable({
        if (input$county1=="All Counties")
        {school_lead_df |> dplyr::select(input$fields1) }
        
        else(school_lead_df |> filter(County==input$county1)|> dplyr::select(input$fields1))
    })
    
    ## second ui element server code
    school_loc<-reactive({school_locations |> filter(County==input$county2)})
    output$map<-renderLeaflet({
        
        tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
            tm_shape(school_loc(), name="school locations") +
            tm_dots(id="",col="County",palette="magma",
                    popup.vars=c("School name: "="School" ),
                    legend.show = FALSE)
        tmap_leaflet(tmap)
    })

    #third server element
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
    
    #fourth server element 
    counties_bry <- reactive({req(input$state)
      get_census_data(input$state) })
    
    school_loc1 <- reactive({school_locations %>%filter(County==input$county)})
    
    
    output$plot3<-renderPlot({
      if (input$county=="All counties"){school_lead_df_<-school_lead_df}
      else{school_lead_df_<-school_lead_df %>% filter(County==input$county)}
      school_lead_df_ %>%  
        group_by(lead_summary_by_school) %>% summarize(Count=n()) %>%
        mutate(percent = prop.table(Count),  prc=paste0( "   %",round(percent*100, 1)," (", comma(Count),")")) %>%
        ggplot(aes(x=lead_summary_by_school,
                   y=Count,fill=lead_summary_by_school))+
        geom_bar(stat="identity")+
        geom_text(aes(label = prc),size=5,
                  position=position_stack(0.9))+guides(fill=FALSE)+
        scale_fill_manual(values=c("green3","red","grey"))+
        labs(x="",y="Count of School", fill="", title = "Count of schools based on lead status",
             caption="has lead < 15ppb: None of the outlets have lead over 15ppb\nhas lead >15ppb: At least a outlet has lead over 15ppb")+theme
    })
    
    
    output$map3<-renderLeaflet({
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(counties_bry() , name="NYS counties") +tm_polygons("black",alpha=0,popup.vars=c("County Name :  "="county"))+
        tm_shape(counties_bry() ,name="NYS counties ") +  tm_borders("black", lwd = 2) +
        tm_shape(school_loc1(), name="School locations") +
        tm_dots(id="something",col="lead_summary_by_school",palette=c("has lead < 15ppb"="green","has lead < 15ppb"="red"),
                popup.vars=c("School: "="School" ),
                legend.show = FALSE)
      tmap_leaflet(tmap)
      
    })

    #fifth server element
    # get total population from census 2020
    county_bry<-reactive({
      req(input$state)
      get_census_data(input$state)})
    
    
    output$map4<-renderLeaflet({
      
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
    
    
    output$map5<-renderLeaflet({
      
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
    
    #sixth server element
    # get total population from census 2020
    county_bry2<-reactive({
      req(input$state)
      get_census_data(input$state)})
    
    
    output$map6<-renderLeaflet({
      
      county_bry2<- st_transform(county_bry2(), crs(school_locations))
      school_locations_join<-st_join(school_locations,county_bry2,join = st_intersects) %>% 
        group_by(GEOID,county) %>% summarise(school_count=n(),
                                             outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                             outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
        dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school<-county_bry2%>% left_join(school_locations_join, by="GEOID")
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_with_school, name="county boundaries") +
        tm_polygons(col=input$fields_map,style=input$classification, n=6,palette="YlOrRd")
      tmap_leaflet(tmap)

      
    })
    
  
    map_expr <- reactive({  county_bry2<- st_transform(county_bry2(), crs(school_locations))
    school_locations_join<-st_join(school_locations,county_bry,join = st_intersects) %>% 
      group_by(GEOID,county) %>% summarise(school_count=n(),
                                           outlets_under_15_ppb=sum(Number_of_Outlets_under_15_ppb, na.rm =TRUE),
                                           outlets_above_15_ppb=sum(Number_of_Outlets_above_15_ppb, na.rm=TRUE)) %>% 
      dplyr::select(GEOID,county,school_count,outlets_under_15_ppb,outlets_above_15_ppb) %>% st_drop_geometry()
    county_with_school<-county_bry2%>% left_join(school_locations_join, by="GEOID")
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
shinyApp(ui = nyc_ui, server = server)
