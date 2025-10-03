# Library can be installed from CRAN
library(ggplot2)

# load the values predicted by the logistic models.
load("Prediction.RData")

# For privacy reasons, the variable selection and model estimations steps are
# not included in this code. 
# Nevertheless, the code can be used to aggregate the predicted values from any
# set of models, provided that their sensitivities and specificities are known 
# and the aggregation assumptions are met.

# load the sensitivities and specificities
load("Parameters.RData")

##### Indicator calculation
# functions:
# - my_parameters: computes the parameters alpha and gamma
# - my_indicator: aggregates the predictions using as weights alpha and gamma
# - my_graph: plot the distribution of the indicator normalized

my_parameters <- function(par){
  # par is a matrix containing sensitivity, specificity and constant for each
  # logistic model
  
  sens <- par$Sensibility
  spec <- par$Specificity
  
  alpha <- (sens*spec)/((1-sens)*(1-spec))
  gamma <- (sens*(1-sens))/(spec*(1-spec))
  
  par$Alpha <- round(alpha,3)
  par$Gamma <- round(gamma,3)
  
  return(par)
}

my_indicator <- function(par,pred){
  # par is a matrix containing constant, alpha, and gamma for each model
  # pred is a matrix contains the values of the prediction from logistic models
  # for each person in the test set
  
  alpha <- par$Alpha
  gamma <- par$Gamma
  c <- par$Constant
  
  superFI <- apply(pred, 1,function(x) 
    sum((x-c)*log(alpha)+log(gamma)))
  
  superFI <- as.data.frame(superFI)
  colnames(superFI) <- c("Indicator")
  superFI$Normalised <- (superFI[,"Indicator"]-min(superFI[,"Indicator"]))/
    (max(superFI[,"Indicator"])-min(superFI[,"Indicator"]))
  
  return(superFI)
}

my_graph <- function(superFI){
  # superFI is the data frame containing the super-classifier indicator and the
  # normalized version obtained with my_indicator function
  
  Norm <- superFI$Normalised
  mean <- mean(Norm, na.rm = TRUE)
  median <- median(Norm, na.rm = TRUE)
  
  line_data <- data.frame(
    x = c(mean, median),
    xend = c(mean, median),
    y = c(0, 0),
    yend = c(25, 25),
    label = c("Mean", "Median")
  )

  p <- ggplot(superFI, aes(x = Normalised)) +
    geom_histogram(
      aes(y = after_stat(count) / sum(after_stat(count)) * 100),
      fill = "gray", 
      color = "black",
      bins = 30, 
      alpha = 0.7
    ) +
    geom_segment(data = line_data,
                 aes(x = x, xend = xend, 
                     y = y, yend = yend, 
                     color = label, 
                     linetype = label),
                 linewidth = 0.5, inherit.aes = FALSE) +
    scale_color_manual(name = "Statistics",
                       values = c("Mean" = "red",
                                  "Median" = "blue")) +
    scale_linetype_manual(name = "Statistics",
                          values = c("Mean" = "dashed", 
                                     "Median" = "dashed")) +
    labs(
      x = "Indicator",
      y = "Percentage"
    ) +
    coord_cartesian(ylim = c(0, 25)) +
    theme_minimal()
  
  return(p)
}


## EXAMPLE:
# calculation of alpha and gamma parameters
parameters <- my_parameters(parameters)

# indicator calculation
indicator <- my_indicator(par = parameters, pred = prediction)

# plot the distribution
distibution <- my_graph(indicator)
plot(distibution)
