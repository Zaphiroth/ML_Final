XGBoost <- function(train, test, product = NULL, seed = 2022, params, nrounds = 300, print_every_n = 100) {
  ## transform data
  if (is.null(product)) {
    train.x <- as.matrix(select(train, -stockout))
    train.y <- train$stockout
    train.dm <- xgb.DMatrix(data = train.x, label = train.y)
    
    test.x <- as.matrix(select(test, -stockout))
    test.y <- test$stockout
    test.dm <- xgb.DMatrix(data = test.x, label = test.y)
    
  } else {
    train.x <- as.matrix(select(train[train$product == product, ], -store, -product, -stockout))
    train.y <- train[train$product == product, ]$stockout
    train.dm <- xgb.DMatrix(data = train.x, label = train.y)
    
    test.x <- as.matrix(select(test[test$product == product, ], -store, -product, -stockout))
    test.y <- test[test$product == product, ]$stockout
    test.dm <- xgb.DMatrix(data = test.x, label = test.y)
  }
  
  ## XGBoost
  set.seed(seed)
  xgb <- xgb.train(
    params = params, 
    data = train.dm, 
    nrounds = nrounds, 
    print_every_n = print_every_n
  )
  
  ## importance
  im <- xgb.importance(colnames(train.x), model = xgb)
  im.plot <- xgb.ggplot.importance(im)
  
  ## predict
  pred <- predict(xgb, newdata = test.dm)
  
  ## accuracy
  acc <- sum(pred == test.y) / length(pred)
  
  ## confusion matrix
  cm <- confusionMatrix(factor(test.y), factor(pred))
  cm.plot <- plot_confusion_matrix(
    as_tibble(cm$table),
    target_col = 'Reference', 
    prediction_col = 'Prediction', 
    counts_col = 'n'
  )
  
  ## train ROC
  train.roc <- roc(train.y, predict(xgb, newdata = train.x))
  train.cutoff <- coords(train.roc, 'best', rec = 'threshold')
  train.roccurve <- ROCCurve(train.roc, train.cutoff)
  
  ## test  ROC
  test.roc <- roc(test.y, pred)
  test.cutoff <- coords(test.roc, 'best', rec = 'threshold')
  test.roccurve <- ROCCurve(test.roc, test.cutoff)
  
  return(
    list(
      'xgb' = xgb, 
      'im' = im, 
      'im.plot' = im.plot, 
      'pred' = pred, 
      'acc' = acc, 
      'cm' = cm, 
      'cm.plot' = cm.plot, 
      'train.roc' = train.roc, 
      'train.roccurve' = train.roccurve, 
      'test.roc' = test.roc, 
      'test.roccurve' = test.roccurve
    )
  )
}