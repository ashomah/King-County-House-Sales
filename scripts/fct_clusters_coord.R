
### THIS SCRIPT CREATES THE FUNCTION ADD_DISTANCE_EDGES

#### FUNCTION CLUSTERS_COORD ####
clusters_coord <- function(df, r, lat, lon){
  sub_df <- df[,c(lat, lon)]
  df <- as.data.table(df)
  out <- leaderCluster(points = as.data.table(sub_df), radius = r, distance="haversine")
  clusters_centroids <- as.data.frame(out$cluster_centroids)
  clusters_centroids$cluster_id <- as.numeric(rownames(clusters_centroids))
  # cols = rainbow(length(unique(out)))[out]
  # plot(df, pch=19, cex=0.7, col=cols, axes=FALSE)
  # points(df[!duplicated(out),drop=FALSE], cex=2, col=unique(cols))
  # box()
  df <- cbind(df, out$cluster_id)
  df <- merge(df, clusters_centroids, by.x = 'V2', by.y = 'cluster_id', all.x = TRUE)
  names(df) <- c('cluster_id', 'lat', 'lon', 'cluster_lat', 'cluster_lon')
  names(clusters_centroids) <- c('cluster_lat', 'cluster_lon', 'cluster_id')
  # clusters_centroids <- unique(as.data.frame(df[,c('cluster_lat', 'cluster_lon')]))
  list_results <- list(df, clusters_centroids, out)
  return(list_results)
}
