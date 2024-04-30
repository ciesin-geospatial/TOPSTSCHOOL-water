nyc_ui <- 
  bslib::nav_panel(
    "NYC School Lead Explorer",
    fluidPage(
      # make input labels bold and different color from written text/narrative
      tags$head(tags$style(
        HTML(
          ".control-label{
                               font-weight:bold;
                               color: #325d88;
            }
            ul{margin-left: 30px}
             "
        )
      )),
      h2(style = "padding-top: 50px; color: #3e3f3a; font-style: font-family: Roboto",
         "Introduction"),
        bslib::card(
          fluidRow(
            shiny::markdown(
              glue::glue(
              "Welcome to the interactive TOPS-SCHOOL NYC Lead Data Explorer. This Shiny app was developed ",
              "by Hasim Engin and Joshua Brinks with support from the NASA Transform To Open Science (TOPS) SCHOOL initiative.", 
              "You might want to use the glue::glue function when ",
              "there is a lot of text that would bleed over the edge of the script making the app.")),
              
            shiny::markdown("Are there objectives for this explorer? You can use markdown to make a list:"),
            shiny::markdown("     * First
                            * Second
                            * Third")
        )), 
  # first ui element----
  h2(style = "color: #3e3f3a; font-style: font-family: Roboto",
         "Raw Data Explorer"),
  bslib::card(
    fluidRow(shiny::markdown(
      glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      )
    )),
    fluidRow(
      column(2),
      column(
        3,
        align = 'center',
        selectInput(
          "county1",
          label = "Select County",
          choices = list_of_counties,
          selected = "All Counties"
        )
      ),
      column(
        5,
        align = 'center',
        selectInput(
          "field1",
          label = "Select Columns",
          choices = lead_data_all_fields,
          selected = c("County",
                       "School",
                       "lead_summary_by_school"),
          multiple = TRUE
        )
      ),
      column(2)
    ), 
    fluidRow(column(1),
             column(10, DT::dataTableOutput("table")),
             column(1))
  ), 
  # second ui element----
  h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
     "School Explorer"), 
  bslib::card(
    fluidRow(shiny::markdown(
      glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      )
    )), 
  fluidRow(column(
    12,
    align = 'center',
    selectInput(
      "county2",
      label = "Select a County",
      choices = list_of_counties,
      selected = "All Counties"
    )
  )),
  fluidRow(column(1),
           column(10, leafletOutput("map")),
           column(1))), 
  
  # third ui element----
h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
       "County Demographics"),
  bslib::card(
    fluidRow(
      shiny::markdown(glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      ))),
  fluidRow(column(1),
           column(5, "", plotOutput("plot1")),
           column(5, "", plotOutput("plot2")),
           column(1)),
  fluidRow(
    column(3),
    column(3, align = 'center', 
           selectInput("field2", 
                       label = "Left Map Field",
                       choices = field_list, selected = "total_white")),
    column(3, align = 'center', 
           selectInput("field3", 
                       label = "Right Map Field",
                       choices = field_list, selected = "white_5_17")),
    column(3)),
  fluidRow(
    column(2),
    column(8, align = 'center', 
           shinyWidgets::radioGroupButtons(
             inputId = "class1",
             label = "Classification Method", 
             choices = classification_methods,
             status = "primary"
           )),
    column(2)),
  fluidRow(
    column(6, "", leafletOutput("map1")),
    column(6, "", leafletOutput("map2"))
  )), 
  
  #fourth ui element
h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
         "County Lead Summaries"),
  bslib::card(
    fluidRow(
      shiny::markdown(glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      ))),
  fluidRow(column(1),
           column(5, align = 'center', 
                  selectInput(
                    "county3",
                    label = "Select a County",
                    choices = list_of_counties,
                    selected = "Albany"),
                  plotOutput("plot3")),
           column(5, align = 'center', leafletOutput("map3", height = 484.5)),
           column(1))),
  
  #fifth ui element
  h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
         "Demographic Comparisons"),
  bslib::card(
    fluidRow(
      shiny::markdown(glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      ))),
  fluidRow(
    column(3),
    column(3,
      align = 'center',
      selectInput(
        "field4",
        label = "Left Map Field",
        choices = field_list,
        selected = "total_white")),
    column(3,
      align = 'center',
      selectInput(
        "field5",
        label = "Right Map Field",
        choices = lead_field_list,
        selected = "school_count")),
    column(3)),
  fluidRow(
    column(2),
    column(8, align = 'center', 
           shinyWidgets::radioGroupButtons(
             inputId = "class2",
             label = "Classification Method", 
             choices = classification_methods,
             status = "primary"
           )),
    column(2)), 
  
  fluidRow(column(1),
           column(5,"", leafletOutput("map4")),
           column(5,"", leafletOutput("map5")),
           column(1))),
  #sixth ui element
  h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
         "Download A Map!"),
  bslib::card(
    fluidRow(
      shiny::markdown(glue::glue(
        "What does this thing do? You might want to use the glue::glue function when ",
        "there is a lot of text that would bleed over the edge of the script making the app."
      ))),
    fluidRow(column(4),
             column(
               4,
               align = 'center',
               selectInput(
                 "fields_map",
                 label = "Select fields",
                 choices = out_map_field_list,
                 selected = "school_count"
               )
             ),
             column(4)),
    fluidRow(column(2),
             column(
               8,
               align = 'center',
               shinyWidgets::radioGroupButtons(
                 inputId = "class3",
                 label = "Classification Method",
                 choices = classification_methods,
                 status = "primary"
               )
             ),
             column(2)), 
  fluidRow(column(2),
           column(4, align = 'center', textInput("title", "Add Map Title", "")),
           column(4, align = 'center', textInput("legendtitle", "Add Legend Title", "")),
           column(2)),
  fluidRow(column(4),
           column(4, align = 'center',style = "padding-top: 15px; padding-bottom: 15px;",
                  downloadButton("download_map",label = "Download Map")),
           column(4)),
  
  fluidRow(column(1),
           column(10,"", leafletOutput("map6")),
           column(1))
),
h2(style = "color: #3e3f3a; font-style: font-family: Roboto",
   "Conclusion"),
bslib::card(
  fluidRow(
    shiny::markdown(
      glue::glue(
        "Congratulations! We changed science")),
    
    shiny::markdown("What did we learn? A lot of things."),
    shiny::markdown("     * First
                            * Second
                            * Third")
  )), ))
