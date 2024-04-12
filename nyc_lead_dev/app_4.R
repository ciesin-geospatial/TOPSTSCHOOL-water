source("nyc_lead_prep.R", local = TRUE)



state_list<-datasets::state.abb
list_of_counties<-school_lead_df %>% pull(County) %>% unique()


  
  ui = fluidPage(
    fluidRow(style = "padding-bottom: 20px;background-color:#f1f2f3;",
             select_state,select_county),
    
    fluidRow(column(5,"", plotOutput("plot")),
             column(7,"", leafletOutput("map"))))
  
  
  server = function(input, output) {
    counties_bry <- reactive({req(input$state)
      get_census_data(input$state) })
    
    school_loc <- reactive({school_locations %>%filter(County==input$county)})
    
    
    output$plot<-renderPlot({
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
    
    
    output$map<-renderLeaflet({
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(counties_bry() , name="NYS counties") +tm_polygons("black",alpha=0,popup.vars=c("County Name :  "="county"))+
        tm_shape(counties_bry() ,name="NYS counties ") +  tm_borders("black", lwd = 2) +
        tm_shape(school_loc(), name="School locations") +
        tm_dots(id="something",col="lead_summary_by_school",palette=c("has lead < 15ppb"="green","has lead < 15ppb"="red"),
                popup.vars=c("School: "="School" ),
                legend.show = FALSE)
      tmap_leaflet(tmap)
      
    })
  }

# Run the application 
shinyApp(ui = ui, server = server,options = list(height = 600))





