# get the version with all years
gpw<-stars::read_ncdf("gpw_v4_population_count_rev11_15_min.nc")
# only the first 5 records of the raster contain the 2000-2020 pop counts
gpw<-
  gpw |> dplyr::slice(raster, 3)

usa <- httr::GET("https://www.geoboundaries.org/api/current/gbOpen/USA/ADM1/")
usa <- httr::content(usa)
usa <- sf::st_read(usa$gjDownloadURL)

texas <- httr::GET("https://www.geoboundaries.org/api/current/gbOpen/USA/ADM1/")
texas <- httr::content(texas)
texas <- sf::st_read(texas$gjDownloadURL)
texas <- texas[texas$shapeName=="Texas",]

texas_counties <- httr::GET("https://www.geoboundaries.org/api/current/gbOpen/USA/ADM2/")
texas_counties <- httr::content(texas_counties)
texas_counties <- sf::st_read(texas_counties$gjDownloadURL)
texas_counties<-sf::st_intersection(texas_counties, texas)

wsim_gldas<-terra::sds("composite_1mo.nc")
# wsim_gldas<-wsim_gldas["deficit"]
keeps<-seq(lubridate::ymd("2011-01-01"), lubridate::ymd("2011-12-01"), by = "month")
layers<-names(wsim_gldas)

wsim_gldas<-wsim_gldas[[terra::time(wsim_gldas) %in% keeps]]
class(wsim_gldas)
names(wsim_gldas) <- keeps
wsim_gldas <- terra::clamp(wsim_gldas, lower = -50, upper = 0)
terra::plot(wsim_gldas)

# numeric reclassiciation
m <- c(-10, 0, -10,
       -20, -10, -20,
       -30, -20, -30,
       -40, -30, -40,
       -50, -40, -50)

rclmat <- matrix(m, ncol=3, byrow=TRUE)
wsim_gldas_num <- terra::classify(wsim_gldas, rclmat, include.lowest=TRUE)

pop_dens<-terra::rast("gpw_v4_population_density_rev11_2010_15_min.tif")

pop_by_rp <-
  exactextractr::exact_extract(wsim_gldas_num, texas, function(df) {
    df <- data.table::setDT(df)
    df <-
      data.table::melt(
        df,
        id.vars = c("shapeISO", "coverage_area", "weight"),
        variable.name = "month",
        value.name = "return_period")
   df<-df[,.(pop_rp = round(sum(coverage_area*weight)/1e6)), by = .(shapeISO, month, return_period)]
   df[,total_pop:=sum(pop_rp), by = month]
   df[,pop_frac:=pop_rp/total_pop][,total_pop:=NULL]
  }, 
  summarize_df = TRUE, 
  weights = pop_dens, 
  coverage_area = TRUE,
  include_cols = 'shapeISO', progress = FALSE)

pop_by_rp[,month:=lubridate::month(pop_by_rp$month, label = TRUE)]
pop_by_rp<-pop_by_rp[!is.nan(return_period)]
pop_by_rp[,return_period:=as.factor(return_period)]

pop_by_rp[ , adjusted_frac := pop_frac + data.table::shift(pop_frac), by = month]
pop_by_rp[is.na(adjusted_frac),adjusted_frac:=pop_frac]

leg_colors<-c(
  '#9B0039',
  '#D44135',
  '#FF8D43',
  '#FFC754',
  '#FFEDA3')

leg_colors<-rev(leg_colors)

ggplot2::ggplot(pop_by_rp, 
                ggplot2::aes(x = month, 
                             y = pop_frac,
                             group = forcats::fct_rev(return_period), 
                             color = forcats::fct_rev(return_period),
                             fill = forcats::fct_rev(return_period),
                             alpha = forcats::fct_rev(return_period)
                             ))+
  ggplot2::geom_area(position = 'identity')+
  ggplot2::scale_color_manual(values = leg_colors)+
  ggplot2::scale_fill_manual(values = leg_colors)+
  ggplot2::scale_alpha_manual(values = rev(c(0.65, 0.50, 0.35, 0.25, 0.15)))+
 # ggplot2::geom_line(size = 0.1)+
  ggplot2::ylim(0,1)+
  ggplot2::labs(title = "Fraction of Population Under Water Deficits in Texas During 2011",
                subtitle = "Categorized by Intensity of Return Period",
                x = "",
                y = "Fraction of Population",
                caption = "Population derived from Gridded Population of the World (2010)",
                color = "Return Period", fill = "Return Period", group = "Return Period", alpha = "Return Period")+
  ggplot2::theme_minimal()

ggplot2::ggplot(pop_by_rp, 
                ggplot2::aes(x = month, 
                             y = pop_frac,
                             group = return_period, 
                             color = return_period,
                             fill = return_period,
                             alpha = return_period
                ))+
  ggplot2::geom_area(position = 'identity')+
  ggplot2::scale_color_manual(values = leg_colors)+
  ggplot2::scale_fill_manual(values = leg_colors)+
  ggplot2::scale_alpha_manual(values = c(0.65, 0.50, 0.35, 0.25, 0.15))+
  # ggplot2::geom_line(size = 0.1)+
  ggplot2::ylim(0,1)+
  ggplot2::labs(title = "Fraction of Population Under Water Deficits in Texas During 2011",
                subtitle = "Categorized by Intensity of Return Period",
                x = "",
                y = "Fraction of Population",
                caption = "Population derived from Gridded Population of the World (2010)",
                color = "Return Period", fill = "Return Period", group = "Return Period", alpha = "Return Period")+
  ggplot2::theme_minimal()

levels(pop_by_rp$return_period)
