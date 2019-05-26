####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 26

set.seed(2019)

ranger_grid = expand.grid(
  mtry = c(1, 2, 3, 4, 5, 6, 7, 10),
  splitrule = c('variance', 'extratrees', 'maxstat'),
  min.node.size = c(1, 3, 5)
)

tuneControl <-
  trainControl(
    method = 'cv',
    number = 10,
    verboseIter = TRUE,
    allowParallel = TRUE
  )

# Tuning with a Random Forest ----
if (calculate == TRUE) {
  # library(doParallel)
  # cl <- makePSOCKcluster(7)
  # clusterEvalQ(cl, library(foreach))
  # registerDoParallel(cl)
  print(paste0('[',
               round(
                 difftime(Sys.time(), start_time, units = 'mins'), 1
               ),
               'm]: ',
               'Starting Model Fit...'))
  time_fit_start <- Sys.time()
  hp_fit_ranger_tuning <-
    train(
      price ~ .,
      data = hp_train_A_rfe,
      method = 'ranger',
      trControl = tuneControl,
      tuneGrid = ranger_grid,
      metric = 'MAE',
      importance = 'impurity',
      verbose = TRUE,
      num.thread = detectCores() - 1
    )
  time_fit_end <- Sys.time()
  # stopCluster(cl)
  time_fit_duration_ranger_tuning <- time_fit_end - time_fit_start
  saveRDS(hp_fit_ranger_tuning,
          'models/hp_fit_ranger_tuning.rds')
  saveRDS(time_fit_duration_ranger_tuning,
          'models/time_fit_duration_ranger_tuning.rds')
}

hp_fit_ranger_tuning <-
  readRDS('models/hp_fit_ranger_tuning.rds')
time_fit_duration_ranger_tuning <-
  readRDS('models/time_fit_duration_ranger_tuning.rds')

residuals_ranger_tuning <- resid(hp_fit_ranger_tuning)
hp_pred_ranger_tuning <-
  predict(hp_fit_ranger_tuning, hp_train_B_rfe)
comp_ranger_tuning <- data.frame(obs = hp_train_B_rfe$price,
                                 pred = hp_pred_ranger_tuning)

results_ranger_tuning <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_ranger_tuning)),
      'MAPE' = MAPE(y_pred = hp_pred_ranger_tuning, y_true = hp_train_B_rfe$price),
      'Coefficients' = length(hp_fit_ranger_tuning$finalModel$xNames),
      'Train Time (min)' = round(as.numeric(time_fit_duration_ranger_tuning, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_ranger_tuning)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_ranger_tuning)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_ranger_tuning)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Tuning Ranger' = results_ranger_tuning)

# summary(hp_fit_ranger_tuning)

png(
  paste0('plots/', plot_counter, '. ranger_tuning_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_ranger_tuning), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. ranger_tuning_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_ranger_tuning)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. ranger_tuning_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_ranger_tuning)
dev.off()
plot_counter = plot_counter + 1

hp_pred_ranger_tuning_test <-
  predict(hp_fit_ranger_tuning, hp_test_rfe)
submission_ranger_tuning <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_ranger_tuning_test * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))
write.csv(submission_ranger_tuning,
          'submissions/ranger_tuning.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_ranger_tuning_train_B <-
  predict(hp_fit_ranger_tuning, hp_train_B_rfe)
submission_ranger_tuning_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_ranger_tuning_train_B * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))

real_results_ranger_tuning <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_ranger_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_ranger_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_ranger_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_ranger_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = length(hp_fit_ranger_tuning$finalModel$xNames),
      'Train Time (min)' = round(as.numeric(time_fit_duration_ranger_tuning, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind(all_real_results, 'Tuning Ranger' = real_results_ranger_tuning)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Tuning with Ranger is done!'))
