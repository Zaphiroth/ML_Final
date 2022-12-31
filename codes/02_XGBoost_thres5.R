options(java.parameters = "-Xmx2048m",
        stringsAsFactors = FALSE, 
        encoding = 'UTF-8')

suppressPackageStartupMessages({
  library(zip)
  library(openxlsx)
  library(readxl)
  library(writexl)
  library(RcppRoll)
  library(plyr)
  library(stringi)
  library(feather)
  library(RODBC)
  library(MASS)
  library(car)
  library(caret)
  library(data.table)
  library(lubridate)
  library(plotly)
  library(tidyverse)
  library(xgboost)
  library(pROC)
  library(cvms)
})

source('./functions/XGBoost.R')
source('./functions/ROCCurve.R')


##---- Parameters ----
xgb.params <- list(
  booster = 'gbtree', 
  eta = 0.01, 
  gamma = 1, 
  max_depth = 10, 
  min_child_weight = 1, 
  subsample = 0.75, 
  colsample_bytree = 1, 
  eval_metric = 'error', 
  num_class = 2, 
  nthread = 5
)


##---- XGBoost ----
## all
stock.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = NULL, 
  seed = 0, 
  params = xgb.params, 
  nrounds = 300
)

## tomato
tomato.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = 1, 
  seed = 1, 
  params = xgb.params, 
  nrounds = 300
)

## carrot
carrot.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = 2, 
  seed = 2, 
  params = xgb.params, 
  nrounds = 300
)

## yam
yam.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = 3, 
  seed = 3, 
  params = xgb.params, 
  nrounds = 300
)

## potato
potato.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = 4, 
  seed = 4, 
  params = xgb.params, 
  nrounds = 300
)

## onion
tomato.xgb5 <- XGBoost(
  stock.train5, 
  stock.test5, 
  product = 5, 
  seed = 5, 
  params = xgb.params, 
  nrounds = 300
)

