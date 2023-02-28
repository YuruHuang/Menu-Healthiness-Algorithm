############################################################################
# In this script, I will create visual maps for menu healthiness in the UK #
############################################################################

# shape file (LA level)
library(rgeos)
library(rgdal)
census = readOGR('Gb_dt_2009_10\\Gb_dt_2009_10.shp') %>% 
  spTransform(CRS('+proj=longlat +datum =WGS84'))
plot(census)
