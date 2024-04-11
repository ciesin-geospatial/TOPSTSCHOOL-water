



source("nyc_lead_prep.R", local = TRUE)

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
             column(1)))


# server
server <- function(input, output) {
    ## first ui element server code
    output$table<- DT::renderDataTable({
        if (input$county1=="All Counties")
        {school_lead_df |> dplyr::select(input$fields1) }
        
        else(school_lead_df |> filter(County==input$county1)|> dplyr::select(input$fields1))
    })
    
    
}

# Run the application 
shinyApp(ui = nyc_ui, server = server)
