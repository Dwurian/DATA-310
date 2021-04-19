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
library(tidymodels)
library(vip)
library(rmapshaper)
library(rgeos)
library(rgdal)
library(mapsRinteractive)
library(rgl)
library(rasterVis)
library(randomForest)

setwd("C:/Users/wsz19/Desktop/Ahhhhh/202101Spring/DATA310/Module_3/data")

### Import Administrative Boundaries ###

jor_adm0  <- read_sf("gadm36_JOR_0.shp")
jor_adm1  <- read_sf("gadm36_JOR_1.shp")
jor_adm2  <- read_sf("gadm36_JOR_2.shp")

# plot(st_geometry(jor_adm2))

jor_adm2 <- ms_simplify(jor_adm2)
jor_adm1 <- ms_dissolve(jor_adm2, field = "NAME_1")
jor_adm0 <- ms_dissolve(jor_adm2)

jor_adm0 <- st_as_sf(jor_adm0)
jor_adm1 <- st_as_sf(jor_adm1)
jor_adm2 <- st_as_sf(jor_adm2)

jor2_irbid <- jor_adm2 %>%
  filter(NAME_1 == "Irbid" | NAME_1 == "my_nextdoor_neighbor_adm" )

jor1_irbid <- jor_adm1 %>%
  filter(NAME_1 == "Irbid")

plot(st_geometry(jor1_irbid))
plot(st_geometry(jor2_irbid), add = TRUE)

jor1_irbid <- jor1_irbid %>%
  st_union() %>%
  st_as_sf()

ggplot() +
   geom_sf(data = jor_adm1) +
   geom_sf_text(data = jor_adm1,
                aes(label = NAME_1),
                size = .75) +
  geom_sf(data = jor1_irbid,
          aes(color = "red"))

### Import Land Use Land Cover, Night Time Lights and Settlements Covariates ###

f <- list.files(pattern="jor_esaccilc_dst", recursive=TRUE)
lulc <- stack(lapply(f, function(i) raster(i, band=1)))

nms <- sub("_100m_2015.tif", "", sub("jor_esaccilc_", "", f))
names(lulc) <- nms

# coastline <- raster("jor_dst_coastline_100m_2000_2020.tif")
# road <- raster("jor_osm_dst_road_100m_2016.tif")
# intersection <- ("jor_osm_dst_roadintersec_100m_2016.tif")
# reserve <- ("jor_wdpa_dst_cat1_100m_2017.tif")
topo <- raster("jor_srtm_topo_100m.tif")
slope <- raster("jor_srtm_slope_100m.tif")
ntl <- raster("jor_viirs_100m_2016.tif")
pop20 <- raster("jor_ppp_2020.tif")

#add hrsl

lulc <- addLayer(lulc, topo, slope, ntl, pop20)

names(lulc)[c(1:13)] <- c("water","cultivated","tree","shrub","herb",
                          "sparse_veg","aqua_veg","artificial",
                          "bare","topo","slope", "ntl", "pop20")

plot(st_geometry(jor1_irbid))
plot(st_geometry(jor2_irbid), add = TRUE)

lulc <- crop(lulc, extent(jor1_irbid))
lulc <- mask(lulc, jor1_irbid)
lulc[is.na(lulc)] <- 0 #this fixes NA
lulc <- crop(lulc, extent(jor1_irbid))
lulc <- mask(lulc, jor1_irbid)

plot(lulc[[13]])

writeRaster(lulc, filename = "lulc.tif", overwrite = TRUE)
lulc <- stack("lulc.tif")
lulc <- brick("lulc.tif")

names(lulc)[c(1:13)] <- c("water","cultivated","tree","shrub","herb",
                          "sparse_veg","aqua_veg","artificial",
                          "bare","topo","slope", "ntl", "pop20")

#lulc_adm2 <- exact_extract(lulc, jor_adm2, fun=c('sum', 'mean'))
lulc_adm2 <- exact_extract(lulc, jor2_irbid, fun=c('sum', 'mean'))

save(lulc_adm2, file = "lulc_adm2.RData")
load("lulc_adm2.RData")

# write.csv(lulc_adm2,"lulc_adm2.csv", row.names = FALSE)

setwd("C:/Users/wsz19/Desktop/Ahhhhh/202101Spring/DATA310/Module_3")

#########################
### Linear Regression ###
#########################

### Step 1. Split our data ###

data <- lulc_adm2[ , 1:13]

# Create a split object
data_split <- initial_split(data, prop = 4/5)

# Build training and testing datasets
data_train <- training(data_split)
data_test <- testing(data_split)


### Step 2. Feature Engineering ###

data_recipe <- recipe(sum.pop20 ~ ., data = data_train)

data_recipe %>%
  prep() %>%
  bake(new_data = data_test)

### Step 3.  Specify a Model ###

