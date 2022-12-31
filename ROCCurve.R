ROCCurve <- function(roc, cutoff) {
  roccurve <- plot_ly(x = 1 - roc$specificities, 
                      y = roc$sensitivities, 
                      type = 'scatter', mode = 'lines', fill = 'tozeroy', 
                      showlegend = FALSE) %>% 
    add_markers(x = 1 - cutoff$specificity, 
                y = cutoff$sensitivity, 
                name = 'Best', inherit = FALSE, showlegend = TRUE) %>% 
    add_segments(x = 0, xend = 1, y = 0, yend = 1, 
                 line = list(dash = 'dash', color = 'black'), 
                 inherit = FALSE, showlegend = FALSE) %>% 
    layout(title = paste0('ROC Curve (AUC = ', round(roc$auc, 2), ')'), 
           xaxis = list(title = 'False Positive Rate'), 
           yaxis = list(title = 'True Positive Rate'), 
           showlegend = TRUE, legend = list(orientation = 'h'))
  
  return(roccurve)
}
