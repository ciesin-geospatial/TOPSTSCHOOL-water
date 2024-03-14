source("nyc-lead-prep.R", local = TRUE)

library(shiny)
# ui
nyc_ui <- fluidPage(
  ## first ui element
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
  fluidRow(style = "padding-bottom: 30px;background-color:#f1f2f3;",
           column(3, selectInput("county2", 
                                 label = "Select a county",
                                 choices = list_of_counties, 
                                 selected = "Bronx"))),
  fluidRow(column(1),
           column(10,leafletOutput("map")),
           column(1)))

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
    
    
    #  if (input$county=="All Counties"){school_loc <-school_locations
    #    tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
    #   tm_shape(school_loc, name="school locations") +
    #   tm_dots(id="",col="County",palette="magma",
    #         popup.vars=c("School name: "="School" ),
    #         legend.show = FALSE)
    # tmap_leaflet(tmap)
    #  }
    #   
    #   else{school_loc <-school_locations |> filter(County==input$county)
    
    tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
      tm_shape(school_loc(), name="school locations") +
      tm_dots(id="",col="County",palette="magma",
              popup.vars=c("School name: "="School" ),
              legend.show = FALSE)
    tmap_leaflet(tmap)
  })
  
}

# Run the application 
shinyApp(ui = nyc_ui, server = server)
