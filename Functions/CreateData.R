# function to create data and ampute it
# requires the packages 'mice' and 'mvtnorm'

data.simulation <- function(n = populationsize, true_effect = 2) {
  # simulate multivariate normal predictors
  means <- c(12, 3, 0.5) #predictor means
  vars  <- c(4, 16, 9) #predictor variances
  R <- matrix(numeric(3 * 3), nrow = 3) #correlation matrix
  diag(R) <- 1 #set diagonal to 1
  R[upper.tri(R)] <-
    R[lower.tri(R)] <- c(.5, .3, .4) #set bivariate correlations
  sigma <-
    diag(sqrt(vars)) %*% R %*% diag(sqrt(vars)) #variance-covariance matrix
  simdata <-
    as.data.frame(mvtnorm::rmvnorm(n = populationsize, mean = means, sigma = sigma)) #create data
  colnames(simdata) <- c("X1", "X2", "X3") #set predictors names
  simdata$X1 <- ifelse(simdata$X1 > mean(simdata$X1), 1, 0) 

  # compute  outcome variable from predictors
  Y <-
    1 + true_effect * simdata$X1 + 0.5 * simdata$X2 - simdata$X3 + rnorm(n = populationsize, sd = 10)
  simdata <- cbind(simdata, Y)
  
  # estimate comlpete data parameters Q
  true.effect <<-
    lm(Y ~ X1 + X2 + X3, data = simdata)[["coefficients"]]
  true.R.sq <<-
    lm(Y ~ X1 + X2 + X3, data = simdata) %>% summary() %>% .$r.squared
  true.mean <<- apply(simdata, 2, mean)
  true.sd <<- apply(simdata, 2, sd)
  true.sigma <<-
    lm(Y ~ X1 + X2 + X3, data = simdata)[["residuals"]] %>% var()
  
  # output
  return(simdata)
  
}
