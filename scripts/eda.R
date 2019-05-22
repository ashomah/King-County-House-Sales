####
#### THIS SCRIPT EXPLORES THE DATA AND GENERATE PLOTS
####

# Initialize plot counter ----
plot_counter = 1

# Generate Correlation Matrix ----
png(
  paste0('plots/', plot_counter, '. mixed_bubble_corr_matrix.png'),
  width = 1500,
  height = 1000
)
corrplot.mixed(cor(hp_train[, names(hp_train)[sapply(hp_train, is.numeric)]]), order = 'FPC')
dev.off()
plot_counter = plot_counter + 1

print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'secs'), 1),
    's]: ',
    'Mixed Bubble Correlation Matrix is generated and saved in /plots!'
  )
)


# Generate Pair Plots ----
png(
  paste0('plots/', plot_counter, '. ggpairs_corr_matrix.png'),
  width = 1500,
  height = 1000
)
print(ggpairs(hp_train[, names(hp_train)[sapply(hp_train, is.numeric)]],
              lower = list(
                continuous = wrap(
                  'points',
                  alpha = 0.3,
                  size = 0.1,
                  color = 'darkcyan'
                )
              )) +
        theme(panel.grid.major = element_blank()))
dev.off()
plot_counter = plot_counter + 1

print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'secs'), 1),
    's]: ',
    'GGpairs Correlation Matrix is generated and saved in /plots!'
  )
)


# Plots of factor features ----
for (feature in names(hp_train)[sapply(hp_train, is.factor)]) {
  png(
    paste0('plots/', plot_counter, '. eda_', feature, '.png'),
    width = 1500,
    height = 1000
  )
  
  g1 <- ggplot(hp_train,
               aes(x = hp_train[, feature])) +
    geom_bar(color = 'darkcyan', fill = 'darkcyan') +
    theme_minimal() +
    theme(
      legend.position = 'none',
      plot.title = element_text(
        hjust = 0.5,
        size = 12,
        face = 'bold'
      )
    ) +
    labs(x = '',
         y = 'Count',
         title = paste0(toupper(substr(feature, 1, 1)), tolower(substr(
           feature, 2, nchar(feature)
         ))))
  
  g2 <- ggplot(hp_train,
               aes(x = hp_train[, feature], y = log(price))) +
    geom_boxplot(color = 'darkcyan') +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = '', y = 'House Price')
  
  grobs <- list()
  grobs[[1]] <- g1
  grobs[[2]] <- g2
  grid.arrange(grobs = grobs)
  dev.off()
  plot_counter = plot_counter + 1
}

print(paste0(
  '[',
  round(difftime(Sys.time(), start_time, units = 'secs'), 1),
  's]: ',
  'Plots for Factor Features are generated and saved in /plots!'
))


# Plots of numerical features ----
for (feature in names(hp_train)[sapply(hp_train, is.numeric)]) {
  png(
    paste0('plots/', plot_counter, '. eda_', feature, '.png'),
    width = 1500,
    height = 1000
  )
  
  g1 <- ggplot(hp_train,
               aes(x = hp_train[, feature])) +
    geom_density(color = 'darkcyan', fill = 'darkcyan') +
    theme_minimal() +
    theme(
      legend.position = 'none',
      plot.title = element_text(
        hjust = 0.5,
        size = 12,
        face = 'bold'
      )
    ) +
    labs(x = '',
         y = 'Count',
         title = paste0(toupper(substr(feature, 1, 1)), tolower(substr(
           feature, 2, nchar(feature)
         ))))
  
  g2 <- ggplot(hp_train,
               aes(x = hp_train[, feature], y = price)) +
    geom_point(color = 'darkcyan', size = 0.5) +
    theme_minimal() +
    theme(legend.position = 'none') +
    labs(x = '', y = 'House Price')
  
  grobs <- list()
  grobs[[1]] <- g1
  grobs[[2]] <- g2
  grid.arrange(grobs = grobs)
  dev.off()
  plot_counter = plot_counter + 1
}

print(
  paste0(
    '[',
    round(difftime(Sys.time(), start_time, units = 'secs'), 1),
    's]: ',
    'Plots for Numericals Features are generated and saved in /plots!'
  )
)
