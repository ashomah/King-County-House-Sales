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


# Read and Transform Dataset Done ----
# print(paste0('[', round(
#   difftime(Sys.time(), start_time, units = 'secs'), 1
# ), 's]: ',
# 'Working dataset ready!'))
