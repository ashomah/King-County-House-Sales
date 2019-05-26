####
#### THIS SCRIPT FITS A MODEL AND MAKE PREDICTIONS
####

set.seed(2019)

# Baseline with a Linear Regression ----
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
  hp_fit_baseline_lm <- train(
    price ~ .,
    data = hp_train_A_proc,
    method = 'lm',
    trControl = fitControl,
    metric = 'MAE'
  )
  time_fit_end <- Sys.time()
  # stopCluster(cl)
  time_fit_duration_baseline_lm <- time_fit_end - time_fit_start
  saveRDS(hp_fit_baseline_lm, 'models/hp_fit_baseline_lm.rds')
  saveRDS(time_fit_duration_baseline_lm,
          'models/time_fit_duration_baseline_lm.rds')
}

hp_fit_baseline_lm <- readRDS('models/hp_fit_baseline_lm.rds')
time_fit_duration_baseline_lm <-
  readRDS('models/time_fit_duration_baseline_lm.rds')

residuals_baseline_lm <- resid(hp_fit_baseline_lm)
hp_pred_baseline_lm <-
  predict(hp_fit_baseline_lm, hp_train_B_proc)
comp_baseline_lm <- data.frame(obs = hp_train_B_proc$price,
                               pred = hp_pred_baseline_lm)

results_baseline_lm <-
  as.data.frame(
    cbind(
      rbind(defaultSummary(comp_baseline_lm)),
      'MAPE' = MAPE(y_pred = hp_pred_baseline_lm, y_true = hp_train_B_proc$price),
      'Coefficients' = length(hp_fit_baseline_lm$finalModel$coefficients),
      'Train Time (min)' = round(as.numeric(time_fit_duration_baseline_lm, units = 'mins'), 1),
      'CV | RMSE' = get_best_result(hp_fit_baseline_lm)[, 'RMSE'],
      'CV | Rsquared' = get_best_result(hp_fit_baseline_lm)[, 'Rsquared'],
      'CV | MAE' = get_best_result(hp_fit_baseline_lm)[, 'MAE']
    )
  )
all_results <- rbind('Baseline Lin. Reg.' = results_baseline_lm)

# summary(hp_fit_baseline_lm)

png(
  paste0('plots/', plot_counter, '. baseline_lm_varImp.png'),
  width = 1500,
  height = 1000
)
plot(varImp(hp_fit_baseline_lm), top = 30)
dev.off()
plot_counter = plot_counter + 1

png(
  paste0('plots/', plot_counter, '. baseline_lm_residuals.png'),
  width = 1500,
  height = 1000
)
plot_residuals(residuals_baseline_lm)
dev.off()
plot_counter = plot_counter + 1

hp_pred_baseline_lm_test <-
  predict(hp_fit_baseline_lm, hp_test_proc)
submission_baseline_lm <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_lm_test * sd(hp_train_A$price) + mean(hp_train_A$price))
write.csv(submission_baseline_lm,
          'submissions/baseline_lm.csv',
          row.names = FALSE)

# Results for unscaled and uncentered submission
hp_pred_baseline_lm_train_B <-
  predict(hp_fit_baseline_lm, hp_train_B_proc)
submission_baseline_lm_train_B <-
  cbind(#'id' = hp_test_id,
    'price' = hp_pred_baseline_lm_train_B * sd(hp_train_A$price) + mean(hp_train_A$price))

real_results_baseline_lm <-
  as.data.frame(
    cbind(
      'RMSE' = RMSE(y_pred = submission_baseline_lm_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Rsquared' = R2_Score(y_pred = submission_baseline_lm_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAE' = MAE(y_pred = submission_baseline_lm_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'MAPE' = MAPE(y_pred = submission_baseline_lm_train_B[, 'price'], y_true = hp_train_B[, 'price']),
      'Coefficients' = length(hp_fit_baseline_lm$finalModel$coefficients),
      'Train Time (min)' = round(as.numeric(time_fit_duration_baseline_lm, units = 'mins'), 1)
    )
  )
all_real_results <-
  rbind('Baseline Lin. Reg.' = real_results_baseline_lm)


print(paste0(
  '[',
  round(difftime(Sys.time(), start_time, units = 'mins'), 1),
  'm]: ',
  'Baseline with Linear Regression is done!'
))
