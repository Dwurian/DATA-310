# Title     : TODO
# Objective : TODO
# Created by: wsz19
# Created on: 3/26/2021

rm(list=ls(all=TRUE))

# install.packages("raster", dependencies = TRUE)
# install.packages("sf", dependencies = TRUE)
# install.packages("tidyverse", dependencies = TRUE)
# install.packages("exactextractr")

library(sf)
library(raster)
library(tidyverse)
library(exactextractr)

setwd("C:/Users/wsz19/Desktop/Ahhhhh/202101Spring/DATA310/Module_3/data")

### Import Administrative Boundaries ###

# jor_int  <- read_sf("gadm36_JOR_0.shp")
# jor_adm1  <- read_sf("gadm36_JOR_1.shp")
jor_adm2  <- read_sf("gadm36_JOR_2.shp")

### Import Land Use Land Cover, Night Time Lights and Settlements Covariates ###

f <- list.files(pattern="jor_esaccilc_dst", recursive=TRUE)
lulc <- stack(lapply(f, function(i) raster(i, band=1)))

nms <- sub("_100m_2015.tif", "", sub("jor_esaccilc_", "", f))
names(lulc) <- nms

coastline <- raster("jor_dst_coastline_100m_2000_2020.tif")
road <- raster("jor_osm_dst_road_100m_2016.tif")
intersection <- ("jor_osm_dst_roadintersec_100m_2016.tif")
reserve <- ("jor_wdpa_dst_cat1_100m_2017.tif")
topo <- raster("jor_srtm_topo_100m.tif")
slope <- raster("jor_srtm_slope_100m.tif")
ntl <- raster("jor_viirs_100m_2016.tif")
pop20 <- raster("jor_ppp_2020.tif")

# add hrsl

lulc <- addLayer(lulc, coastline, road, intersection,
                 reserve, topo, slope, ntl, pop20)

names(lulc)[c(1:17)] <- c("water","cultivated","tree","shrub","herb",
                          "sparse_veg","aqua_veg","artificial",
                          "bare","coastline","road","intersection",
                          "reserve","topo","slope", "ntl", "pop20")

lulc_adm2 <- exact_extract(lulc, jor_adm2, fun=c('sum', 'mean'))

write.csv(lulc_adm2,"lulc_adm2.csv")