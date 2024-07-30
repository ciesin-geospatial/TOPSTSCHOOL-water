library(shiny)

load(file.path(getwd(),"nyc_lead_dats.RData"))
source("nyc_lead_prep.R", local = TRUE)
source('nyc_ui.R', local = TRUE)

link_web <- tags$a(shiny::icon("globe"), href = "https://ciesin-geospatial.github.io/TOPSTSCHOOL/", target = "_blank")
link_git <- tags$a(shiny::icon("github"), href = "https://github.com/ciesin-geospatial/TOPSTSCHOOL/", target = "_blank")
link_youtube <- tags$a(shiny::icon("youtube"), href = "https://www.youtube.com/channel/UCOIrczFd7_ht2bNUQ3qnM8w", target = "_blank")



link_wsim_acqu <- tags$a("WSIM Data Acquisition and Processing",
                         href = "https://ciesin-geospatial.github.io/TOPSTSCHOOL-water/m101-wsim-gldas.html",
                         target = "_blank")
link_modis_nrt <- tags$a("MODIS NRT Flood Data Acquisition Exploration",
                         href = "https://ciesin-geospatial.github.io/TOPSTSCHOOL-water/m102-lance-modis-nrt-global-flood.html",
                         target = "_blank")
link_nyc_lead <- tags$a("Interactive NYC School Lead Data Explorer",
                        href = "https://topstschool.shinyapps.io/nyc-lead/",
                        target = "_blank")


school_theme <- bslib::bs_theme(
  version = 5,
  "navbar-bg" = "#325d88",
  "navbar-fg" = "#c7d3e0")

basemap<-leaflet::providers$OpenStreetMap.Mapnik

ui <-
  bslib::page(
    theme = school_theme,
    ## The Landing Page----
    bslib::navset_bar(
      nyc_ui,
      position = "fixed-top",
      collapsible = TRUE,
      title = HTML('<a href="https://ciesin-geospatial.github.io/TOPSTSCHOOL-water/" style="color: white;">SCHOOL Water Module</a>'),
      bslib::nav_menu(
        title = "Lessons",
        bslib::nav_item(link_wsim_acqu),
        bslib::nav_item(link_modis_nrt),
        bslib::nav_item(link_nyc_lead)
      ),
      bslib::nav_spacer(),
      bslib::nav_item(link_web),
      bslib::nav_item(link_git),
      bslib::nav_item(link_youtube))
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
      tm_basemap(basemap)+
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
      guides(fill = "none") +
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
      guides(fill = "none") +
      labs(
        x = "",
        y = " ",
        fill = "",
        title = "Total Population Aged 5-17 by Race") +
      coord_flip() + theme
  })  
  
  
  output$map1<-renderLeaflet({
    
    tmap<-tm_basemap(basemap)+
      tmap::tm_shape(county_census, name="NYS Counties") +
      tm_polygons(col=input$field2,style=input$class1, palette="RdYlGn")+
      tm_view(bbox = sf::st_bbox(county_census))
    tmap_leaflet(tmap, in.shiny = TRUE)
    
  })
  
  output$map2<-renderLeaflet({
    
    tmap<-tm_basemap(basemap)+
      tmap::tm_shape(county_census, name="NYS counties") +
      tm_polygons(col=input$field3,style=input$class1, n=6,palette="RdYlGn")+
      tm_view(bbox = sf::st_bbox(county_census))
    tmap_leaflet(tmap, in.shiny = TRUE)
    
  })
  
  # fourth server element----
  output$plot3 <- renderPlot({
    
    school_lead_df %>%
      filter(County == input$county3) %>%
      group_by(lead_summary_by_school) %>% summarize(Count = n()) %>%
      mutate(percent = prop.table(Count),
             prc = paste0("   %", round(percent * 100, 1), " (", comma(Count), ")")) %>%
      ggplot(aes(x = lead_summary_by_school,
                 y = Count, fill = lead_summary_by_school)) +
      geom_bar(stat = "identity") +
      geom_text(aes(label = prc), size = 5,
                position = position_stack(0.9)) + guides(fill = "none") +
      scale_fill_manual(values = c("green3", "red", "grey")) +
      labs(
        x = "",
        y = "Count of School",
        fill = "",
        title = "Count of Schools by Lead Classification",
        caption = "Lead Levels < 15ppb: None of the outlets have lead over 15ppb\nhas Lead Levels > 15ppb: At least a outlet has lead over 15ppb") + 
      theme
  })
  
  
  selected_schools <-
    reactive({
      if(input$county3 == "All Counties") {school_locations} else{
        school_locations %>% filter(County == input$county3)}
    })
  
  selected_county <-
    reactive({
      if(input$county3 == "All Counties") {county_census} else{
        county_census %>% filter(county == input$county3)}
    })
  
  output$map3 <- renderLeaflet({
    tmap <- 
      tm_basemap(basemap) +
      tm_shape(county_census, name = "NY Counties")+
      tm_borders("darkgrey", lwd = 2) +
      tm_shape(selected_county()) +
      tm_borders("cyan", lwd = 3) +
      tm_shape(selected_schools())+
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
    
    tmap <- tm_basemap(basemap) +
      tmap::tm_shape(county_with_school, name = "county Boundaries") +
      tm_polygons(
        col = input$field4,
        style = input$class2,
        n = 6,
        palette = "YlOrRd",
        popup.vars = c("County: " = "county.x"))
    
    tmap_leaflet(tmap, in.shiny = TRUE)
    
  })
  
  
  output$map5 <- renderLeaflet({
    tmap <- tm_basemap(basemap) +
      tmap::tm_shape(county_with_school, name = "county Boundaries") +
      tm_polygons(
        col = input$field5,
        style = input$class2,
        n = 6,
        palette = "YlOrRd",
        popup.vars = c("County: " = "county.x"))
    tmap_leaflet(tmap, in.shiny = TRUE)
    
  })
  
  # sixth server element----
  output$map6 <- renderLeaflet({
    tmap <- tm_basemap(basemap) +
      tmap::tm_shape(county_with_school, name = "County Boundaries") +
      tm_polygons(
        col = input$fields_map,
        style = input$class3,
        n = 6,
        palette = "YlOrRd",
        popup.vars = c("County: " = "county.x"))
    tmap_leaflet(tmap, in.shiny = TRUE)
  })
  
  map_expr <-
    reactive({
      tmap <- tm_basemap(basemap) +
        tmap::tm_shape(county_with_school, name = "County Boundaries") +
        tm_polygons(
          col = input$fields_map,
          style = input$class3,
          n = 6,
          palette = "YlOrRd",
          title = input$legendtitle,
          popup.vars = c("County: " = "county.x")
        ) +
        tm_scale_bar(position = c("center", "bottom")) + 
        tm_compass(position = c("right", "top")) +
        tm_layout(
          legend.position = c("left", "bottom"),
          main.title = input$title,
          main.title.position = "center"
        )
      
    })
  
  output$download_map <- downloadHandler(
    filename = paste0(
      "NY",
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