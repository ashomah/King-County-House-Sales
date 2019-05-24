####
#### THIS SCRIPT LOADS AND TRANSFORMS THE DATASET
####

# Loading Train Set ----
raw_hp_train <-
  read.csv('data_input/house_price_train.csv',
           sep = ',',
           stringsAsFactors = FALSE)
hp_train <- raw_hp_train

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'Train Set imported'))


# Loading Test Set ----
raw_hp_test <-
  read.csv('data_input/house_price_test.csv',
           sep = ',',
           stringsAsFactors = FALSE)
hp_test <- raw_hp_test

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'Test Set imported'))


# Check if contains NAs ----
na_count <-
  sapply(hp_train, function(y)
    sum(length(which(is.na(
      y
    )))))
na_count <- data.frame(na_count)
na_count$perc <- round(na_count$na_count / nrow(hp_train) * 100, 2)
print(paste0(nrow(na_count[na_count$na_count != 0, ]), ' columns of the Train Set have NAs.'))

na_count <-
  sapply(hp_test, function(y)
    sum(length(which(is.na(
      y
    )))))
na_count <- data.frame(na_count)
na_count$perc <- round(na_count$na_count / nrow(hp_test) * 100, 2)
print(paste0(nrow(na_count[na_count$na_count != 0, ]), ' columns of the Test Set have NAs.'))


# Check if house IDs are relevant ----
houses_sold_multi_times_train <-
  length(names(table(hp_train$id)[table(hp_train$id) > 1]))
houses_train <- length(unique(hp_train$id))
print(
  paste0(
    houses_sold_multi_times_train,
    ' houses sold more than once on the period, for a total of ',
    houses_train,
    ' houses in the Train Set (',
    round(houses_sold_multi_times_train / houses_train, 3),
    '%).'
  )
)

houses_sold_multi_times_test <-
  length(names(table(hp_test$id)[table(hp_test$id) > 1]))
houses_test <- length(unique(hp_test$id))
print(
  paste0(
    houses_sold_multi_times_test,
    ' houses in the Test Set sold more than once on the period, for a total of ',
    houses_test,
    ' houses in the Test Set (',
    round(houses_sold_multi_times_test / houses_test, 3),
    '%).'
  )
)


# Drop id and date columnes ----
hp_train_id <- hp_train$id
hp_test_id <- hp_test$id
hp_train$id <- NULL
hp_train$date <- NULL
hp_test$id <- NULL
hp_test$date <- NULL


# Add price to hp_test ----
hp_test$price <- NA


# Set features as factors ----
hp_train$waterfront <- as.factor(hp_train$waterfront)
hp_train$view <- as.factor(hp_train$view)
hp_train$condition <- as.factor(hp_train$condition)
hp_train$grade <- as.factor(hp_train$grade)
hp_train$bedrooms <- as.factor(hp_train$bedrooms)
# hp_train$bathrooms <- as.factor(hp_train$bathrooms)
hp_train$floors <- as.factor(hp_train$floors)
# hp_train$zipcode <- as.factor(hp_train$zipcode)
hp_test$waterfront <- as.factor(hp_test$waterfront)
hp_test$view <- as.factor(hp_test$view)
hp_test$condition <- as.factor(hp_test$condition)
hp_test$grade <- as.factor(hp_test$grade)
hp_test$bedrooms <- as.factor(hp_test$bedrooms)
# hp_test$bathrooms <- as.factor(hp_test$bathrooms)
hp_test$floors <- as.factor(hp_test$floors)
# hp_test$zipcode <- as.factor(hp_test$zipcode)


# Read and Transform Dataset Done ----
print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'Working dataset ready!'))
