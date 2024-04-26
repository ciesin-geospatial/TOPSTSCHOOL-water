library(shiny)

source("nyc_lead_prep.R", local = TRUE)

state_list<-datasets::state.abb

list_of_counties<-school_lead_df %>% pull(County) %>% unique()
static_state<-"NY"
# get te census data
county_census<-get_census_data(static_state)
county_census$county <- gsub(" County", "", county_census$county)

# download.file(
# "https://raw.githubusercontent.com/ciesin-geospatial/TOPSTSCHOOL/main/custom.scss", 
# destfile = "nyc-lead/school.scss")
# ui
source('nyc_ui.R', local = TRUE)
ui <-
  bslib::page(
    theme = bslib::bs_theme(version = 5, "navbar-bg" = "#325d88"),
    ## The Landing Page----
    bslib::navset_bar(
      nyc_ui,
      position = "fixed-top",
      title = "TOPS-SCHOOL: ")
  )
# server
server <- function(input, output) {
  
    # first element server code----
    output$table<- DT::renderDataTable({
        if (input$county1=="All Counties")
        {school_lead_df |> dplyr::select(input$field1) }
        
        else(school_lead_df |> filter(County==input$county1)|> dplyr::select(input$field1))
    })
    
    # second element server----
    school_loc<-reactive({school_locations |> filter(County==input$county2)})
    output$map<-renderLeaflet({
        
        tmap<-
          tm_basemap(leaflet::providers$Esri.WorldImagery)+
            tm_shape(school_loc(), name="School Locations") +
            tm_dots(id="",
                    col="#0096FF",
                    popup.vars=c("School Name: "="School",
                                 "Summary: "="lead_summary_by_school",
                                 "Outlets (n): "="Number_of_Outlets"),
                    legend.show = FALSE)+
          tmap::tm_view(bbox = sf::st_bbox(school_loc()))
        tmap_leaflet(tmap, in.shiny = TRUE)
    })

    # third server element----
    # get total population from census 202
    output$plot1 <- renderPlot({
      county_census %>% st_drop_geometry() %>%
        dplyr::select(contains("total")) %>% gather(key, value) %>%
        group_by(key) %>% summarise(Count = sum(value)) %>%
        filter(key != "total_pop") %>%
        mutate(percent = prop.table(Count),
               prc = paste0("%", round(percent * 100, 1), " \n(", comma(Count / 1000), "K)")) %>%
        
        ggplot(aes(x = key, y = Count, fill = key)) +
        geom_bar(stat = "identity") +
        geom_text(
          aes(label = prc),
          size = 5,
          hjust = 0.7,
          position = position_stack(0.9)) + 
        guides(fill = FALSE) +
        labs(
          x = "",
          y = " ",
          fill = "",
          title = "Total Population by Race") +
        coord_flip() + 
        theme
    })
    
    output$plot2 <- renderPlot({
      county_census %>% st_drop_geometry() %>%
        dplyr::select("white_5_17", "black_5_17", "hispanic_5_17", "asian_5_17") %>%
        gather(key, value) %>%
        group_by(key) %>% summarise(Count = sum(value)) %>%
        mutate(percent = prop.table(Count),
               prc = paste0("%", round(percent * 100, 1), " \n(", comma(Count / 1000), "K)")) %>%
        ggplot(aes(x = key, y = Count, fill = key)) +
        geom_bar(stat = "identity") +
        geom_text(
          aes(label = prc),
          size = 5,
          hjust = 0.7,
          position = position_stack(0.9)) + 
        guides(fill = FALSE) +
        labs(
          x = "",
          y = " ",
          fill = "",
          title = "Total Population Aged 5-17 by Race") +
        coord_flip() + theme
    })  
    
    
    output$map1<-renderLeaflet({
      
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_census, name="NYS Counties") +
        tm_polygons(col=input$field2,style=input$class1, palette="RdYlGn")+
        tm_view(bbox = sf::st_bbox(county_census))
      tmap_leaflet(tmap, in.shiny = TRUE)
      
    })
    
    output$map2<-renderLeaflet({
      
      tmap<-tm_basemap(leaflet::providers$Esri.WorldImagery)+
        tmap::tm_shape(county_census, name="NYS counties") +
        tm_polygons(col=input$field3,style=input$class1, n=6,palette="RdYlGn")+
        tm_view(bbox = sf::st_bbox(county_census))
      tmap_leaflet(tmap, in.shiny = TRUE)
      
    })
    
    # fourth server element----
    output$plot3 <- renderPlot({
      if (input$county3 == "All counties") {
        school_lead_df_ <- school_lead_df
      }
      else{school_lead_df_ <- school_lead_df %>% filter(County == input$county3)}
      
      school_lead_df_ %>%
        group_by(lead_summary_by_school) %>% summarize(Count = n()) %>%
        mutate(percent = prop.table(Count),
               prc = paste0("   %", round(percent * 100, 1), " (", comma(Count), ")")) %>%
        ggplot(aes(x = lead_summary_by_school,
                   y = Count, fill = lead_summary_by_school)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = prc), size = 5,
                  position = position_stack(0.9)) + guides(fill = FALSE) +
        scale_fill_manual(values = c("green3", "red", "grey")) +
        labs(
          x = "",
          y = "Count of School",
          fill = "",
          title = "Count of Schools by Lead Classification",
          caption = "Lead Levels < 15ppb: None of the outlets have lead over 15ppb\nhas Lead Levels > 15ppb: At least a outlet has lead over 15ppb") + 
        theme
    })
    
    school_schools <- reactive({school_locations %>% filter(County==input$county3)})
    selected_county <- reactive({county_census %>% filter(county==input$county3)})
    
    output$map3 <- renderLeaflet({
      tmap <- 
        tm_basemap(leaflet::providers$Esri.WorldImagery) +
        tm_shape(county_census, name = "NY Counties")+
        tm_borders("darkgrey", lwd = 2) +
        tm_shape(selected_county()) +
        tm_borders("cyan", lwd = 3) +
        tm_shape(school_schools())+
        tm_dots(
          id = "Schools",
          col = "lead_summary_by_school",
          palette = c(
            "Lead Levels < 15ppb" = "green",
            "Lead Levels > 15ppb" = "red",
            "no data" = "gray"),
          popup.vars = c("School: " = "School"),
          legend.show = FALSE)+
        tm_view(bbox = sf::st_bbox(selected_county()))
    
      tmap_leaflet(tmap, in.shiny = TRUE)
      
    })

    # fifth server element----
    # get total population from census 2020
    output$map4 <- renderLeaflet({
      county_bry1 <- st_transform(county_census, crs(school_locations))
      school_locations_join <-
        st_join(school_locations , county_bry1, join = st_intersects) %>%
        group_by(GEOID, county) %>% summarise(
          school_count = n(),
          outlets_under_15_ppb = sum(Number_of_Outlets_under_15_ppb, na.rm =
                                       TRUE),
          outlets_above_15_ppb = sum(Number_of_Outlets_above_15_ppb, na.rm =
                                       TRUE)) %>%
        dplyr::select(GEOID,
                      county,
                      school_count,
                      outlets_under_15_ppb,
                      outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school <-
        county_bry1 %>% left_join(school_locations_join, by = "GEOID")
      tmap <- tm_basemap(leaflet::providers$Esri.WorldImagery) +
        tmap::tm_shape(county_with_school, name = "county boundaries") +
        tm_polygons(
          col = input$field4,
          style = input$class2,
          n = 6,
          palette = "YlOrRd")
      
      tmap_leaflet(tmap, in.shiny = TRUE)
      
    })
    
    
    output$map5 <- renderLeaflet({
      county_bry2 <- st_transform(county_census, crs(school_locations))
      school_locations_join <-
        st_join(school_locations, county_bry2, join = st_intersects) %>%
        group_by(GEOID, county) %>% summarise(
          school_count = n(),
          outlets_under_15_ppb = sum(Number_of_Outlets_under_15_ppb, na.rm =
                                       TRUE),
          outlets_above_15_ppb = sum(Number_of_Outlets_above_15_ppb, na.rm =
                                       TRUE)
        ) %>%
        dplyr::select(GEOID,
                      county,
                      school_count,
                      outlets_under_15_ppb,
                      outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school <-
        county_bry2 %>% left_join(school_locations_join, by = "GEOID")
      tmap <- tm_basemap(leaflet::providers$Esri.WorldImagery) +
        tmap::tm_shape(county_with_school, name = "county boundaries") +
        tm_polygons(
          col = input$field5,
          style = input$class2,
          n = 6,
          palette = "YlOrRd"
        )
      tmap_leaflet(tmap, in.shiny = TRUE)
      
    })
    
    # sixth server element----
    output$map6 <- renderLeaflet({
      county_bry3 <- st_transform(county_census, crs(school_locations))
      school_locations_join <-
        st_join(school_locations, county_bry3, join = st_intersects) %>%
        group_by(GEOID, county) %>% summarise(
          school_count = n(),
          outlets_under_15_ppb = sum(Number_of_Outlets_under_15_ppb, na.rm =
                                       TRUE),
          outlets_above_15_ppb = sum(Number_of_Outlets_above_15_ppb, na.rm =
                                       TRUE)
        ) %>%
        dplyr::select(GEOID,
                      county,
                      school_count,
                      outlets_under_15_ppb,
                      outlets_above_15_ppb) %>% st_drop_geometry()
      county_with_school <-
        county_bry3 %>% left_join(school_locations_join, by = "GEOID")
      tmap <- tm_basemap(leaflet::providers$Esri.WorldImagery) +
        tmap::tm_shape(county_with_school, name = "county boundaries") +
        tm_polygons(
          col = input$fields_map,
          style = input$class3,
          n = 6,
          palette = "YlOrRd"
        )
      tmap_leaflet(tmap, in.shiny = TRUE)
    })
    
    map_expr <-
      reactive({
        county_bry4 <- st_transform(county_census, crs(school_locations))
        school_locations_join <-
          st_join(school_locations, county_census, join = st_intersects) %>%
          group_by(GEOID, county) %>% summarise(
            school_count = n(),
            outlets_under_15_ppb = sum(Number_of_Outlets_under_15_ppb, na.rm =
                                         TRUE),
            outlets_above_15_ppb = sum(Number_of_Outlets_above_15_ppb, na.rm =
                                         TRUE)
          ) %>%
          dplyr::select(GEOID,
                        county,
                        school_count,
                        outlets_under_15_ppb,
                        outlets_above_15_ppb) %>% st_drop_geometry()
        county_with_school <-
          county_bry4 %>% left_join(school_locations_join, by = "GEOID")
        tmap <- tm_basemap(leaflet::providers$Esri.WorldImagery) +
          tmap::tm_shape(county_with_school, name = "county boundaries") +
          tm_polygons(
            col = input$fields_map,
            style = input$class3,
            n = 6,
            palette = "YlOrRd",
            title = input$legendtitle
          ) +
          tm_scale_bar(position = c("center", "bottom")) + tm_compass(position =
                                                                        c("right", "top")) +
          tm_layout(
            legend.position = c("left", "bottom"),
            main.title = input$title,
            main.title.position = "center"
          )
        
      })
    
    output$download_map <- downloadHandler(
      filename = paste0(
        static_state,
        "_",
        input$fields_map,
        "_",
        input$class3,
        "_classification.png"
      ),
      content = function(file) {
        tmap_save(map_expr(), file = file)
      }
    )
}

# Run the application 
shinyApp(ui = ui, server = server)
