nyc_ui <- 
  bslib::nav_panel(
    "NYC School Lead Explorer",
      fluidPage(
  ## first ui element
  fluidRow(
    column(
      12,
      align = 'center',
      h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
         "Lead Data Explorer")
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
        selected = "Bronx")),
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
        multiple = TRUE)),
    column(2)),
  fluidRow(column(1),
           column(10, DT::dataTableOutput("table")),
           column(1)),
  
  # second ui element----
  fluidRow(
    column(
      12,
      align = 'center',
      h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
         "School Explorer")
    )),
  fluidRow(column(
    12,
    align = 'center',
    selectInput(
      "county2",
      label = "Select a County",
      choices = list_of_counties,
      selected = "All counties"
    )
  )), 
  fluidRow(column(1),
           column(10,leafletOutput("map")),
           column(1)),
  
  # third ui element----
  fluidRow(column(
    12,
    align = 'center',
    h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
       "County Demographics")
  )),
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
    column(4),
    column(4, align = 'center', 
           selectInput("class1", 
                       label = "Classification Method",
                       choices = classification_methods, 
                       selected = "jenks")),
    column(4)),
  fluidRow(column(1),
           column(5, "", leafletOutput("map1")),
           column(5, "", leafletOutput("map2")),
           column(1)), 
  
  #fourth ui element
  fluidRow(
    column(
      12,
      align = 'center',
      h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
         "County Lead Summaries")
    )),
  fluidRow(column(1),
           column(5, align = 'center', 
                  selectInput(
                    "county3",
                    label = "Select a County",
                    choices = list_of_counties,
                    selected = "All counties"),
                  plotOutput("plot3")),
           column(5, align = 'center', leafletOutput("map3")),
           column(1)),
  
  #fifth ui element
  fluidRow(
    column(
      12,
      align = 'center',
      h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
         "Demographic Comparisons")
    )),
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
    column(4),
    column(4,
      align = 'center',
      selectInput(
        "class2",
        label = "Classification Method",
        choices = classification_methods,
        selected = "jenks")),
    column(4)), 
  
  fluidRow(column(1),
           column(5,"", leafletOutput("map4")),
           column(5,"", leafletOutput("map5")),
           column(1)),
  #sixth ui element
  fluidRow(
    column(
      12,
      align = 'center',
      h3(style = "color: #353a40; text-align: center; font-weight: bold; font-style: font-family: Roboto",
         "Download A Map!")
    )),
  fluidRow(column(3),
           column(3, align = 'center',
                  selectInput("fields_map", 
                       label = "Select fields",
                       choices = out_map_field_list, 
                       selected = "school_count")),
           column(3, align = 'center',
           selectInput("class3", 
                       label = "Classification Method",
                       choices = classification_methods, 
                       selected = "jenks")),
           column(3)),
  fluidRow(column(3),
           column(3, align = 'center', textInput("title", "Add Map Title", "")),
           column(3, align = 'center', textInput("legendtitle", "Add Legend Title", "")),
           column(3)),
  fluidRow(column(5),
           column(2, align = 'center',
                  downloadButton("download_map",label = "Download Map")),
           column(5)),
  
  fluidRow(column(1),
           column(10,"", leafletOutput("map6")),
           column(1))
))