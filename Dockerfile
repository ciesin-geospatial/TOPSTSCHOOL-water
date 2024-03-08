# Get the rocker image we want
FROM rocker/geospatial:latest

# copy the lesson contents into the image
## WSIM lessons
ADD wsim-gldas-acquisition.qmd /home/rstudio/
ADD wsim-gldas-vis.qmd /home/rstudio/

## WSIM files (temporary solution)
ADD composite_12mo.nc /home/rstudio
ADD composite_1mo.nc /home/rstudio

## MODIS NRT LESSON
ADD lance-modis-nrt-global-flood-mcdwd-f3.qmd /home/rstudio

## Copy the shiny app
ADD /nyc_lead_dev home/rstudio

## give the rstudio user permissions on these files
RUN chown -R rstudio /home/rstudio/

# Add packages not part of rocker/geospatial
RUN Rscript -e "install.packages('cubelyr')"
RUN Rscript -e "install.packages('exactextractr')"
RUN Rscript -e "install.packages('basemaps')"
RUN Rscript -e "install.packages('shiny')"

CMD ["/init"]