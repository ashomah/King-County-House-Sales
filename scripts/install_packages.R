####
#### THIS SCRIPT CHECK IF NECESSARY PACKAGES ARE INSTALLED AND LOADED
####

packages_list <- c(
  'data.table',
  'dplyr',
  'tibble',
  'tidyr',
  'corrplot',
  'GGally',
  'ggmap',
  'ggplot2',
  'grid',
  'gridExtra',
  'caret',
  'dbscan',
  'glmnet',
  'leaderCluster',
  'MLmetrics',
  'ranger',
  'xgboost',
  'doMC',
  'doParallel',
  'factoextra',
  'foreach',
  'parallel',
  'kableExtra',
  'knitr',
  'RColorBrewer',
  'shiny',
  'beepr'
)

for (i in packages_list) {
  if (!i %in% installed.packages()) {
    install.packages(i, dependencies = TRUE)
    library(i, character.only = TRUE)
    print(paste0(i, ' has been installed'))
  } else {
    print(paste0(i, ' is already installed'))
    library(i, character.only = TRUE)
  }
}

# print(paste0(
#   '[',
#   round(difftime(Sys.time(), start_time, units = 'mins'), 1),
#   'm]: ',
#   'All necessary packages installed and loaded'
# ))
