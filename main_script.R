####
#### THIS SCRIPT CALLS ALL SUB-SCRIPTS TO READ AND PREPARE THE DATASET,
#### RUN THE ANALYSIS AND OUTPUT RELEVANT DATA FILES
####

start_time <- Sys.time()
print(paste0('---START--- Starting at ', start_time))

options(warn = -1)

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

# Baseline Linear Regression with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_lm_log.R')

# Baseline Linear Regression All Fact ----
calculate <- FALSE
source('scripts/model_baseline_lm_all_fact.R')

# Baseline Linear Regression All Fact with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_lm_log_all_fact.R')

# Baseline Random Forest ----
calculate <- FALSE
source('scripts/model_baseline_ranger.R')

# Baseline Random Forest with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_ranger_log.R')

# Baseline Random Forest All Fact ----
calculate <- FALSE
source('scripts/model_baseline_ranger_all_fact.R')

# Baseline Random Forest All Fact with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_ranger_log_all_fact.R')

# Baseline XGBoost ----
calculate <- FALSE
source('scripts/model_baseline_xgb.R')

# Baseline XGBoost with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_xgb_log.R')

# Baseline XGBoost All Fact ----
calculate <- FALSE
source('scripts/model_baseline_xgb_all_fact.R')

# Baseline XGBoost All Fact with log10(price) ----
calculate <- FALSE
source('scripts/model_baseline_xgb_log_all_fact.R')

# Feature Engineering Renovation ----
source('scripts/feateng_renovation.R')

# Feature Engineering Clusters ----
source('scripts/feateng_clusters.R')

# Feature Selection Lasso ----
source('scripts/featsel_lasso.R')


# Save RData for RMarkdown ----
save(
  list = c(
    'raw_hp_train',
    'raw_hp_test',
    'hp_train',
    'hp_test',
    'hp_train_A',
    'hp_train_A_FE2',
    'hp_train_B',
    'long_lat',
    'houses_sold_multi_times_train',
    'houses_train',
    'houses_sold_multi_times_test',
    'houses_test',
    'all_results',
    'all_real_results',
    'varsSelected',
    'varsNotSelected',
    'dbscan_clusters_train_A',
    'dbscan_clusters_train_B',
    'cluster_plot_A',
    'cluster_plot_B',
    'hp_fit_baseline_xgb_log_all_fact',
    'hp_fit_baseline_ranger_log',
    'hp_fit_xgb_FE',
    'hp_fit_baseline_ranger_log_all_fact'
  ),
  file = 'data_output/RMarkdown_Objects.RData'
)

save.image(file = 'data_output/ALL.RData')

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'All operations are over!'))

# Render RMarkdown Report ----
if (is.null(webshot:::find_phantom())) {
  webshot::install_phantomjs()
}
invisible(
  rmarkdown::render(
    'King-County-House-Sales-Report.Rmd',
    'github_document',
    params = list(shiny = FALSE),
    runtime = 'static'
  )
)
invisible(
  rmarkdown::render(
    'King-County-House-Sales-Report.Rmd',
    'html_document',
    params = list(shiny = FALSE)
  )
)
# )
# invisible(
#   rmarkdown::run(
#     'King-County-House-Sales-Report.Rmd'
#   )
# )

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'mins'), 1
), 'm]: ',
'Report generated! ---END---'))
