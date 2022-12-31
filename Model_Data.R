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


##---- Readin data ----
stock.raw <- read_xlsx('stock.xlsx')
colnames(stock.raw) <- c('id', 'date', 'store', 'product', 'stock', 'receipt', 'sales', 'stockout')

stock.clean <- stock.raw %>% 
  select(-id, -date) %>% 
  mutate(store = ifelse(store == 'A店', 'A', 
                        ifelse(store == 'B店', 'B', 
                               ifelse(store == 'C店', 'C', 
                                      ifelse(store == 'D店', 'D', 
                                             'E'))))) %>% 
  mutate(product = ifelse(product == '番茄', 'Tomato', 
                          ifelse(product == '胡萝卜', 'Carrot', 
                                 ifelse(product == '山药', 'Yam', 
                                        ifelse(product == '土豆', 'Potato', 
                                               ifelse(product == '洋葱', 'Onion', 
                                                      'Others'))))))


##---- Determine the stockout threshold ----
stockout.total <- sort(stock.clean$stockout)
stockout.tomato <- sort(stock.clean$stockout[stock.clean$product == 'Tomato'])
stockout.carrot <- sort(stock.clean$stockout[stock.clean$product == 'Carrot'])
stockout.yam <- sort(stock.clean$stockout[stock.clean$product == 'Yam'])
stockout.potato <- sort(stock.clean$stockout[stock.clean$product == 'Potato'])
stockout.onion <- sort(stock.clean$stockout[stock.clean$product == 'Onion'])

summary(stockout.total)
summary(stockout.tomato)
summary(stockout.carrot)
summary(stockout.yam)
summary(stockout.potato)
summary(stockout.onion)

plot(stockout.total)
plot(stockout.tomato)
plot(stockout.carrot)
plot(stockout.yam)
plot(stockout.potato)
plot(stockout.onion)

## threshold can be 0
stock.stockout <- stock.clean %>% 
  mutate(store = ifelse(store == 'A', 1, 
                        ifelse(store == 'B', 2, 
                               ifelse(store == 'C', 3, 
                                      ifelse(store == 'D', 4, 
                                             0)))), 
         product = ifelse(product == 'Tomato', 1, 
                          ifelse(product == 'Carrot', 2, 
                                 ifelse(product == 'Yam', 3, 
                                        ifelse(product == 'Potato', 4, 
                                               ifelse(product == 'Onion', 5, 
                                                      0)))))) %>% 
  mutate(stockout = if_else(stockout > 0, 1, stockout))

# write.csv(stock.stockout, 'stock_thres0.csv', row.names = FALSE)

## check segments
stock.stockout.chk <- stock.stockout %>% 
  group_by(store, product, stockout) %>% 
  summarise(num = n())


##---- Split train and test set ----
set.seed(2022)
split.set <- sample(c(0,1), size = 7724, replace = TRUE, prob = c(0.8, 0.2))

stock.train <- stock.stockout[split.set == 0, ]
stock.test <- stock.stockout[split.set == 1, ]

