####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')
# calculate <- TRUE
# plot_counter <- 26

set.seed(2019)

# Baseline with a Random Forest ----
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
  hp_fit_baseline_ranger <-
    train(
      price ~ .,
      data = hp_train_A_proc,
      method = 'ranger',
      trControl = fitControl,
      metric = 'MAE',
      importance = 'impurity',
      verbose = TRUE,
      num.thread = detectCores() - 1
    )
  time_fit_end <- Sys.time()
  # stopCluster(cl)
  time_fit_duration_baseline_ranger <- time_fit_end - time_fit_start
  saveRDS(hp_fit_baseline_ranger,
          'models/hp_fit_baseline_ranger.rds')
  saveRDS(
    time_fit_duration_baseline_ranger,
    'models/time_fit_duration_baseline_ranger.rds'
  )
}

hp_fit_baseline_ranger <-
  readRDS('models/hp_fit_baseline_ranger.rds')
time_fit_duration_baseline_ranger <-
  readRDS('models/time_fit_duration_baseline_ranger.rds')

residuals_baseline_ranger <- resid(hp_fit_baseline_ranger)
hp_pred_baseline_ranger <-
  predict(hp_fit_baseline_ranger, hp_train_B_proc)
comp_baseline_ranger <- data.frame(obs = hp_train_B_proc$price,
                                   pred = hp_pred_baseline_ranger)

results_baseline_ranger <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_baseline_ranger)),
      'MAPE' = MAPE(y_pred = hp_pred_baseline_ranger, y_true = hp_train_B_proc$price),
      'Coefficients' = length(hp_fit_baseline_ranger$finalModel$xNames),
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_ranger, units = 'mins'),
        1
      ),
      'CV | RMSE' = get_best_result(hp_fit_baseline_ranger)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_baseline_ranger)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_baseline_ranger)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Baseline Ranger' = results_baseline_ranger)

# summary(hp_fit_baseline_ranger)

png(
  paste0('plots/', plot_counter, '. baseline_ranger_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_baseline_ranger), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_ranger_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_baseline_ranger)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_ranger_parameters.png'),
  width = 1500,
  height = 1000
)
plot(hp_fit_baseline_ranger)
dev.off()
plot_counter = plot_counter + 1

hp_pred_baseline_ranger_test <-
  predict(hp_fit_baseline_ranger, hp_test_proc)
submission_baseline_ranger <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_ranger_test * sd(hp_train_A$price) + mean(hp_train_A$price))
write.csv(submission_baseline_ranger,
          'submissions/baseline_ranger.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_baseline_ranger_train_B <-
  predict(hp_fit_baseline_ranger, hp_train_B_proc)
submission_baseline_ranger_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_ranger_train_B * sd(hp_train_A$price) + mean(hp_train_A$price))

real_results_baseline_ranger <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_baseline_ranger_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_baseline_ranger_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_baseline_ranger_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_baseline_ranger_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = length(hp_fit_baseline_ranger$finalModel$xNames),
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_ranger, units = 'mins'),
        1
      )
    )
  )
all_real_results <-
  rbind(all_real_results, 'Baseline Ranger' = real_results_baseline_ranger)

print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Baseline with Ranger is done!'))
