# Title     : TODO
# Objective : TODO
# Created by: wsz19
# Created on: 3/26/2021

# Title     : TODO

# Objective : TODO
# Created by: wsz19
# Created on: 3/10/2021

library(rgeos)
library(sf)
library(sp)
library(raster)
library(rgdal)
library(tidyverse)
library(haven)
library(spatstat)
library(maptools)
library(VIM)
library(units)
library(tidymodels)
library(randomForest)
library(keras)
library(heatmaply)
library(vip)

########################################
### Import and modify household data ###
########################################

# households <- read_dta("data/LBHR6ADT/LBHR6AFL.DTA")
# households <- read_dta("data/GHHR72DT/GHHR72FL.DTA")
households <- read_dta("C:/project/JOHR73FL.DTA")

hhid <- households$hhid #check length(unique(hhid))
unit <- households$hv004
weights <- households$hv005 / 1000000
# location <- as_factor(households$shcounty) #Liberia
# location <- as_factor(households$shdist) #Ghana
location <- as_factor(households$shregion) #Jordan
size <- households$hv009
# sex <- households[ ,371:423] #Liberia
# sex <- households[ ,299:323] #Ghana
sex <- households[ ,300:319] #Jordan
# age <- households[ ,424:476] #Liberia
# age <- households[ ,324:348] #Ghana
age <- households[ ,320:339] # Jordan
# edu <- households[ ,477:529] #Liberia
# edu <- households[ ,349:373] #Ghana
edu <- households[ ,340:359] #Jordan

# your_variable <- households[ ,seq(from = 450, to = 550, by = 20)] #script to extract variables as sequence
# which( colnames(households)=="hv104_01" )
# which( colnames(households)=="hv104_25" )

wealth <- households$hv270

hhs <- cbind.data.frame(hhid, unit, weights, location, size, sex, age, edu, wealth)

gender <- hhs %>%
  pivot_longer(cols = starts_with("hv104"),
               names_to = "pid",
               values_to = "gender",
               values_drop_na = TRUE)

age <- hhs %>%
  pivot_longer(cols = starts_with("hv105"),
               names_to = "pid",
               values_to = "age",
               values_drop_na = TRUE)

edu <- hhs %>%
  pivot_longer(cols = starts_with("hv106"),
               names_to = "pid",
               values_to = "edu",
               values_drop_na = TRUE)

gender <- select(gender, -starts_with("hv"))
age <- select(age, -starts_with("hv"))
edu <- select(edu, -starts_with("hv"))

# if number of observations are not equal

gender$id <- paste(gender$hhid, substr(gender$pid, 7,8), sep = '')
age$id <- paste(age$hhid, substr(age$pid, 7,8), sep = '')
edu$id <- paste(edu$hhid, substr(edu$pid, 7,8), sep = '')
# pns <- merge(gender, age, by = 'id')
# pns <- merge(pns, edu, by = 'id')

pns <- inner_join(gender, age, by = "id") %>% inner_join(., edu, by = "id")

sum(pns$weights)
nrow(pns)

#pns <- pns %>% # add weights later
#  select(size, gender, age, edu, wealth)

pns <- gender %>%
  cbind.data.frame(age = age$age, edu = edu$edu)

#pns$size <- as.numeric(pns$size)
#pns$gender <- as.factor(pns$gender)
#pns$age <- as.factor(pns$age)
#pns$edu <- as.factor(pns$edu)
#pns$wealth <- as.factor(pns$wealth)

write.csv(pns,'personal_data.csv')

########################
### analyze the data ###
########################

# install.packages("heatmaply", repos='http://cran.us.r-project.org')
library(heatmaply)

pns_prep <- as.data.frame(pns[c(6,8,10,11)])
pns_prep <- slice_sample(pns_prep, n = 1000, replace = FALSE)

plot <- heatmaply(
  pns_prep,
  xlab = "Features",
  ylab = "Combinations",
  main = "Raw data",
  cexRow = .25)

ggsave("raw.png", width = 25, height = 25)

plot <- heatmaply(
  scale(pns_prep),
  xlab = "Features",
  ylab = "Combinations",
  main = "Scaled data",
  cexRow = .25)

ggsave("scale.png", width = 25, height = 25)

plot <- heatmaply(
  normalize(pns_prep),
  xlab = "Features",
  ylab = "education",
  main = "Normalize data",
  cexRow = .25
)

ggsave("normal.png", width = 25, height = 25)

plot <- heatmaply(
  percentize(pns_prep),
  xlab = "Features",
  ylab = "education",
  main = "Percentize data",
  cexRow = .25
)

ggsave("percent.png", width = 25, height = 25)