lr_model <-
  linear_reg()%>%
  set_engine("lm") %>%
  set_mode("regression")

### Step 4.  Create a Workflow

lr_workflow <- workflow() %>%
  add_recipe(data_recipe) %>%
  add_model(lr_model)

### Step 5.  Execute the Workflow

final_model <- fit(lr_workflow, data)

rstr_to_df <- as.data.frame(lulc, xy = TRUE)
save(rstr_to_df, file = "rstr_to_df.RData")
load("rstr_to_df.RData")

names(rstr_to_df) <- c("x", "y", "sum.water", "sum.cultivated", "sum.tree", "sum.shrub", "sum.herb",
  "sum.sparse_veg", "sum.aqua_veg", "sum.artificial", "sum.bare", "sum.topo", "sum.slope", "sum.ntl", "sum.pop20")

preds <- predict(final_model, new_data = rstr_to_df)

coords_preds <- cbind.data.frame(rstr_to_df[ ,1:2], preds)

predicted_values_sums <- rasterFromXYZ(coords_preds)

ttls <- exact_extract(predicted_values_sums, jor1_irbid, fun=c('sum'))

jor1_irbid <- jor1_irbid %>%
  add_column(preds_sums = ttls)

predicted_totals_sums <- rasterize(jor1_irbid, predicted_values_sums, field = "preds_sums")

gridcell_proportions_sums  <- predicted_values_sums / predicted_totals_sums

cellStats(gridcell_proportions_sums, sum)

jor_pop20 <- raster("data/jor_ppp_2020.tif")
irbid_adm2_pop20 <- exact_extract(jor_pop20, jor1_irbid, fun=c('sum'))
jor1_irbid <- jor1_irbid %>%
  add_column(pop20 = irbid_adm2_pop20)

population_adm2 <- rasterize(jor1_irbid, predicted_values_sums, field = "pop20")

population_sums <- gridcell_proportions_sums * population_adm2

cellStats(population_sums, sum)

sum(jor1_irbid$pop20)

irbid_pop20 <- crop(jor_pop20, jor1_irbid)
irbid_pop20 <- mask(irbid_pop20, jor1_irbid)

diff_sums <- population_sums - irbid_pop20

plot(population_sums)
plot(diff_sums)
rasterVis::plot3D(diff_sums)
cellStats(abs(diff_sums), sum)

irbid_me <- me(irbid_pop20, population_sums)
irbid_mae <- mae(irbid_pop20, population_sums)
irbid_rmse <- rmse(irbid_pop20, population_sums)

plot(irbid_me)
plot(irbid_mae)
plot(irbid_rmse)

rasterVis::plot3D(irbid_me)
rasterVis::plot3D(irbid_mae)
rasterVis::plot3D(irbid_rmse)


data_training_baked <- data_recipe %>%
  prep() %>%
  bake(new_data = data_train)

data_training_baked

data_lr_fit <- lr_model %>%
  fit(sum.pop20 ~ ., data = data_training_baked)

vip(data_lr_fit)

#####################
### Random Forest ###
#####################

model <- randomForest(sum.pop20 ~ ., data = data)

print(model)
plot(model)
varImpPlot(model)

names(lulc) <- c("sum.water", "sum.cultivated", "sum.tree", "sum.shrub", "sum.herb",
  "sum.sparse_veg", "sum.aqua_veg", "sum.artificial", "sum.bare", "sum.topo", "sum.slope", "sum.ntl", "sum.pop20")

predicted_values_sums <- raster::predict(lulc, model, type="response", progress="window")

ttls <- exact_extract(predicted_values_sums, jor1_irbid, fun=c('sum'))

jor1_irbid <- jor1_irbid %>%
  add_column(rf_preds_sums = ttls)

predicted_totals_sums <- rasterize(jor1_irbid, predicted_values_sums, field = "rf_preds_sums")

gridcell_proportions_sums  <- predicted_values_sums / predicted_totals_sums

cellStats(gridcell_proportions_sums, sum)

population_adm2 <- rasterize(jor1_irbid, predicted_values_sums, field = "pop20")

population_sums <- gridcell_proportions_sums * population_adm2

cellStats(population_sums, sum)

sum(jor1_irbid$pop20)

diff_sums <- population_sums - irbid_pop20


plot(population_sums)
plot(diff_sums)
rasterVis::plot3D(diff_sums)
cellStats(abs(diff_sums), sum)

irbid_me <- me(irbid_pop20, population_sums)
irbid_mae <- mae(irbid_pop20, population_sums)
irbid_rmse <- rmse(irbid_pop20, population_sums)

plot(irbid_me)
plot(irbid_mae)
plot(irbid_rmse)

rasterVis::plot3D(irbid_me)
rasterVis::plot3D(irbid_mae)
rasterVis::plot3D(irbid_rmse)

plot(lulc[[13]])