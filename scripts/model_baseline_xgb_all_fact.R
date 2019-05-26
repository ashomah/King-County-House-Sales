####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 35

set.seed(2019)

# Baseline with a eXtreme Gradient BOOSTing All Fact ----
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
  hp_fit_baseline_xgb_all_fact <-
    train(
      price ~ .,
      data = hp_train_A_proc_all_fact,
      method = 'xgbTree',
      trControl = fitControl,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_baseline_xgb_all_fact <-
    time_fit_end - time_fit_start
  saveRDS(hp_fit_baseline_xgb_all_fact,
          'models/hp_fit_baseline_xgb_all_fact.rds')
  saveRDS(
    time_fit_duration_baseline_xgb_all_fact,
    'models/time_fit_duration_baseline_xgb_all_fact.rds'
  )
}

hp_fit_baseline_xgb_all_fact <-
  readRDS('models/hp_fit_baseline_xgb_all_fact.rds')
time_fit_duration_baseline_xgb_all_fact <-
  readRDS('models/time_fit_duration_baseline_xgb_all_fact.rds')

residuals_baseline_xgb_all_fact <-
  resid(hp_fit_baseline_xgb_all_fact)
hp_pred_baseline_xgb_all_fact <-
  predict(hp_fit_baseline_xgb_all_fact, hp_train_B_proc_all_fact)
comp_baseline_xgb_all_fact <-
  data.frame(obs = hp_train_B_proc_all_fact$price,
             pred = hp_pred_baseline_xgb_all_fact)

results_baseline_xgb_all_fact <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_baseline_xgb_all_fact)),
      'MAPE' = MAPE(y_pred = hp_pred_baseline_xgb_all_fact, y_true = hp_train_B_proc_all_fact$price),
      'Coefficients' = hp_fit_baseline_xgb_all_fact$finalModel$nfeatures,
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_xgb_all_fact, units = 'mins'),
        1
      ),
      'CV | RMSE' = get_best_result(hp_fit_baseline_xgb_all_fact)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_baseline_xgb_all_fact)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_baseline_xgb_all_fact)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Baseline XGBoost All Fact' = results_baseline_xgb_all_fact)

# summary(hp_fit_baseline_xgb_all_fact)

png(
  paste0('plots/', plot_counter, '. baseline_xgb_all_fact_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_baseline_xgb_all_fact), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0(
    'plots/',
    plot_counter,
    '. baseline_xgb_all_fact_residuals.png'
  ),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_baseline_xgb_all_fact)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0(
    'plots/',
    plot_counter,
    '. baseline_xgb_all_fact_parameters.png'
  ),
  width = 1500,
  height = 1000
)
plot(hp_fit_baseline_xgb_all_fact)
dev.off()
plot_counter = plot_counter + 1

hp_pred_baseline_xgb_all_fact_test <-
  predict(hp_fit_baseline_xgb_all_fact, hp_test_proc_all_fact)
submission_baseline_xgb_all_fact <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_xgb_all_fact_test * sd(hp_train_A$price) + mean(hp_train_A$price))
write.csv(
  submission_baseline_xgb_all_fact,
  'submissions/baseline_xgb_all_fact.csv',
  row.names = FALSE
)

# Results for unscaled and uncentered submission
hp_pred_baseline_xgb_all_fact_train_B <-
  predict(hp_fit_baseline_xgb_all_fact, hp_train_B_proc_all_fact)
submission_baseline_xgb_all_fact_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_xgb_all_fact_train_B * sd(hp_train_A$price) + mean(hp_train_A$price))

real_results_baseline_xgb_all_fact <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_baseline_xgb_all_fact_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_baseline_xgb_all_fact_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_baseline_xgb_all_fact_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_baseline_xgb_all_fact_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = hp_fit_baseline_xgb_all_fact$finalModel$nfeatures,
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_xgb_all_fact, units = 'mins'),
        1
      )
    )
  )
all_real_results <-
  rbind(all_real_results, 'Baseline XGBoost All Fact' = real_results_baseline_xgb_all_fact)

print(paste0(
  '[',
  round(difftime(Sys.time(), start_time, units = 'mins'), 1),
  'm]: ',
  'Baseline with XGBoost All Fact is done!'
))
