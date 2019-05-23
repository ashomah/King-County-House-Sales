####
#### THIS SCRIPT DEFINES THE PARAMETERS OF THE BASELINE
####

time_fit_start <- 0
time_fit_end <- 0


# Function to get the best results in caret ----
get_best_result = function(caret_fit) {
  best = which(rownames(caret_fit$results) == rownames(caret_fit$bestTune))
  best_result = caret_fit$results[best,]
  rownames(best_result) = NULL
  best_result
}


# Function to plot residuals ----
plot_residuals <- function (residuals, title = '') {
  p1 <- ggplot(as.data.frame(residuals),
               aes(x = seq_along(residuals), y = residuals)) +
    geom_point(color = 'darkcyan', size = 0.5) +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = 'Scatterplot', y = '')
  
  p2 <- ggplot(as.data.frame(residuals),
               aes(x = residuals)) +
    geom_histogram(fill = 'darkcyan', bins = 100) +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = 'Histogram', y = '')
  
  p3 <- ggplot(as.data.frame(residuals),
               aes(y = residuals)) +
    geom_boxplot(color = 'darkcyan') +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = 'Boxplot', y = '')
  
  p4 <- ggplot(as.data.frame(residuals),
               aes(sample = residuals)) +
    geom_qq(color = 'darkcyan', size = 0.5) +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = 'QQplot', y = '')
  
  grobs <- list()
  grobs[[1]] <- p1
  grobs[[2]] <- p2
  grobs[[3]] <- p3
  grobs[[4]] <- p4
  grid.arrange(
    grobs = grobs,
    nrow = 2,
    ncol = 2,
    top = ifelse(title != '', paste0('Residuals of ', title), 'Residuals')
  )
}


# Splitting Train Set into two parts ----
set.seed(2019)
# registerDoMC(cores = 3)

index <-
  createDataPartition(hp_train$price,
                      p = 0.8,
                      list = FALSE,
                      times = 1)
hp_train_A <- hp_train[index, ]
hp_train_B <- hp_train[-index, ]

print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'mins'), 1),
    'm]: ',
    'Train Set is split!'
  )
)


# Center and Scale Train Sets and Test Set ----
preProcValues <-
  preProcess(hp_train_A, method = c("center", "scale"))
hp_train_A_proc <- predict(preProcValues, hp_train_A)
hp_train_B_proc <- predict(preProcValues, hp_train_B)
hp_test_proc <- predict(preProcValues, hp_test)

hp_train_all_fact <- hp_train
hp_test_all_fact <- hp_test
hp_train_all_fact$bathrooms <- as.factor(hp_train_all_fact$bathrooms)
hp_train_all_fact$zipcode <- as.factor(hp_train_all_fact$zipcode)
hp_test_all_fact$bathrooms <- as.factor(hp_test_all_fact$bathrooms)
hp_test_all_fact$zipcode <- as.factor(hp_test_all_fact$zipcode)

hp_train_A_all_fact <- hp_train_all_fact[index, ]
hp_train_B_all_fact <- hp_train_all_fact[-index, ]

preProcValues <-
  preProcess(hp_train_A_all_fact, method = c("center", "scale"))
hp_train_A_proc_all_fact <- predict(preProcValues, hp_train_A_all_fact)
hp_train_B_proc_all_fact <- predict(preProcValues, hp_train_B_all_fact)
hp_test_proc_all_fact <- predict(preProcValues, hp_test_all_fact)

print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'mins'), 1),
    'm]: ',
    'Data Sets are centered and scaled!'
  )
)


# Cross-Validation Settings ----
fitControl <-
  trainControl(
    method = 'repeatedcv',
    number = 10,
    repeats = 3,
    verboseIter = TRUE
  )


