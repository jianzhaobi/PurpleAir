# Extracting the site information from Purple Air Download website
#
# Author: Jianzhao Bi
# Date: Mar 2, 2018

library(xml2)
library(rvest)

setwd('~/Google Drive/Projects/Codes/R/PurpleAir/')

# ---- Load and parse the HTML website ---- #
doc.html <- read_html('https://map.purpleair.org/sensorlist')
# Find all <td> notes with the arribute 'style'
# These <td> notes include the site information
td <- xml_find_all(doc.html, xpath = '////td[@style]') 

# ---- Extracting the site info and write them into a csv file ---- #
# This is an initialization of the final data frame 
info.df.total <- data.frame()

# For each site
for (i in 1 : length(td)) {
  
  print(i)
  
  # Each site
  td.single <- td[i]
  buttons <- xml_children(td.single) # The children nodes of a <td> note; they are 2 <button> nodes and a <br>
  buttons <- buttons[c(1,3)] # Removing a blank <br>
  
  # Primary = 0 and Secondary = 1
  for (j in 1 : length(buttons)) {
  
    ## --- Overall informaton from 'onclick' attribute ---
    # e.g. download(0,'1027 Hollywood (40.72750976571053 -111.86143357074661)','385885', '5CPPE62979927J8N', 'startdatepicker', 'enddatepicker', 'average', 6);
    info <- xml_attr(buttons[j], 'onclick')
    
    # Split the overall info by regexp ", ?'"
    sub.info <- unlist(strsplit(info, split = ", ?'"))
    
    ## --- Secondary (Primary = 0, Secondary = 1) ---
    sub.info[1] <- gsub('download\\( *', '', sub.info[1])
    secondary <- as.numeric(sub.info[1])
    
    ## --- Name & Coordinates ---
    # The regexp means that find a open paren followed by 0 or more spaces or tabs, and they should be ahead of '-' or digits
    # perl = T is necessary for the regexp to be valid (especially if the regexp includes parens)
    name.cor <- unlist(strsplit(sub.info[2], split = "\\( *\\t*(?=([-0-9]))", perl = T))
    name <- name.cor[1]
    name <- gsub("'", '', name) # Remove "'"
    cor <- gsub('\\)', '', name.cor[2])
    latlon <- unlist(strsplit(cor, split = ' '))
    lat <- latlon[1]
    lon <- latlon[2]
    lon <- gsub("'", '', lon)
    
    ## --- Channel ---
    channel <- sub.info[3]
    channel <- gsub("'", '', channel)
    
    ## --- Key ---
    key <- sub.info[4]
    key <- gsub("'", '', key)
    
    ## --- Data frame ---
    info.df <- data.frame(channel = channel, name = name, key = key, lat = lat, lon = lon, secondary = secondary)
    # Combine data frames
    info.df.total <- rbind(info.df.total, info.df)
  }

}

# ---- Write site information ----
write.csv(info.df.total, file = 'PurpleAirSites.csv', row.names = F)


                    