####
#### THIS SCRIPT SELECTS FEATURE USING A RECURSIVE FEATURE ELIMINATION
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL_LATEST.RData')
# calculate <- TRUE
# plot_counter <- 44

set.seed(2019)

# Feature Selection with Recursive Feature Elimination ----
subsets <- c(20, 30, 40, 50, 60, 80, 100)

ctrl <- rfeControl(
  functions = rfFuncs,
  method = "cv",
  number = 5,
  verbose = TRUE,
  allowParallel = TRUE
)

if (calculate == TRUE) {
  library(doParallel)
  cl <- makePSOCKcluster(7)
  clusterEvalQ(cl, library(foreach))
  registerDoParallel(cl)
  print(paste0('[',
               round(
                 difftime(Sys.time(), start_time, units = 'mins'), 1
               ),
               'm]: ',
               'Starting RFE...'))
  time_fit_start <- Sys.time()
  
  results_rfe <-
    rfe(
      x = hp_train_A_FE2_lasso[,!names(hp_train_A_FE2_lasso) %in% c('price')],
      y = hp_train_A_FE2_lasso[, 'price'],
      sizes = subsets,
      rfeControl = ctrl,
      metric = 'RMSE',
      maximize = FALSE
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_rfe <- time_fit_end - time_fit_start
  saveRDS(results_rfe, 'models/results_rfe.rds')
  saveRDS(time_fit_duration_rfe,
          'models/time_fit_duration_rfe.rds')
}

results_rfe <- readRDS('models/results_rfe.rds')
time_fit_duration_rfe <- readRDS('models/time_fit_duration_rfe.rds')


varImp_rfe <-
  data.frame(
    'Variables' = attr(results_rfe$fit$importance[, 2], which = 'names'),
    'Importance' = as.vector(round(results_rfe$fit$importance[, 2], 4))
  )
varImp_rfe <- varImp_rfe[order(varImp_rfe$Importance), ]
varImp_rfe$perc <-
  round(varImp_rfe$Importance / sum(varImp_rfe$Importance) * 100, 4)
var_sel_rfe <- varImp_rfe[varImp_rfe$perc > 0.1, ]
var_rej_rfe <- varImp_rfe[varImp_rfe$perc <= 0.1, ]

# ggplot(tail(varImp_rfe,50), aes(x = reorder(Variables, Importance), y = Importance)) +
#   geom_bar(stat = 'identity') +
#   coord_flip()

hp_train_A_rfe <-
  hp_train_A_FE2_ohe[, names(hp_train_A_FE2_ohe) %in% var_sel_rfe$Variables |
                       names(hp_train_A_FE2_ohe) == 'price']
hp_train_B_rfe <-
  hp_train_B_FE2_ohe[, names(hp_train_B_FE2_ohe) %in% var_sel_rfe$Variables |
                       names(hp_train_B_FE2_ohe) == 'price']
hp_test_rfe <-
  hp_test_FE2_ohe[, names(hp_test_FE2_ohe) %in% var_sel_rfe$Variables |
                    names(hp_test_FE2_ohe) == 'price']


print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'mins'), 1),
    'm]: ',
    'Feature Selection with Recursive Feature Elimination is done!'
  )
)
