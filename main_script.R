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


print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'secs'), 1
), 's]: ',
'All operations are over!'))

# Render RMarkdown Report ----
if (is.null(webshot:::find_phantom())) {
  webshot::install_phantomjs()
}
invisible(rmarkdown::render('King-County-House-Sales-Report.Rmd', 'github_document'))
invisible(rmarkdown::render('King-County-House-Sales-Report.Rmd', 'html_document'))

print(paste0('[', round(
  difftime(Sys.time(), start_time, units = 'secs'), 1
), 's]: ',
'Report generated! ---END---'))
