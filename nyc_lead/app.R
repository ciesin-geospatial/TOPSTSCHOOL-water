source("nyc_lead_prep.R", local = TRUE)

library(shiny)




ui <- navbarPage(strong("School water quality: Exposure to lead"),theme = shinytheme("flatly"),
                 
###--------TABNAME:BaCKGROUND--------------------                
  tabPanel(strong("Background"),
    fluidRow(column(10, offset=1, 
      h2(strong("Objective")),
        hr(),
      
            p("This document helps to analyse school lead datasets collected 
             from 2016,2017,2018 and 2019 and compare it with population characteristic at county level in NYS."),
        h5(strong("By compliting this module, you are expected to learn following points")),

          tags$ul(
            tags$li("Possible health outcomes of consuming water with lead level above 15pbb and importance of water quality"),
            tags$li("Read into R and analyze the data set"),
            tags$li("Convert school lead survey dataset to spatial data by using school xy coordinates"),
            tags$li("Obtain population data from US Census Bureau by using census API"),
            tags$li("Compare school lead datasets with population by aggregating the dataset into country boudary"),
            tags$li("Explore different data classification methods ( equal, quantile, natural breaks, standard deviation)"),
            tags$li("Create your own map")
            ),
      h2(strong("Background Information")),
            p("Access to clean and safe drinking water is significant to ensure public health. Drinking water contaminants may
            have both short-term and long-term negative health impacts. One such contaminant that can have detrimental effects
            is lead, which is particularly harmful to a child's development. Children's central nervous systems and cognitive
            function have been linked to harm from lead exposure, even at low levels . It is therefore essential to supply lead
            free drinking water in schools and homes."),

            p("Lead concentrations in drinking water should not exceed 10 ppb, according to guidelines issued by the World Health
            Organization, and 15 ppb is the action level set by the US EPA . These guidelines demonstrate how important it is to
            reduce lead exposure and contamination from drinking water on a global scale. Lead exposure has no safe threshold.
            Safety depends on making sure that lead levels in water are below legal thresholds, and ideally as close to zero as
            feasible since it can have serious negative health impacts, especially in children."),

            p("The main source of lead in drinking water is the corrosion of lead-containing plumbing materials. The EPA considers
              lead levels over 15 ppb to be dangerous. Lead poisoning must be prevented at all costs, particularly in schools
              where young students' developing brains are vulnerable. Developing effective preventive and remedial strategies
              requires an understanding of the factors that contribute to lead contamination. It is significant to understand
              that the distribution of lead contamination often coincides with socioeconomic issues . Lead exposure often has
              a disproportionate impact on communities with lower incomes and limited access to resources . Older plumbing
              systems with lead pipes and solder may leak lead into drinking water, particularly in regions with acidic water.
              Furthermore, runoff from contaminated soil and industrial discharges can also introduce lead into water systems.
              Low income communities' residential areas often lack access to safe drinking water due to inadequate infrastructure
              or reliance on private wells that may be contaminated with lead. Studies also show that most of these low income and
              marginalized groups reside in the areas which are more likely to be located near industrial facilities and other
              sources which are exposed to lead pollution ."),
     
       h4(strong("Lead in New York Schools")),
          p("New York State (NYS) Lead Testing in School Drinking Water dataset analysis reveals that as of 2022, 1,864 schools had
            lead outlets testing higher than 15 ppb . While 527 schools finished their remediation, 1,851 schools reported taking 
            remedial action. There are now 12 schools with outlets exceeding 15 ppb in operation, indicating possible continuous 
            exposure. There are gaps evident with following up and documenting the corrective measures. To understand and mitigate
            the lead hazards, more transparency is needed around the schools which are at high exposure to the lead and improved
            repeated testing protocols could be in place. Guidelines, rules, and resources pertaining to lead testing and remediation
            in schools are provided by the New York State Department of Health . However, it seems that there is currently a lack of
            financial and technical support to schools to handle lead hazards, particularly in underprivileged communities."),
      
      h4(strong("Ensuring Safe Driking Safe Water")), 
          p("The lead contamination issues evident in Flint and New York schools highlight the need to balance the tradeoffs between
            quickly addressing risks in the short term by improving monitoring and transparency around water quality issues, and 
            managing the costs of major infrastructure changes required in the long term to prevent such crises and exposures - 
            for example, replacing lead service lines and school plumbing. Community collaboration, precise surveillance databases,
            and adaptable adaptation strategies will be critical to ensuring that everyone has access to safe drinking water."),
          
          p("Availability of safe drinking water is the basic human right, however from above cases it shows the alarming need to
            consider this risk from the lead contamination yet ignored by the state. From New York to Flint, Michigan, we witness
            alarming examples that necessitate immediate action backed by transparent and accessible data. Moreover an informed
            public through the learnings and accessing the data, can play a crucial role in building leadership roles to fulfill
            their responsibilities around providing healthy, lead free infrastructures in schools. Thus , it is significant to
            develop the curriculum which focuses on water quality issues globally and locally for students and school communities.")
            
      ))),

 
     
###--------TABNAME:Data Source-------------------- 
    tabPanel(strong("Data Source"),
      fluidRow(column(10,offset=1,
          h2("Read Data"),
            p("The section below reads NYS school lead testing result from 2016 to 2019 in to R enviroment.
              In the code snip below, we are reading the datasets that hosted on a github reposotory.
              Then we use read_csv fundtion to read dataset.The most important part when read a datatset is the format of 
              the dataset.The format the dataset determines what method to use."),br(),
            code("data_url<-https://raw.githubusercontent.com/ciesin-geospatial/TOPSTSCHOOL-module-1-water/main"),br(),
            code("dataset_name<-Lead_Testing_in_School_Drinking_Water_Sampling_and_Results_Compliance_Year_2016.csv"),br(),
            code("data_path=paste0(data_url,\\,data_url"),br(),
            code("school_lead_df<-readr::read_csv(url(get_data))"),
                         
                                          
    )),
    fluidRow(column(10,offset=1,
                    h2("Explore the dataset"),
                    p("The section below allow us to see the dataset in detail.Click on select fields widget to see
                      all fields in the dataset. You can select multiple fields."))),br(),
    fluidRow(style = "padding-bottom: 30px;background-color:#f1f2f3;",
             column(3,offset=1, selectInput("county", label = "Select a county",
                                            choices = list_of_counties, selected = "Bronx")),
             column(4,offset=1, selectInput("field4", label = "Select fields",
                                             choices = lead_data_all_fields, selected = "County",multiple = TRUE))),

    fluidRow(column(10, DT::dataTableOutput("table"))),               
                    
    ),


)
                          

# server
server <- function(input, output) {
  output$table<-DT::renderDataTable({
 
    school_lead_df %>% filter(County==input$county)%>% dplyr::select(input$field4)

  })
}

# Run the application 
shinyApp(ui = ui, server = server)
