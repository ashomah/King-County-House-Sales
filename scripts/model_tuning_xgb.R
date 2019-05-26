####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 32

set.seed(2019)

nrounds = 1000

xgb_grid = expand.grid(
  nrounds = seq(from = 200, to = nrounds, by = 100),
  max_depth = c(2, 3, 4, 5, 6),
  eta = c(0.025, 0.05, 0.1, 0.2, 0.3),
  gamma = 0,
  colsample_bytree = 1,
  min_child_weight = c(2, 3, 5),
  subsample = 1
)

tuneControl <-
  trainControl(
    method = 'cv',
    number = 10,
    verboseIter = TRUE,
    allowParallel = TRUE
  )

# eXtreme Gradient BOOSTing for Tuning ----
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
               'Starting Model Fit...'))
  time_fit_start <- Sys.time()
  hp_fit_xgb_tuning <-
    train(
      price ~ .,
      data = hp_train_A_rfe,
      method = 'xgbTree',
      trControl = tuneControl,
      tuneGrid = xgb_grid,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_xgb_tuning <- time_fit_end - time_fit_start
  saveRDS(hp_fit_xgb_tuning, 'models/hp_fit_xgb_tuning.rds')
  saveRDS(time_fit_duration_xgb_tuning,
          'models/time_fit_duration_xgb_tuning.rds')
}

hp_fit_xgb_tuning <- readRDS('models/hp_fit_xgb_tuning.rds')
time_fit_duration_xgb_tuning <-
  readRDS('models/time_fit_duration_xgb_tuning.rds')

residuals_xgb_tuning <- resid(hp_fit_xgb_tuning)
hp_pred_xgb_tuning <-
  predict(hp_fit_xgb_tuning, hp_train_B_rfe)
comp_xgb_tuning <- data.frame(obs = hp_train_B_rfe$price,
                              pred = hp_pred_xgb_tuning)

results_xgb_tuning <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_xgb_tuning)),
      'MAPE' = MAPE(y_pred = hp_pred_xgb_tuning, y_true = hp_train_B_rfe$price),
      'Coefficients' = hp_fit_xgb_tuning$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_tuning, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_xgb_tuning)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_xgb_tuning)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_xgb_tuning)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Tuning XGBoost' = results_xgb_tuning)

# summary(hp_fit_xgb_tuning)

png(
  paste0('plots/', plot_counter, '. xgb_tuning_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_xgb_tuning), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_tuning_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_xgb_tuning)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_tuning_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_xgb_tuning)
dev.off()
plot_counter = plot_counter + 1

hp_pred_xgb_tuning_test <-
  predict(hp_fit_xgb_tuning, hp_test_rfe)
submission_xgb_tuning <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_tuning_test * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))
write.csv(submission_xgb_tuning,
          'submissions/xgb_tuning.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_xgb_tuning_train_B <-
  predict(hp_fit_xgb_tuning, hp_train_B_rfe)
submission_xgb_tuning_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_tuning_train_B * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))

real_results_xgb_tuning <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_xgb_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_xgb_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_xgb_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_xgb_tuning_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = hp_fit_xgb_tuning$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_tuning, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind(all_real_results, 'Tuning XGBoost' = real_results_xgb_tuning)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Tuning with XGBoost is done!'))
