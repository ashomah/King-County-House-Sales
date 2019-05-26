####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 32

set.seed(2019)

# Baseline with a eXtreme Gradient BOOSTing ----
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
  hp_fit_baseline_xgb <-
    train(
      price ~ .,
      data = hp_train_A_proc,
      method = 'xgbTree',
      trControl = fitControl,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_baseline_xgb <- time_fit_end - time_fit_start
  saveRDS(hp_fit_baseline_xgb, 'models/hp_fit_baseline_xgb.rds')
  saveRDS(time_fit_duration_baseline_xgb,
          'models/time_fit_duration_baseline_xgb.rds')
}

hp_fit_baseline_xgb <- readRDS('models/hp_fit_baseline_xgb.rds')
time_fit_duration_baseline_xgb <-
  readRDS('models/time_fit_duration_baseline_xgb.rds')

residuals_baseline_xgb <- resid(hp_fit_baseline_xgb)
hp_pred_baseline_xgb <-
  predict(hp_fit_baseline_xgb, hp_train_B_proc)
comp_baseline_xgb <- data.frame(obs = hp_train_B_proc$price,
                                pred = hp_pred_baseline_xgb)

results_baseline_xgb <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_baseline_xgb)),
      'MAPE' = MAPE(y_pred = hp_pred_baseline_xgb, y_true = hp_train_B_proc$price),
      'Coefficients' = hp_fit_baseline_xgb$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_baseline_xgb, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_baseline_xgb)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_baseline_xgb)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_baseline_xgb)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Baseline XGBoost' = results_baseline_xgb)

# summary(hp_fit_baseline_xgb)

png(
  paste0('plots/', plot_counter, '. baseline_xgb_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_baseline_xgb), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_xgb_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_baseline_xgb)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_xgb_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_baseline_xgb)
dev.off()
plot_counter = plot_counter + 1

hp_pred_baseline_xgb_test <-
  predict(hp_fit_baseline_xgb, hp_test_proc)
submission_baseline_xgb <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_xgb_test * sd(hp_train_A$price) + mean(hp_train_A$price))
write.csv(submission_baseline_xgb,
          'submissions/baseline_xgb.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_baseline_xgb_train_B <-
  predict(hp_fit_baseline_xgb, hp_train_B_proc)
submission_baseline_xgb_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_xgb_train_B * sd(hp_train_A$price) + mean(hp_train_A$price))

real_results_baseline_xgb <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_baseline_xgb_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_baseline_xgb_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_baseline_xgb_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_baseline_xgb_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = hp_fit_baseline_xgb$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_baseline_xgb, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind(all_real_results, 'Baseline XGBoost' = real_results_baseline_xgb)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Baseline with XGBoost is done!'))
