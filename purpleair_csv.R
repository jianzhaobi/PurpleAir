# Downloading the Purple Air measurements of selected sites
#
# Author: Jianzhao Bi
# Mar 2 2018

#download(0,'1027 Hollywood (40.72750976571053 -111.86143357074661)','385885', '5CPPE62979927J8N', 'startdatepicker', 'enddatepicker', 'average', 6);
#download(1,'1027 Hollywood (40.72750976571053 -111.86143357074661)','385886', 'CY94WZ0PXRIG4FP9', 'startdatepicker', 'enddatepicker', 'average',6);

library(httpuv)

#--------------Customization--------------#
# Output path
#setwd('~/Google Drive/Projects/Codes/R/PurpleAir/')
setwd('C:/Users/jbi6/Google Drive/Projects/Codes/R/PurpleAir')
if (!file.exists('Output')) {
  dir.create('Output')
}

# Read the csv file of the site list
sites <- read.csv('Input/sample.csv')

# Start date and end date
start_date <- as.Date('2018-02-01')
end_date <- as.Date('2018-02-07')

# Average
average <- 0 # 0 means not doing average; for hourly data, "average" is set to 60
#--------------Customization--------------#


#--------------Run--------------#
# For each site
for (i in 1 : nrow(sites)) {
  
  # --- Site information ---
  channel <- sites$channel[i]
  name <- sites$name[i]
  key <- sites$key[i]
  secondary <- sites$secondary[i]
  
  print(channel)
  
  # Initialization of final data frame
  dat.final <- data.frame()
  
  for (j in 0 : as.numeric(end_date - start_date)) {
    
    this.day <- start_date + j
    print(this.day)
  
    # --- Time range for a day ---
    starttime <- encodeURI(paste(this.day, '00:00:00'))
    endtime <- encodeURI(paste(this.day, '23:59:59'))
    
    # --- Field names ---
    # Primary
    fieldnames.pri <- c("PM1.0_CF_ATM_ug/m3","PM2.5_CF_ATM_ug/m3","PM10.0_CF_ATM_ug/m3","UptimeMinutes","RSSI_dbm","Temperature_F","Humidity_%","PM2.5_CF_1_ug/m3")
    # Secondary
    fieldnames.sec <- c("0.3um/dl","0.5um/dl","1.0um/dl","2.5um/dl","5.0um/dl","10.0um/dl","PM1.0_CF_1_ug/m3","PM10_CF_1_ug/m3")
    
    # --- URL ---
    url.csv <- paste("https://thingspeak.com/channels/", channel, "/feed.csv?api_key=", key, "&offset=0&average=", average, "&round=2&start=", starttime, "&end=", endtime, sep = '')
    
    # --- Load CSV data ---
    dat <- read.csv(url.csv)
    # Change the column names
    name.len <- length(names(dat))
    if (secondary) { # Secondary
      names(dat)[(name.len - 7) : name.len] <- fieldnames.sec
    } else { # Primary
      names(dat)[(name.len - 7) : name.len] <- fieldnames.pri
    }
    
    # --- Combine data frame ---
    dat.final <- rbind(dat.final, dat)
    
  }
  
  # --- Save CSV data ---
  file.name <- paste(channel, '_', start_date, '_', end_date, '_', 'Avg_', average, '_Sec_', secondary, '.csv', sep = '')
  write.csv(dat.final, file.path('Output', file.name), row.names = F)

}
#--------------Run--------------#


