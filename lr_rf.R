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

########################
### model the data ###
########################

pns <- pns %>% # add weights later
  select(size, gender, age, edu, wealth)

pns$size <- as.numeric(pns$size)
pns$gender <- as.factor(pns$gender)
pns$age <- as.factor(pns$age)
pns$edu <- as.factor(pns$edu)
pns$wealth <- as.factor(pns$wealth)

glimpse(pns)

pns %>%
  count(wealth) %>%
  mutate(prop = n/sum(n))

# splitting and sampling

splits      <- initial_split(pns, strata = wealth)

pns_other <- training(splits)
pns_test  <- testing(splits)

pns_other %>%
  count(wealth) %>%
  mutate(prop = n/sum(n))

pns_test  %>%
  count(wealth) %>%
  mutate(prop = n/sum(n))

val_set <- validation_split(pns_other,
                            strata = wealth,
                            prop = 0.80)
val_set

# penalized logistic regression

lr_mod <-
  multinom_reg(penalty = tune(), mixture = 1) %>%
  set_engine("glmnet")

lr_recipe <-
  recipe(wealth ~ ., data = pns_other) %>%
  step_dummy(all_nominal(), -all_outcomes()) %>%
  step_zv(all_predictors()) %>%
  step_normalize(all_predictors())

# create workflow

lr_workflow <-
  workflow() %>%
  add_model(lr_mod) %>%
  add_recipe(lr_recipe)

lr_reg_grid <- tibble(penalty = 10^seq(-4, -1, length.out = 30))

lr_reg_grid %>% top_n(-5) # lowest penalty values

lr_reg_grid %>% top_n(5)

lr_res <-
  lr_workflow %>%
  tune_grid(val_set,
            grid = lr_reg_grid,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(roc_auc))

lr_plot <-
  lr_res %>%
  collect_metrics() %>%
  ggplot(aes(x = penalty, y = mean)) +
  geom_point() +
  geom_line() +
  ylab("Area under the ROC Curve") +
  scale_x_log10(labels = scales::label_number())

lr_plot

ggsave("lr_plot.png")

top_models <-
  lr_res %>%
  show_best("roc_auc", n = 15) %>%
  arrange(penalty)
top_models

lr_best <-
  lr_res %>%
  collect_metrics() %>%
  arrange(penalty) %>%
  slice(10)
lr_best

lr_auc <-
  lr_res %>%
  collect_predictions(parameters = lr_best) %>%
  roc_curve(wealth, .pred_1:.pred_2:.pred_3:.pred_4:.pred_5) %>%
  mutate(model = "Logistic Regression")

autoplot(lr_auc)
ggsave("lr_auc.png")

# random forest

cores <- parallel::detectCores()
cores

rf_mod <-
  rand_forest(mtry = tune(), min_n = tune(), trees = 1000) %>%
  set_engine("ranger", num.threads = cores) %>%
  set_mode("classification")

rf_recipe <-
  recipe(wealth ~ ., data = pns_other)

rf_workflow <-
  workflow() %>%
  add_model(rf_mod) %>%
  add_recipe(rf_recipe)

rf_mod

rf_mod %>%
  parameters()

rf_res <-
  rf_workflow %>%
  tune_grid(val_set,
            grid = 25,
            control = control_grid(save_pred = TRUE),
            metrics = metric_set(roc_auc))

rf_res %>%
  show_best(metric = "roc_auc")

autoplot(rf_res)
ggsave("rf_res.png")

rf_best <-
  rf_res %>%
  select_best(metric = "roc_auc")
rf_best

rf_res %>%
  collect_predictions()

rf_auc <-
  rf_res %>%
  collect_predictions(parameters = rf_best) %>%
  roc_curve(wealth, .pred_1:.pred_2:.pred_3:.pred_4:.pred_5) %>%
  mutate(model = "Random Forest")

autoplot(rf_auc)
ggsave("rf_auc.png")

bind_rows(rf_auc, lr_auc) %>%
  ggplot(aes(x = 1 - specificity, y = sensitivity, col = model)) +
  geom_path(lwd = 1.5, alpha = 0.8) +
  geom_abline(lty = 3) +
  coord_equal() +
  scale_color_viridis_d(option = "plasma", end = .6)

ggsave("rf_lr_auc.png")

# second random forest

last_rf_mod <-
  rand_forest(mtry = 2, min_n = 40, trees = 1000) %>%
  set_engine("ranger", num.threads = cores, importance = "impurity") %>%
  set_mode("classification")

last_rf_workflow <-
  rf_workflow %>%
  update_model(last_rf_mod)

last_rf_fit <-
  last_rf_workflow %>%
  last_fit(splits)

last_rf_fit

last_rf_fit %>%
  collect_metrics()

last_rf_fit %>%
  pluck(".workflow", 1) %>%
  pull_workflow_fit() %>%
  vip(num_features = 20)

ggsave("last_rf_fit.png")

last_rf_fit %>%
  collect_predictions() %>%
  roc_curve(wealth, .pred_1:.pred_2:.pred_3:.pred_4:.pred_5) %>%
  autoplot()

ggsave("last_rf_fit_auc.png")