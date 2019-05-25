####
#### THIS SCRIPT ADD NEW FEATURES TO THE DATASETS
####


# Add House Age ---- 
hp_train_A_FE1 <- hp_train_A_all_fact
hp_train_B_FE1 <- hp_train_B_all_fact
hp_test_FE1 <- hp_test
hp_train_A_FE1$house_age <- 2015 - hp_train_A$yr_built
hp_train_B_FE1$house_age <- 2015 - hp_train_B$yr_built
hp_test_FE1$house_age <- 2015 - hp_test$yr_built


# Add House Age since last Renovation ----
hp_train_A_FE1$house_age_since_renovation <- hp_train_A_FE1$house_age
hp_train_B_FE1$house_age_since_renovation <- hp_train_B_FE1$house_age
hp_test_FE1$house_age_since_renovation <- hp_test_FE1$house_age
hp_train_A_FE1$house_age_since_renovation[hp_train_A_FE1$yr_renovated != 0] <- 2015 - hp_train_A_FE1$yr_renovated[hp_train_A_FE1$yr_renovated != 0]
hp_train_B_FE1$house_age_since_renovation[hp_train_B_FE1$yr_renovated != 0] <- 2015 - hp_train_B_FE1$yr_renovated[hp_train_B_FE1$yr_renovated != 0]
hp_test_FE1$house_age_since_renovation[hp_test_FE1$yr_renovated != 0] <- 2015 - hp_test_FE1$yr_renovated[hp_test_FE1$yr_renovated != 0]


# Add Renovated Flag ----
hp_train_A_FE1$renovated <- 0
hp_train_B_FE1$renovated <- 0
hp_test_FE1$renovated <- 0
hp_train_A_FE1$renovated[hp_train_A_FE1$yr_renovated != 0] <- 1
hp_train_B_FE1$renovated[hp_train_B_FE1$yr_renovated != 0] <- 1
hp_test_FE1$renovated[hp_test_FE1$yr_renovated != 0] <- 1
hp_train_A_FE1$renovated <- as.factor(hp_train_A_FE1$renovated)
hp_train_B_FE1$renovated <- as.factor(hp_train_B_FE1$renovated)
hp_test_FE1$renovated <- as.factor(hp_test_FE1$renovated)


# Log, Fact, Scale and Center ----
hp_train_A_FE1$bathrooms <- as.factor(hp_train_A_FE1$bathrooms)
hp_train_A_FE1$zipcode <- as.factor(hp_train_A_FE1$zipcode)
hp_train_B_FE1$bathrooms <- as.factor(hp_train_B_FE1$bathrooms)
hp_train_B_FE1$zipcode <- as.factor(hp_train_B_FE1$zipcode)
hp_test_FE1$bathrooms <- as.factor(hp_test_FE1$bathrooms)
hp_test_FE1$zipcode <- as.factor(hp_test_FE1$zipcode)

hp_train_A_FE1$price <- log10(hp_train_A_FE1$price)
hp_train_B_FE1$price <- log10(hp_train_B_FE1$price)

preProcValues <-
  preProcess(hp_train_A_FE1, method = c("center", "scale"))
hp_train_A_FE1 <- predict(preProcValues, hp_train_A_FE1)
hp_train_B_FE1 <- predict(preProcValues, hp_train_B_FE1)
hp_test_FE1 <- predict(preProcValues, hp_test_FE1)


print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Age and Renovation Generated!'))








