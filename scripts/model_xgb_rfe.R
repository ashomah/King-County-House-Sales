####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 32

set.seed(2019)

# eXtreme Gradient BOOSTing with Feature Engineering ----
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
  hp_fit_xgb_rfe <-
    train(
      price ~ .,
      data = hp_train_A_rfe,
      method = 'xgbTree',
      trControl = fitControl,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_xgb_rfe <- time_fit_end - time_fit_start
  saveRDS(hp_fit_xgb_rfe, 'models/hp_fit_xgb_rfe.rds')
  saveRDS(time_fit_duration_xgb_rfe,
          'models/time_fit_duration_xgb_rfe.rds')
}

hp_fit_xgb_rfe <- readRDS('models/hp_fit_xgb_rfe.rds')
time_fit_duration_xgb_rfe <-
  readRDS('models/time_fit_duration_xgb_rfe.rds')

residuals_xgb_rfe <- resid(hp_fit_xgb_rfe)
hp_pred_xgb_rfe <-
  predict(hp_fit_xgb_rfe, hp_train_B_rfe)
comp_xgb_rfe <- data.frame(obs = hp_train_B_rfe$price,
                           pred = hp_pred_xgb_rfe)

results_xgb_rfe <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_xgb_rfe)),
      'MAPE' = MAPE(y_pred = hp_pred_xgb_rfe, y_true = hp_train_B_rfe$price),
      'Coefficients' = hp_fit_xgb_rfe$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_rfe, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_xgb_rfe)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_xgb_rfe)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_xgb_rfe)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'XGBoost Post RFE' = results_xgb_rfe)

# summary(hp_fit_xgb_rfe)

png(
  paste0('plots/', plot_counter, '. xgb_rfe_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_xgb_rfe), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_rfe_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_xgb_rfe)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_rfe_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_xgb_rfe)
dev.off()
plot_counter = plot_counter + 1

hp_pred_xgb_rfe_test <-
  predict(hp_fit_xgb_rfe, hp_test_rfe)
submission_xgb_rfe <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_rfe_test * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))
write.csv(submission_xgb_rfe,
          'submissions/xgb_rfe.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_xgb_rfe_train_B <-
  predict(hp_fit_xgb_rfe, hp_train_B_rfe)
submission_xgb_rfe_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_rfe_train_B * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))

real_results_xgb_rfe <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_xgb_rfe_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_xgb_rfe_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_xgb_rfe_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_xgb_rfe_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = hp_fit_xgb_rfe$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_rfe, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind(all_real_results, 'XGBoost Post RFE' = real_results_xgb_rfe)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'XGBoost Post RFE is done!'))
