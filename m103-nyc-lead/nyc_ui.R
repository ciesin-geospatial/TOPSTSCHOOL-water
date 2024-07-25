nyc_ui <- bslib::nav_panel("NYC School Lead Explorer",
  fluidPage(# make input labels bold and different color from written text/narrative
    tags$head(tags$style(
      HTML(".control-label{
            font-weight:bold;
            color: #325d88;}
          ul{margin-left: 30px}"
          )
        )
      ),
    h1(style = "padding-top: 50px; color: #3e3f3a; font-style: font-family: Roboto",
      "Lead Testing in NYS School Drinking Water"),
    bslib::card(
      fluidRow(
        shiny::markdown(
          glue::glue(
            "Welcome to the interactive TOPS-SCHOOL NYC Lead Data Explorer. This Shiny app was developed ",
            "by Hasim Engin and Joshua Brinks with support from the NASA Transform To Open Science (TOPS) SCHOOL initiative.
            
            This use case explores the risks of exposure to lead via drinking water. Lead contamination is a serious issue that poses severe health risks and requires remedial action. ",
            "In this lesson, we will analyze data on lead levels in [NY State schools](https://health.data.ny.gov/Health/Lead-Testing-in-School-Drinking-Water-Sampling-and/rkyy-fsv9/data) ",
            "collected from 2016, 2017, 2018, and 2019 and compare it with population characteristics at the county level in New York State (NYS) to understand its impact. 
            
            No 'safe' levels of lead have been established, but we will discuss what level of lead can be detected. The lesson examines the sources of lead exposure and its adverse effects; ",
            "we will also discuss the importance of data transparency, public participation, visualizing contamination as maps/graphs, and estimating population risks to address water quality issues. 

            ## Learning Objectives
            
            - Learn about NYS lead as a drinking water contaminant and its health impacts.
            - Visualize NYS lead contamination data geographically and statistically.
            - Discuss the importance of safe drinking water in the context of lead contamination.
            - Understand and apply open data principles in the context of lead contamination data.
            - Explore different data classification methods (equal, quantile, natural breaks, standard deviation).
            
            ## Introduction

            Access to clean and safe drinking water is significant to ensure public health [(National Institute of Environmental Health Sciences, 2024)](https://www.niehs.nih.gov/health/topics/agents/water-poll). ",
            "Drinking water contaminants may have both short-term and long-term negative health impacts. One such contaminant that can have detrimental effects is lead, which is particularly harmful to a child's development [(Levallois et al., 2018)](https://doi.org/10.1007/s40572-018-0193-0).
            
            Children's central nervous systems and cognitive function have been linked to harm from lead exposure, even at low levels [(Lanphear et al., 2005)](https://doi.org/10.1289/ehp.7688). ",
            "Therefore, it is essential to address lead-contaminated water in schools and homes. Lead exposure has no safe threshold. Safety depends on ensuring that lead levels in water are below the legal thresholds set by the World Health Organization (WHO) and the US Environmental Protection Agency (EPA). ",
            "According to guidelines issued by the WHO, lead concentrations in drinking water should not exceed 10 ppb (Parts Per Billion) [(World Health Organization, 2022)](https://www.who.int/publications/i/item/9789240045064), ",
            "and 15 ppb is the action level set by the EPA [(EPA, 2024)](https://www.epa.gov/ground-water-and-drinking-water/basic-information-about-lead-drinking-water).

            It is crucial to highlight that the degree of lead able to be detected depends upon many variables [(Schock 1990)](https://doi.org/10.1007/BF00454749). ",
            "The main source of lead in drinking water is the corrosion of lead-containing plumbing materials. Older plumbing systems with lead pipes and solder may leak lead into drinking water, particularly in regions with acidic water [(EPA, 2024)](https://www.epa.gov/ground-water-and-drinking-water/basic-information-about-lead-drinking-water). ",
            "Furthermore, runoff from contaminated soil and industrial discharges can also introduce lead into water systems. ",
            "Developing effective preventive and remedial strategies requires understanding the factors that contribute to lead contamination."
            )
          )
        ),
      fluidRow( 
        div(style = "text-align: center;",
          img(src = "https://nylcv.org/wp-content/uploads/lead-pipes.jpg", height = "300px"),
          a(href = "https://nylcv.org/news/its-national-lead-poisoning-prevention-week/lead-pipes/", "1")
          ) 
        )
      ), 
    # first ui element----
    h2(style = "color: #3e3f3a; font-style: font-family: Roboto",
        "Lead In New York Schools Data Explorer"),
    bslib::card(
      fluidRow(shiny::markdown(
        glue::glue(
          "The New York State (NYS) Lead Testing in School Drinking Water dataset shows the 'school drinking water lead sampling and results information ",
          "reported by each NYS public school and Boards of Cooperative Educational Services (BOCES)' [(NYS Department of Health)](https://health.data.ny.gov/Health/Lead-Testing-in-School-Drinking-Water-Sampling-and/rkyy-fsv9/data). ",
          "More information on the NYS dataset sampling is available [here](https://www.health.ny.gov/environmental/water/drinking/lead/lead_testing_of_school_drinking_water.htm).
          
          Analysis of the dataset reveals that as of 2022, 1,864 schools had lead outlets testing higher than 15 ppb [(New York State Department of Health, 2020)](https://health.data.ny.gov/Health/Lead-Testing-in-School-Drinking-Water-Sampling-and/rkyy-fsv9/about_data). ", 
          "While 527 schools finished their remediation, 1,851 schools reported taking remedial action.
          
          There are now 12 schools with outlets exceeding 15 ppb in operation, indicating possible continuous exposure. However, there are gaps in following up and documenting the corrective measures. ",
          "More transparency is necessary for schools with high exposure to lead to address the hazards of lead contamination and implement improved repeated testing protocols.
          
          The New York State Department of Health provides guidelines, rules, and resources on lead testing and remediation in schools [(New York State Department of Health 2024)](https://health.data.ny.gov/Health/Lead-Testing-in-School-Drinking-Water-Sampling-and/rkyy-fsv9/about_data).
          
          ### Get familiar with the dataset
          
          To work with the NYS data, first we will read the NYS school lead testing results from 2016 to 2019. The dataset is hosted on a GitHub repository and we will read the dataset by using the dataset URL.",
          
          
          "
          
          ```r
          # Dataset url on GitHub repository
          data_url<-'https://raw.githubusercontent.com/renastechschool/Python_tutorials/main/Lead_Testing_in_School_Drinking_Water_Sampling_and_Results_Compliance_Year_2016_formated.csv?token=GHSAT0AAAAAACNH7S3BJGTQXNGH4UPQCJI6ZNQB3VA'
          # Read dataset. Input data wrapped by url method. This allows to read data from a url.
          school_lead_df<-read_csv(url(data_url))
          ```
          
          All datasets require some pre-cleaning and formatting. The shinyapp will format field names. ",
          "R does not like field names with spaces, so we need to convert space to an underscore '_'. Also, we need to extract the year from the date field for the next step of our work.",
          "Please refer to the GitHub Repo for an in-depth look at the shiny app.
          
          A [Shiny app](https://shiny.rstudio.com/) is a web application framework for the R programming language that allows you to create interactive web applications directly from R code. It is part of the RStudio ecosystem and is widely used for creating interactive data visualizations, dashboards, and web-based tools without needing to know HTML, CSS, or JavaScript.
          
          The code in the [SCHOOL Module 1 Water Repo](https://github.com/ciesin-geospatial/TOPSTSCHOOL-water/tree/main) ",
          "creates a [Shiny app](https://shiny.rstudio.com/) that allows users to select a county and specific fields from a data frame (school_lead_df), the app then displays the corresponding data table based on the user's selections.
          
          Getting familiar with the dataset is the first step of an analysis. ",
          "To understand the attributes, we will query the data by geographic region (county) and by different attributes (fields)."
          )
        )),
      fluidRow(
        column(2),
        column( 3,
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
      fluidRow(
        column(1),
        column(10, DT::dataTableOutput("table")),
        column(1)
        )
    ), 
    # second ui element----
    h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
    "Converting from tabular data to geospatial data and Mapping It"), 
    bslib::card(
      fluidRow(shiny::markdown(
        glue::glue(
          "A dataset needs a geometry attribute to plot the data on a map or to complete different spatial analyses. ",
          "The NYS dataset has **xy coordinates of schools**. The xy coordinates will allow us to convert the tabular dataset to a spatial dataset.
          
          We first need to address that the xy coordinates are not properly formatted. The coordinates are currently stored with school addresses, for example: 31-02 67 AVENUE Queens, NY 11364(40.74779141700003, -73.74551716499997). ",
          "We need to extract these coordinates and store the value on each side of the comma as a separate field. The first number refers to the **y coordinate (latitude)**, and the second number refers to the **x coordinate (longitude)**.
          
          While converting the data, we also need to know the projection of the xy coordinates. ",
          "XY coordinates can be in different projection systems. Projection information is typically stored in the metadata of a dataset. However, in the NYS dataset, there is not any metadata attached to the dataset. ",
          "The most commonly used geographic coordinate system in the [WORLD GEODETIC SYSTEM 1984 (WGS 84)](https://earth-info.nga.mil/index.php?dir=wgs84&action=wgs84). We will use the WGS84 projection to convert the NYS dataset to spatial data.
          
          We will now map the school locations in New York State from the dataset.
          "
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
        column(1)
        )
      ), 

    # third ui element----
    h2(style = "color: #3e3f3a;  font-style: font-family: Roboto", "Exploring Census County Demographics"),
    bslib::card(
      fluidRow(shiny::markdown(
        glue::glue(
          "We will next pull population data from the **US Census Bureau** ",
          "by using the Census Bureau's Application Programming Interface (API) tool, [Census Data API Discovery Tool](https://www.census.gov/data/developers/updates/new-discovery-tool.html).
        
          "
          )
        )),
      fluidRow(column(1),
        column(5, "", plotOutput("plot1")),
        column(5, "", plotOutput("plot2")),
        column(1)),
      fluidRow(shiny::markdown(
        glue::glue(
          "We can explore the data spatially using county-level boundary maps. 
          "
          )
        )),
      fluidRow(
        column(3),
        column(3, align = 'center', 
          selectInput("field2", 
                      label = "Left Map Field",
                      choices = field_list, selected = "total_white")),
        column(3, align = 'center', selectInput("field3", 
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
            )
          ),
        column(2)),
      fluidRow(
        column(6, "", leafletOutput("map1")),
        column(6, "", leafletOutput("map2"))
        )
      ), 
  
    #fourth ui element
    h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
        "Aggregate Census and County Lead data for Summaries"),
    bslib::card(
      fluidRow(shiny::markdown(
        glue::glue(
          "We also aggregate points into county boundaries using the stae's county boundaries.
        
          The shinyapp also plots the lead levels classification of the selected county and plots it in a bar graph. 
          "
          )
        )),
      fluidRow(column(1),
        column(5, align = 'center', 
          selectInput(
              "county3",
              label = "Select a County",
              choices = list_of_counties,
              selected = "Albany"),
          plotOutput("plot3")
          ),
        column(5, align = 'center', leafletOutput("map3", height = 484.5)),
        column(1)
        )
      ),
  
    #fifth ui element
    h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
        "Demographic Comparisons of Census data and Lead in Drinking Water data"),
    bslib::card(
      fluidRow(
        shiny::markdown(glue::glue(
          "Use the dropdown menus to do a visual side-by-side comparison of the aggregated data. 
        
          Change the classification method to see how each method can help you distinguish patterns, similarities, or outliers in the data!
        
          "
          ))
        ),
      fluidRow(
        column(3),
        column(3,
          align = 'center',
          selectInput(
            "field4",
            label = "Left Map Field",
            choices = field_list,
            selected = "total_white"
            )
          ),
        column(3,
          align = 'center',
          selectInput(
            "field5",
            label = "Right Map Field",
            choices = lead_field_list,
            selected = "school_count"
            )
          ),
        column(3)
        ),
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
              column(1)
        )
      ),
      #sixth ui element
    h2(style = "color: #3e3f3a;  font-style: font-family: Roboto",
        "Download A Map and Share Your Findings!"),
    bslib::card(
      fluidRow(
        shiny::markdown(glue::glue(
          "Select a field that you would like to place on the map. 
          Select the classification method that best conveys the data and information.
        
          Don't forget to add a legend title to let the viewers understand what the map means.
          
          Finaly, download the map as an image (in .png)"
          ))
        ),
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
        column(2)
        ), 
      fluidRow(column(2),
        column(4, align = 'center', textInput("title", "Add Map Title", "")),
        column(4, align = 'center', textInput("legendtitle", "Add Legend Title", "")),
        column(2)
        ),
      fluidRow(column(4),
        column(4, align = 'center',style = "padding-top: 15px; padding-bottom: 15px;",
          downloadButton("download_map",label = "Download Map (.png)")),
        column(4)
        ),
      fluidRow(column(1),
              column(10,"", leafletOutput("map6")),
              column(1)
        )
      ),
    h2(style = "color: #3e3f3a; font-style: font-family: Roboto",
      "Ensuring Safe Drinking Water"
      ),
    bslib::card(
      fluidRow(
        shiny::markdown(
          glue::glue(
            "Access to safe drinking water is a fundamental human right and a pillar of public health [(Li and Carpenter 2023)](https://doi.org/10.1002/awwa.2199). ",
            "However, the cases discussed underscore the critical need to address the risk of lead contamination. ",
            "From New York to Flint, Michigan, these examples serve as reminders of the need for action, supported by transparent and accessible data.
            
            A balance is needed between short and long-term action - promptly addressing risks in the short term by closing down contaminated water sources, improving monitoring, and transparency in reporting water quality issues . ",
            "In the long term, managing the costs of major infrastructure changes required to prevent such crises and exposures, such as replacing lead service lines and school plumbing [(EPA, 2024)](https://www.epa.gov/ground-water-and-drinking-water/basic-information-about-lead-drinking-water). ", 

            "Community collaboration, precise surveillance databases, and flexible adaptation strategies are critical in ensuring access to safe drinking water.
            
            Maintaining transparency and exchanging information with communities regarding the outcomes of lead testing and mitigation strategies is essential; ",
            "empowering the public with knowledge and access to data can catalyze action and foster leadership within communities to address these challenges. ", 
            "Educating individuals about water quality issues, both globally and locally, is paramount."
            )
          )
        ),
      fluidRow( div(
        style = "text-align: center;",
          img(src = "https://d3oj2y7irryo5z.cloudfront.net/wp-content/uploads/2016/01/FlintWater01s.jpg", height = "300px"), 
          a(href = "https://thegroundtruthproject.org/we-fear-the-water-photos-from-flint-residents/", "2")
          ) 
        ), 


      fluidRow(
        shiny::markdown(
          glue::glue("
            #### Lead in the News
              
            Thousands of people were exposed to dangerously high lead levels in their drinking water when the [Flint water crisis](https://www.nrdc.org/stories/flint-water-crisis-everything-you-need-know) broke out in 2014. ",
            "A study by Virginia Tech researchers, through their resident-organized sampling to testing data of 252 homes, revealed that lead levels in the city had increased [(NRDC, 2024)](https://www.nrdc.org/stories/flint-water-crisis-everything-you-need-know#summary). ",
            "Over 17% of samples tested higher than the federal 'action level' of 15 ppb, which calls for the need for corrective action. ",
            "More than 40% had lead readings higher than 5 ppb, which the researchers deemed indicative of a 'very serious' issue.
        
            Even years after the crisis began, elevated lead levels remained in Flint's schools. An article by [The New York Times](https://www.nytimes.com/2019/11/06/us/politics/flint-michigan-schools.html) ",
            "discusses how, in 2019, drinking water samples from 30 Flint school buildings still exhibit excessive lead levels. ",
            "The elevated levels demonstrate remaining problems with a prolonged impact on children's health and development. ",
            "Schools have an obligation to supply their pupils with clean drinking water. The Flint water crisis brought to light the long-term consequences of prolonged exposure to lead, especially for vulnerable groups such as children.
            
            Lead exposure is cumulative, as noted in an article by the [Tampa Bay Times](https://projects.tampabay.com/projects/2018/investigations/school-lead/hillsborough-disclosure/). ",
            "The duration of lead exposure in Flint has lasting impacts on the public, not only affecting physical health but also leading to psychological consequences of communities unable to trust their drinking water [@brooks2021]. ",
            "Rather than waiting for concerns to arise, schools can detect contamination issues early and take corrective action by implementing a lead testing program. Better learning outcomes are made possible by shielding children from lead exposure. The Flint water crisis made it clear how crucial it is to conduct proactive lead testing, monitor the situation, and take prompt corrective action. It also highlighted the importance of transparency, community involvement, and addressing barriers to accessing clean drinking water.
            
            In 2021, the Biden-Harris administration announced an ambitious [Lead Pipe and Paint Action Plan](https://www.whitehouse.gov/briefing-room/statements-releases/2021/12/16/fact-sheet-the-biden-harris-lead-pipe-and-paint-action-plan/). ",
            "This comprehensive $15 billion effort intends to promptly replace all lead service lines and pipes contaminating drinking water systems across the country. ",
            "The plan has a provision of providing a lead remediation grant of $9 billion to disadvantaged communities through the Water Infrastructure Improvements for the Nation Act (WIIN) program, including for schools and childcare centers at EPA.
                
            
            
            ## In this lesson, you learned...
            
            Congratulations! Now you should be able to:
            
            -   Read into R to analyze a dataset.
            -   Convert survey dataset to spatial data using xy coordinates.
            -   Plot locations on a map.
            -   Download population data from the US Census Bureau using the census API.
            -   Aggregate a dataset to a boundary.
            -   Create your own map.
            
            #### References
            
            Brooks, Samantha K, and Sonny S Patel. 2022. “Psychological Consequences of the Flint Water Crisis: A Scoping Review.” Disaster Medicine and Public Health Preparedness 16 (3): 1259–69. https://doi.org/10.1017/dmp.2021.41.

            Guidelines for Drinking-Water Quality. 2022. Fourth edition incorporating the first and Second addenda. Geneva: World Health Organization. https://www.who.int/publications/i/item/9789240045064.
            
            Lanphear, Bruce P., Richard Hornung, Jane Khoury, Kimberly Yolton, Peter Baghurst, David C. Bellinger, Richard L. Canfield, et al. 2005. “Low-Level Environmental Lead Exposure and Children’s Intellectual Function: An International Pooled Analysis.” Environmental Health Perspectives 113 (7): 894–99. https://doi.org/10.1289/ehp.7688.
            
            Levallois, Patrick, Prabjit Barn, Mathieu Valcke, Denis Gauvin, and Tom Kosatsky. 2018. “Public Health Consequences of Lead in Drinking Water.” Current Environmental Health Reports 5 (2): 255–62. https://doi.org/10.1007/s40572-018-0193-0.
            
            Li, Samuel, and Adam Carpenter. 2023. “The Human Right to Water: UN Definitions, Implications, and Effects.” Journal AWWA 115 (10): 50–55. https://doi.org/10.1002/awwa.2199.
            
            National Institute of Environmental Health Sciences. 2024. “Safe Water and Your Health.” https://www.niehs.nih.gov/health/topics/agents/water-poll.
            
            Natural Resource Defense Council. “Flint Water Crisis: Everything You Need to Know.” 2024. https://www.nrdc.org/stories/flint-water-crisis-everything-you-need-know#summary.
            
            New York State Department of Health. 2020. “Lead Testing in School Drinking Water Sampling and Results Compliance Year 2016.” https://health.data.ny.gov/Health/Lead-Testing-in-School-Drinking-Water-Sampling-and/rkyy-fsv9/about_data.
            
            New York State Department of Health. 2024. “Lead Testing of School Drinking Water.” https://www.health.ny.gov/environmental/water/drinking/lead/lead_testing_of_school_drinking_water.htm.
            
            Schock, Michael R. 1990. “Causes of Temporal Variability of Lead in Domestic Plumbing Systems.” Environmental Monitoring and Assessment 15 (1): 59–82. https://doi.org/10.1007/BF00454749.
            
            United States Environmental Protection Agency (EPA). 2024. “Basic Information about Lead in Drinking Water.” https://www.epa.gov/ground-water-and-drinking-water/basic-information-about-lead-drinking-water. 
            
            
            #### Photo Credits

            1. Devin Callahan, 2023. https://nylcv.org/news/its-national-lead-poisoning-prevention-week/lead-pipes/.

            2. Brittany Greeson/GroundTruth, 2016, https://thegroundtruthproject.org/we-fear-the-water-photos-from-flint-residents/. 
            "
            )
          )
        )
      ) 
    )
  )