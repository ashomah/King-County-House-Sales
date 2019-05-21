####
#### THIS SCRIPT LOADS AND TRANSFORMS THE DATASET
####


# Loading Train Set ----
hp_train <-
  read.csv('data_input/house_price_train.csv',
           sep = ',',
           stringsAsFactors = FALSE)

# print(paste0('[', round(
#   difftime(Sys.time(), start_time, units = 'secs'), 1
# ), 's]: ',
# 'Train Set imported'))


# Loading Test Set ----
hp_test <-
  read.csv('data_input/house_price_test.csv',
           sep = ',',
           stringsAsFactors = FALSE)

# print(paste0('[', round(
#   difftime(Sys.time(), start_time, units = 'secs'), 1
# ), 's]: ',
# 'Test Set imported'))


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
print(
  paste0(
    length(names(table(hp_train$id)[table(hp_train$id) > 1])),
    ' houses sold more than once on the period, for a total of ',
    length(unique(hp_train$id)),
    ' houses in the Train Set (',
    round(length(names(
      table(hp_train$id)[table(hp_train$id) > 1]
    )) / length(unique(hp_train$id)), 3),
    '%).'
  )
)

print(
  paste0(
    length(names(table(hp_test$id)[table(hp_test$id) > 1])),
    ' houses in the Test Set sold more than once on the period, for a total of ',
    length(unique(hp_test$id)),
    ' houses in the Test Set (',
    round(length(names(table(
      hp_test$id
    )[table(hp_test$id) > 1])) / length(unique(hp_test$id)), 3),
    '%).'
  )
)


# Drop id and date columnes ----
hp_train$id <- NULL
hp_train$date <- NULL
hp_test$id <- NULL
hp_test$date <- NULL


# Set features as factors
hp_train$waterfront <- as.factor(hp_train$waterfront)
hp_train$view <- as.factor(hp_train$view)
hp_train$condition <- as.factor(hp_train$condition)
hp_train$grade <- as.factor(hp_train$grade)
hp_test$waterfront <- as.factor(hp_test$waterfront)
hp_test$view <- as.factor(hp_test$view)
hp_test$condition <- as.factor(hp_test$condition)
hp_test$grade <- as.factor(hp_test$grade)



# Save RData for RMarkdown ----
save(list = c('hp_train',
              'hp_test',
              'long_lat'),
     file = 'data_output/RMarkdown_Objects.RData')


# Read and Transform Dataset Done ----
# print(paste0('[', round(
#   difftime(Sys.time(), start_time, units = 'secs'), 1
# ), 's]: ',
# 'Working dataset ready!'))
