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
  hp_fit_xgb_FE <-
    train(
      price ~ .,
      data = hp_train_A_FE2,
      method = 'xgbTree',
      trControl = fitControl,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_xgb_FE <- time_fit_end - time_fit_start
  saveRDS(hp_fit_xgb_FE, 'models/hp_fit_xgb_FE.rds')
  saveRDS(time_fit_duration_xgb_FE,
          'models/time_fit_duration_xgb_FE.rds')
}

hp_fit_xgb_FE <- readRDS('models/hp_fit_xgb_FE.rds')
time_fit_duration_xgb_FE <-
  readRDS('models/time_fit_duration_xgb_FE.rds')

residuals_xgb_FE <- resid(hp_fit_xgb_FE)
hp_pred_xgb_FE <-
  predict(hp_fit_xgb_FE, hp_train_B_FE2)
comp_xgb_FE <- data.frame(obs = hp_train_B_FE2$price,
                          pred = hp_pred_xgb_FE)

results_xgb_FE <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_xgb_FE)),
      'MAPE' = MAPE(y_pred = hp_pred_xgb_FE, y_true = hp_train_B_FE2$price),
      'Coefficients' = hp_fit_xgb_FE$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_FE, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_xgb_FE)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_xgb_FE)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_xgb_FE)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'FE XGBoost' = results_xgb_FE)

# summary(hp_fit_xgb_FE)

png(
  paste0('plots/', plot_counter, '. xgb_FE_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_xgb_FE), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_FE_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_xgb_FE)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. xgb_FE_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_xgb_FE)
dev.off()
plot_counter = plot_counter + 1

hp_pred_xgb_FE_test <-
  predict(hp_fit_xgb_FE, hp_test_FE2)
submission_xgb_FE <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_FE_test * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))
write.csv(submission_xgb_FE,
          'submissions/xgb_FE.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_xgb_FE_train_B <-
  predict(hp_fit_xgb_FE, hp_train_B_FE2)
submission_xgb_FE_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_xgb_FE_train_B * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))

real_results_xgb_FE <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_xgb_FE_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_xgb_FE_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_xgb_FE_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_xgb_FE_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = hp_fit_xgb_FE$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_FE, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind(all_real_results, 'FE XGBoost' = real_results_xgb_FE)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'FE with XGBoost is done!'))
