####
#### THIS SCRIPT CALLS ALL SUB-SCRIPTS TO READ AND PREPARE THE DATASET,
#### RUN THE ANALYSIS AND OUTPUT RELEVANT DATA FILES
####

start_time <- Sys.time()
print(paste0('---START--- Starting at ', start_time))

# Install Necessary Packages ----
source('scripts/install_packages.R')

# Read and Prepare Dataset ----
source('scripts/read_dataset.R')

# Get Map Background ----
source('scripts/map_background.R')

# Exploratory Data Analysis ----
source('scripts/eda.R')

# Parameters of Baseline ----
source('scripts/param_baseline.R')

# Baseline Linear Regression ----
calculate <- FALSE
source('scripts/model_baseline_lm.R')

# Baseline Linear Regression All Fact----
calculate <- FALSE
source('scripts/model_baseline_lm_all_fact.R')

# Baseline Random Forest ----
calculate <- FALSE
source('scripts/model_baseline_ranger.R')

# Baseline Random Forest All Fact ----
calculate <- FALSE
source('scripts/model_baseline_ranger_all_fact.R')

# Baseline XGBoost ----
calculate <- FALSE
source('scripts/model_baseline_xgb.R')

# Baseline XGBoost All Fact ----
calculate <- FALSE
source('scripts/model_baseline_xgb_all_fact.R')

# Feature Selection Lasso ----
source('scripts/featsel_lasso.R')


# Save RData for RMarkdown ----
save(
  list = c(
    'hp_train',
    'hp_test',
    'long_lat',
    'houses_sold_multi_times_train',
    'houses_train',
    'houses_sold_multi_times_test',
    'houses_test',
    'all_results',
    'varsSelected',
    'varsNotSelected'
  ),
  file = 'data_output/RMarkdown_Objects.RData'
)

save.image(file = 'data_output/ALL.RData')

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'All operations are over!'))

# # Render RMarkdown Report ----
# if (is.null(webshot:::find_phantom())) {
#   webshot::install_phantomjs()
# }
# invisible(
#   rmarkdown::render(
#     'King-County-House-Sales-Report.Rmd',
#     'github_document',
#     params = list(shiny = FALSE),
#     runtime = 'static'
#   )
# )
# invisible(
#   rmarkdown::render(
#     'King-County-House-Sales-Report.Rmd',
#     'html_document',
#     params = list(shiny = FALSE)
#   )
# )
# invisible(
#   rmarkdown::run(
#     'King-County-House-Sales-Report.Rmd'
#   )
# )
# 
# print(paste0('[', round(
#   difftime(Sys.time(), start_time, units = 'mins'), 1
# ), 'm]: ',
# 'Report generated! ---END---'))
