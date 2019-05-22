####
#### THIS SCRIPT COLLECTS THE MAP BACKGROUND FROM GOOGLE MAP API
####

# # API Settings ----
# api <- readLines('google.api') # Text file with the API key
# register_google(key = api)
# getOption("ggmap")


# Find center of the map
long_lat <-
  rbind(hp_train[, c("long", "lat")], hp_test[, c("long", "lat")])
mean_long <- mean(long_lat$long)
mean_lat <- mean(long_lat$lat)


# # Collect map data
# hp_map_8 <- get_map(
#   location = c(lon = mean_long, lat = mean_lat),
#   maptype = "toner-hybrid",
#   zoom = 8,
#   filename = "data/hp_map_8_temp"
# )
# hp_map_9 <- get_map(
#   location = c(lon = mean_long, lat = mean_lat),
#   maptype = "toner-hybrid",
#   zoom = 9,
#   filename = "data/hp_map_9_temp"
# )
# hp_map_10 <- get_map(
#   location = c(lon = mean_long, lat = mean_lat),
#   maptype = "toner-hybrid",
#   zoom = 10,
#   filename = "data/hp_map_10_temp"
# )
# save(hp_map_8, file = 'data_output/hp_map_8.rda')
# save(hp_map_9, file = 'data_output/hp_map_9.rda')
# save(hp_map_10, file = 'data_output/hp_map_10.rda')
