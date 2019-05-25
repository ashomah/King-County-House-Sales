####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 32

set.seed(2019)

# FeatEng Clusters  with a eXtreme Gradient BOOSTing ----
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
  hp_fit_xgb_clusters <-
    train(
      price ~ .,
      data = hp_train_A_clusters_proc,
      method = 'xgbTree',
      trControl = fitControl,
      metric = 'MAE',
      nthread = 1#detectCores()-1
    )
  time_fit_end <- Sys.time()
  stopCluster(cl)
  time_fit_duration_xgb_clusters <- time_fit_end - time_fit_start
  saveRDS(hp_fit_xgb_clusters, 'models/hp_fit_xgb_clusters.rds')
  saveRDS(time_fit_duration_xgb_clusters,
          'models/time_fit_duration_xgb_clusters.rds')
}

hp_fit_xgb_clusters <- readRDS('models/hp_fit_xgb_clusters.rds')
time_fit_duration_xgb_clusters <-
  readRDS('models/time_fit_duration_xgb_clusters.rds')

residuals_xgb_clusters <- resid(hp_fit_xgb_clusters)
hp_pred_xgb_clusters <-
  predict(hp_fit_xgb_clusters, hp_train_B_clusters_proc)
comp_xgb_clusters <- data.frame(obs = hp_train_B_clusters_proc$price,
                                pred = hp_pred_xgb_clusters)

results_xgb_clusters <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_xgb_clusters)),
      'MAPE' = MAPE(y_pred = hp_pred_xgb_clusters, y_true = hp_train_B_clusters_proc$price),
      'Coefficients' = hp_fit_xgb_clusters$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_clusters, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_xgb_clusters)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_xgb_clusters)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_xgb_clusters)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Baseline XGBoost Clusters Fact' = results_xgb_clusters)

# summary(hp_fit_xgb)

png(
  paste0('plots/', plot_counter, '. baseline_xgb_clusters_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_xgb_clusters), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_xgb_clusters_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_xgb_clusters)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_xgb_clusters_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_xgb_clusters)
dev.off()
plot_counter = plot_counter + 1

hp_pred_xgb_clusters_test <-
  predict(hp_fit_xgb_clusters, hp_test_clusters_proc)
submission_xgb_clusters <-
  cbind('id' = hp_test_id,
        'price' = hp_pred_xgb_clusters_test * sd(hp_train_A$price) + mean(hp_train_A$price))
write.csv(submission_xgb_clusters,
          'submissions/baseline_xgb_clusters.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_xgb_clusters_train_B <-
  predict(hp_fit_xgb_clusters, hp_train_B_clusters_proc)
submission_xgb_clusters_train_B <-
  cbind('id' = hp_test_id,
        'price' = hp_pred_xgb_clusters_train_B * sd(hp_train_A$price) + mean(hp_train_A$price))

real_results_xgb_clusters <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_xgb_clusters_train_B[,'price'], y_true = hp_train_B[,'price']),
      'Rsquared' = R2_Score(y_pred = submission_xgb_clusters_train_B[,'price'], y_true = hp_train_B[,'price']),
      'MAE' = MAE(y_pred = submission_xgb_clusters_train_B[,'price'], y_true = hp_train_B[,'price']),
      'MAPE' = MAPE(y_pred = submission_xgb_clusters_train_B[,'price'], y_true = hp_train_B[,'price']),
      'Coefficients' = hp_fit_xgb_clusters$finalModel$nfeatures,
      'Train Time (min)' = round(as.numeric(time_fit_duration_xgb_clusters, units = 'mins'), 1)
    )
  )
all_real_results <- rbind(all_real_results, 'FE XGBoost Clusters' = real_results_xgb_clusters)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'FE with XGBoost Clusters is done!'))
