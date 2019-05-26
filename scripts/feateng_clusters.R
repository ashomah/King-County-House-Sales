####
#### THIS SCRIPT IDENTIFIES CLUSTERS BASED ON LOCATIONS AND A RADIUS PARAMETER
####

# source('scripts/install_packages.R')
# load(file = 'data_output/ALL.RData')

set.seed(2019)

# Clustering using density with DBSCAN ----
dbscan_clusters_train_A <-
  dbscan::dbscan(x = hp_train_A[, c('long', 'lat')], eps = 0.0114, minPts = 50)

png(paste0('plots/clusters.png'),
    width = 1500,
    height = 1000)
fviz_cluster(
  dbscan_clusters_train_A,
  hp_train_A[, c('long', 'lat')],
  stand = FALSE,
  frame = FALSE,
  geom = "point",
  pointsize = 0.5
)
dev.off()


# Predict clusters for other datasets ----
dbscan_clusters_train_B <-
  predict(dbscan_clusters_train_A,
          newdata = hp_train_B[, c('long', 'lat')],
          data = hp_train_A[, c('long', 'lat')])
dbscan_clusters_test <-
  predict(dbscan_clusters_train_A,
          newdata = hp_test[, c('long', 'lat')],
          data = hp_train_A[, c('long', 'lat')])


# Add Clusters to Datasets ----
hp_train_A_FE2 <-
  cbind(hp_train_A_FE1, 'cluster' = as.factor(dbscan_clusters_train_A$cluster))
hp_train_B_FE2 <-
  cbind(hp_train_B_FE1, 'cluster' = as.factor(dbscan_clusters_train_B))
hp_test_FE2 <-
  cbind(hp_test_FE1, 'cluster' = as.factor(dbscan_clusters_test))


# Clusters Map ----
load('data_output/hp_map_10_terrain.rda')

cluster_plot_A <-
  cbind(hp_train_A, 'cluster' = as.factor(dbscan_clusters_train_A$cluster))
cluster_plot_A$cluster[cluster_plot_A$cluster == 0] <- NA
cluster_plot_B <-
  cbind(hp_train_B, 'cluster' = as.factor(dbscan_clusters_train_B))
cluster_plot_B$cluster[cluster_plot_B$cluster == 0] <- NA
cluster_plot_test <-
  cbind(hp_test, 'cluster' = as.factor(dbscan_clusters_test))
cluster_plot_test$cluster[cluster_plot_test$cluster == 0] <- NA

png(paste0('plots/clusters_map_train_A.png'),
    width = 1500,
    height = 1000)
ggmap(hp_map_10_terrain) +
  labs(x = '', y = '') +
  theme(legend.position = 'none') +
  scale_colour_hue(h.start = 10,
                   c = 120,
                   na.value = 'grey') +
  geom_point(data = cluster_plot_A,
             aes(x = long, y = lat, colour = cluster),
             size = 2) +
  stat_density2d(
    data = hp_train_A,
    aes(x = long, y = lat),
    contour = TRUE,
    geom = 'density_2d',
    bins = 15,
    color = 'black',
    size = 0.6,
    alpha = 0.7
  )
# geom_point(data = hp_train_A, aes(x = long, y = lat, colour = zipcode), size = 2) +
# geom_point(data = clusters_2.0, aes(x = cluster_lon, y = cluster_lat), size = 0.5, colour = 'green')
dev.off()

png(paste0('plots/clusters_map_train_B.png'),
    width = 1500,
    height = 1000)
ggmap(hp_map_10_terrain) +
  labs(x = '', y = '') +
  theme(legend.position = 'none') +
  scale_colour_hue(h.start = 10,
                   c = 120,
                   na.value = 'grey') +
  geom_point(data = cluster_plot_B,
             aes(x = long, y = lat, colour = cluster),
             size = 2) +
  stat_density2d(
    data = hp_train_A,
    aes(x = long, y = lat),
    contour = TRUE,
    geom = 'density_2d',
    bins = 15,
    color = 'black',
    size = 0.6,
    alpha = 0.7
  )
# geom_point(data = hp_train_A, aes(x = long, y = lat, colour = zipcode), size = 2) +
# geom_point(data = clusters_2.0, aes(x = cluster_lon, y = cluster_lat), size = 0.5, colour = 'green')
dev.off()


# Additional datasets with clusters ----

hp_train_A_clusters <-
  cbind(hp_train_A, 'cluster' = dbscan_clusters_train_A$cluster)
hp_train_B_clusters <-
  cbind(hp_train_B, 'cluster' = dbscan_clusters_train_B)
hp_test_clusters <- cbind(hp_test, 'cluster' = dbscan_clusters_test)

preProcValues <-
  preProcess(hp_train_A_clusters, method = c("center", "scale"))
hp_train_A_clusters_proc <-
  predict(preProcValues, hp_train_A_clusters)
hp_train_B_clusters_proc <-
  predict(preProcValues, hp_train_B_clusters)
hp_test_clusters_proc <- predict(preProcValues, hp_test_clusters)

hp_train_A_clusters_fact <-
  cbind(hp_train_A, 'cluster' = as.factor(dbscan_clusters_train_A$cluster))
hp_train_B_clusters_fact <-
  cbind(hp_train_B, 'cluster' = as.factor(dbscan_clusters_train_B))
hp_test_clusters_fact <-
  cbind(hp_test, 'cluster' = as.factor(dbscan_clusters_test))

preProcValues <-
  preProcess(hp_train_A_clusters_fact, method = c("center", "scale"))
hp_train_A_clusters_fact_proc <-
  predict(preProcValues, hp_train_A_clusters_fact)
hp_train_B_clusters_fact_proc <-
  predict(preProcValues, hp_train_B_clusters_fact)
hp_test_clusters_fact_proc <-
  predict(preProcValues, hp_test_clusters_fact)

hp_train_A_clusters_all_fact <- hp_train_A_all_fact
hp_train_B_clusters_all_fact <- hp_train_B_all_fact
hp_test_clusters_all_fact <- hp_test_all_fact

hp_train_A_clusters_all_fact <-
  cbind(hp_train_A_clusters_all_fact,
        'cluster' = as.factor(dbscan_clusters_train_A$cluster))
hp_train_B_clusters_all_fact <-
  cbind(hp_train_B_clusters_all_fact,
        'cluster' = as.factor(dbscan_clusters_train_B))
hp_test_clusters_all_fact <-
  cbind(hp_test_clusters_all_fact, 'cluster' = as.factor(dbscan_clusters_test))

preProcValues <-
  preProcess(hp_train_A_clusters_all_fact, method = c("center", "scale"))
hp_train_A_clusters_all_fact_proc <-
  predict(preProcValues, hp_train_A_clusters_all_fact)
hp_train_B_clusters_all_fact_proc <-
  predict(preProcValues, hp_train_B_clusters_all_fact)
hp_test_clusters_all_fact_proc <-
  predict(preProcValues, hp_test_clusters_all_fact)


print(paste0('[',
             round(
               difftime(Sys.time(), start_time, units = 'mins'), 1
             ),
             'm]: ',
             'Clusters Generated!'))
