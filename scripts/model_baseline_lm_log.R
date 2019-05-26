####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

set.seed(2019)

# Baseline with a Linear Regression with log10(price) ----
if (calculate == TRUE) {
  # cl <- makePSOCKcluster(2)
  # registerDoParallel(cl, cores = detectCores() - 1)
  print(paste0('[',
               round(
                 difftime(Sys.time(), start_time, units = 'mins'), 1
               ),
               'm]: ',
               'Starting Model Fit...'))
  time_fit_start <- Sys.time()
  hp_fit_baseline_lm_log <- train(
    price ~ .,
    data = hp_train_A_log_proc,
    method = 'lm',
    trControl = fitControl,
    metric = 'MAE'
  )
  time_fit_end <- Sys.time()
  # stopCluster(cl)
  time_fit_duration_baseline_lm_log <- time_fit_end - time_fit_start
  saveRDS(hp_fit_baseline_lm_log,
          'models/hp_fit_baseline_lm_log.rds')
  saveRDS(
    time_fit_duration_baseline_lm_log,
    'models/time_fit_duration_baseline_lm_log.rds'
  )
}

hp_fit_baseline_lm_log <-
  readRDS('models/hp_fit_baseline_lm_log.rds')
time_fit_duration_baseline_lm_log <-
  readRDS('models/time_fit_duration_baseline_lm_log.rds')

residuals_baseline_lm_log <- resid(hp_fit_baseline_lm_log)
hp_pred_baseline_lm_log <-
  predict(hp_fit_baseline_lm_log, hp_train_B_log_proc)
comp_baseline_lm_log <- data.frame(obs = hp_train_B_log_proc$price,
                                   pred = hp_pred_baseline_lm_log)

results_baseline_lm_log <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_baseline_lm_log)),
      'MAPE' = MAPE(y_pred = hp_pred_baseline_lm_log, y_true = hp_train_B_log_proc$price),
      'Coefficients' = length(hp_fit_baseline_lm_log$finalModel$coefficients),
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_lm_log, units = 'mins'),
        1
      ),
      'CV | RMSE' = get_best_result(hp_fit_baseline_lm_log)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_baseline_lm_log)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_baseline_lm_log)[, 'MAE']
    )
  )
all_results <-
  rbind(all_results, 'Baseline Lin. Reg. Log' = results_baseline_lm_log)

# summary(hp_fit_baseline_lm_log)

png(
  paste0('plots/', plot_counter, '. baseline_lm_log_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_baseline_lm_log), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_lm_log_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_baseline_lm_log)
dev.off()
plot_counter = plot_counter + 1

hp_pred_baseline_lm_log_test <-
  predict(hp_fit_baseline_lm_log, hp_test_log_proc)
submission_baseline_lm_log <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_baseline_lm_log_test * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))
write.csv(submission_baseline_lm_log,
          'submissions/baseline_lm_log.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_baseline_lm_log_train_B <-
  predict(hp_fit_baseline_lm_log, hp_train_B_log_proc)
submission_baseline_lm_log_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = 10 ^ (
      hp_pred_baseline_lm_log_train_B * sd(hp_train_A_log$price) + mean(hp_train_A_log$price)
    ))

real_results_baseline_lm_log <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_baseline_lm_log_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_baseline_lm_log_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_baseline_lm_log_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_baseline_lm_log_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = length(hp_fit_baseline_lm_log$finalModel$coefficients),
      'Train Time (min)' = round(
        as.numeric(time_fit_duration_baseline_lm_log, units = 'mins'),
        1
      )
    )
  )
all_real_results <-
  rbind(all_real_results, 'Baseline Lin. Reg. Log' = real_results_baseline_lm_log)


print(paste0(
  '[',
  round(difftime(Sys.time(), start_time, units = 'mins'), 1),
  'm]: ',
  'Baseline with Linear Regression Log is done!'
))
