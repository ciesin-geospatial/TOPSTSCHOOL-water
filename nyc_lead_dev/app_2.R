source("nyc_lead_prep.R", local = TRUE)



library(shiny)
# ui
nyc_ui <- fluidPage(
    ## second ui element
    fluidRow(style = "padding-bottom: 30px;background-color:#f1f2f3;",
             column(3, selectInput("county2", 
                                   label = "Select a county",
                                   choices = list_of_counties, 
                                   selected = "All counties"))),
    fluidRow(column(1),
             column(10,leafletOutput("map")),
             column(1)))

# server
server <- function(input, output) {

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
    
}

# Run the application 
shinyApp(ui = nyc_ui, server = server)
