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
  library(pROC)
  library(tidyverse)
  library(xgboost)
})


##---- XGBoost for all variables ----
## transform data
stock.x <- as.matrix(stock.train[-6])
stock.y <- stock.train$stockout
stock.dm <- xgb.DMatrix(data = stock.x, label = stock.y)

## XXGBoost
stock.params <- list(
  booster = 'gbtree', 
  eta = 0.01, 
  gamma = 5, #
  max_depth = 5, #
  min_child_weight = 1, 
  subsample = 0.5, 
  colsample_bytree = 1, 
  eval_metric = 'error', 
  num_class = 2
)

set.seed(22)
stock.xgb <- xgb.train(params = stock.params, data = stock.dm, nrounds = 100, print_every_n = 10)

## importance
stock.impt <- xgb.importance(feature_names = colnames(stock.train)[-6], 
                             model = stock.xgb)
xgb.ggplot.importance(stock.impt)

## predict
stock.pred <- predict(stock.xgb, newdata = as.matrix(stock.test[-6]), reshape = TRUE)


##---- XGBoost for each product ----
## tomato
tomato.x <- as.matrix(stock.train[])




