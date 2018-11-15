# Downloading Sensor list from PurpleAir JSON
# 
# Jianzhao Bi
# 11/14/2018

setwd('~/Google Drive/Projects/Codes/R/Projects/PurpleAir/')

library(rjson)

# Load JSON from URL
json.file <- fromJSON(file = 'https://www.purpleair.com/json')
# Load sensor list
sensor.lst <- json.file$results
# For each sensor
sensor.df <- data.frame()
for (i in 1 : length(sensor.lst)) {
  cat(paste(i, '\r'))
  sensor.i.lst <- sensor.lst[[i]]
  sensor.i.lst[sapply(sensor.i.lst, is.null)] <- NA # Convert NULL to NA in order to preserve it
  sensor.i <- data.frame(t(unlist(sensor.i.lst, use.names = T)), stringsAsFactors = F)
  sensor.df <- rbind(sensor.df, sensor.i)
}
# Write CSV
write.csv(sensor.df, file = paste('Sensorlists/sensorlist', '_', Sys.Date(), '.csv', sep = ''), row.names = F)

