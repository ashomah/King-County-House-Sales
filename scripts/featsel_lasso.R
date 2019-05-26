####
#### THIS SCRIPT SELECTS FEATURE USING A LASSO REGRESSION
####

# One-Hot Encode to pass the 53 levels limitation of rfe ----
dummies_model <- dummyVars(price ~ ., data = hp_train_A_FE2)
hp_train_A_FE2_ohe <-
  predict(dummies_model, newdata = hp_train_A_FE2)
hp_train_A_FE2_ohe <-
  cbind(data.frame(hp_train_A_FE2_ohe), 'price' = hp_train_A_FE2$price)
hp_train_B_FE2_ohe <-
  predict(dummies_model, newdata = hp_train_B_FE2)
hp_train_B_FE2_ohe <-
  cbind(data.frame(hp_train_B_FE2_ohe), 'price' = hp_train_B_FE2$price)
hp_test_FE2_ohe <- predict(dummies_model, newdata = hp_test_FE2)
hp_test_FE2_ohe <-
  cbind(data.frame(hp_test_FE2_ohe), 'price' = hp_test_FE2$price)


# Feature Selection with Lasso Regression ----
X <- model.matrix(price ~ ., hp_train_A_FE2_ohe)[,-1]
y <- hp_train_A_FE2_ohe$price
cv <- cv.glmnet(X, y, alpha = 1)
lasso_glmnet <- glmnet(X, y, alpha = 1, lambda = cv$lambda.min)
coef(lasso_glmnet)

lassoVarImp <-
  varImp(lasso_glmnet, scale = FALSE, lambda = cv$lambda.min)

varsSelected    <-
  rownames(lassoVarImp)[which(lassoVarImp$Overall != 0)]
varsNotSelected <-
  rownames(lassoVarImp)[which(lassoVarImp$Overall == 0)]

print(
  paste0(
    'The Lasso Regression selected ',
    length(varsSelected),
    ' variables, and rejected ',
    length(varsNotSelected),
    ' variables.'
  )
)

hp_train_A_FE2_lasso <-
  hp_train_A_FE2_ohe[,!names(hp_train_A_FE2_ohe) %in% varsNotSelected]
hp_train_B_FE2_lasso <-
  hp_train_B_FE2_ohe[,!names(hp_train_B_FE2_ohe) %in% varsNotSelected]
hp_test_FE2_lasso <-
  hp_test_FE2_ohe[,!names(hp_test_FE2_ohe) %in% varsNotSelected]

print(paste0(
  '[',
  round(difftime(Sys.time(), start_time, units = 'mins'), 1),
  'm]: ',
  'Feature Selection with Lasso Regression is done!'
))
