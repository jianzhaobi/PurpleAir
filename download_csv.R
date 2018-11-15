# Downloading the Purple Air measurements of selected sites (Only Primary Data)
#
# Jianzhao Bi
# 11/15/2018

#download(0,'1027 Hollywood (40.72750976571053 -111.86143357074661)','385885', '5CPPE62979927J8N', 'startdatepicker', 'enddatepicker', 'average', 6);
#download(1,'1027 Hollywood (40.72750976571053 -111.86143357074661)','385886', 'CY94WZ0PXRIG4FP9', 'startdatepicker', 'enddatepicker', 'average',6);

library(httpuv)

#--------------Customization--------------#
# Output path
setwd('~/Google Drive/Projects/Codes/R/Projects/PurpleAir/')
#setwd('C:/Users/jbi6/Google Drive/Projects/Codes/R/PurpleAir')
if (!file.exists('Output')) {
  dir.create('Output')
}

# Read the lastest sensor list
sites <- read.csv(paste('Input/target_sites.csv', sep = ''), as.is = T)

# sensor.lists <- dir(path = 'Sensorlists/', pattern = '*.csv') # Sensor list files
# lists.date <- as.Date(substr(sensor.lists, start = 12, stop = 21)) # Get the dates of the files
# date.diff <- Sys.Date() - lists.date # Compare to today's date
# sensor.list.lastest <- sensor.lists[which(date.diff == min(date.diff))] # Find the latest file
# sites <- read.csv(paste('Sensorlists/', sensor.list.lastest, sep = '')) # Get the sites from the latest file

# Start date and end date
start_date <- as.Date('2018-11-01')
end_date <- as.Date('2018-11-02')

# Time zone
timezone <- 'America/Los_Angeles'

# Average level
average <- 60 # Get average of this many minutes, valid values: 10, 15, 20, 30, 60, 240, 720, 1440, "daily". 
# Don't use 'daily' since the time is UTC !!!

# --- Field names ---
# Primary
fieldnames.pri.A <- c("PM1.0_CF_ATM_ug/m3_A","PM2.5_CF_ATM_ug/m3_A","PM10.0_CF_ATM_ug/m3_A","Uptime_Minutes_A","RSSI_dbm_A","Temperature_F_A","Humidity_%_A","PM2.5_CF_1_ug/m3_A")
fieldnames.pri.B <- c("PM1.0_CF_ATM_ug/m3_B","PM2.5_CF_ATM_ug/m3_B","PM10.0_CF_ATM_ug/m3_B","HEAP_B","ADC0_voltage_B","Atmos_Pres_B","Not_Used_B","PM2.5_CF_1_ug/m3_B")
# Secondary
# fieldnames.sec <- c("0.3um/dl","0.5um/dl","1.0um/dl","2.5um/dl","5.0um/dl","10.0um/dl","PM1.0_CF_1_ug/m3","PM10_CF_1_ug/m3")
#--------------Customization--------------#


#--------------Run--------------#
# For each site
for (i in 1 : nrow(sites)) {
  
  if ((is.na(sites$ParentID[i])) & (sites$DEVICE_LOCATIONTYPE[i] != 'inside')) { # Skip indoor sensors and Channel B sensors
    
    # --- Site information ---
    name <- trimws(sites$Label[i]) # Remove Leading/Trailing Whitespace
    Lat <- sites$Lat[i]
    Lon <- sites$Lon[i]
    # Channel A
    ID.A <- sites$ID[i]
    channelID.A <- sites$THINGSPEAK_PRIMARY_ID[i]
    channelKey.A <- sites$THINGSPEAK_PRIMARY_ID_READ_KEY[i]
    # Channel B
    ib <- which(sites$ParentID == ID.A)
    channelID.B <- sites$THINGSPEAK_PRIMARY_ID[ib]
    channelKey.B <- sites$THINGSPEAK_PRIMARY_ID_READ_KEY[ib]
    
    print(name)
    
    # --- Channel A & B ---
    # Initialization of primary data frame
    dat.final <- data.frame()
    
    for (j in 0 : as.numeric(end_date - start_date)) {
      
      this.day <- start_date + j
      cat(as.character(this.day), '\r')
      
      # --- Time range for a day ---
      starttime <- encodeURI(paste(this.day, '00:00:00')) # UTC Time !!!
      endtime <- encodeURI(paste(this.day, '23:59:59')) # UTC Time !!!
      
      # --- URL ---
      # Channel A
      url.csv.A <- paste("https://thingspeak.com/channels/", channelID.A, "/feed.csv?api_key=", channelKey.A, '&average=', average, "&round=3&start=", starttime, "&end=", endtime, sep = '')
      # Channel B
      url.csv.B <- paste("https://thingspeak.com/channels/", channelID.B, "/feed.csv?api_key=", channelKey.B, '&average=', average, "&round=3&start=", starttime, "&end=", endtime, sep = '')
      
      # --- Load CSV data ---
      dat.A <- read.csv(url.csv.A)
      if (length(ib) != 0) { # If Channel B exists
        dat.B <- read.csv(url.csv.B)
      } else {
        dat.B <- dat.A
        dat.B[,] <- NA
      }
      # Combine Channel A & B
      dat.B$created_at <- NULL
      dat <- cbind(dat.A, dat.B)
      # Change the column names
      names(dat)[2 : ncol(dat)] <- c(fieldnames.pri.A, fieldnames.pri.B)
      # Add basic information
      dat$ID <- ID.A
      dat$Name <- name
      dat$Lat <- Lat
      dat$Lon <- Lon
      
      # --- Combine data frame ---
      dat.final <- rbind(dat.final, dat)
      
    }
  }
  
  # --- Save CSV data ---
  file.name <- paste(ID.A, '_', name, '_', start_date, '_', end_date, '_Primary', '.csv', sep = '')
  write.csv(dat.final, file.path('Output', file.name), row.names = F)
  
}
#--------------Run--------------#


