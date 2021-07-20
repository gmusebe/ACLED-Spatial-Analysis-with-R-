library(sf) 
library(ggplot2) 
library(tmap)
library(tmaptools)
library(leaflet) 
library(leaflet.providers) 
library(dplyr)
library(raster) 
library(leaflet.opacity)
library(rgdal) 
library(raster) 
library(rgeos) 

# Level 0 [Country]
zim <- st_read("zwe_admbnda_adm0_zimstat_ocha_20180911.shp", stringsAsFactors = FALSE)
str(zim)

leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 1.5)


# Add Level 1 Boundaries:
level_1 <- st_read("zwe_admbnda_adm1_zimstat_ocha_20180911.shp", stringsAsFactors = FALSE)
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "red", 
              fill = NA,
              weight = 1.5) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 1.5) 


  
# Add Level 2 Boundaries:
level_2 <- st_read("zwe_admbnda_adm2_zimstat_ocha_20180911.shp", stringsAsFactors = FALSE)
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = level_2 , # borders of all districts
              color = "blue", 
              fill = NA,
              weight = 1.5) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "red", 
              fill = NA,
              weight = 2) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 4)

# Add Level 3 Boundaries:
level_3 <- st_read("zwe_admbnda_adm3_zimstat_ocha_20180911.shp", stringsAsFactors = FALSE)
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = level_3 , # borders of all wards
              color = "grey", 
              fill = NA,
              weight = 0.8) %>%
  addPolygons(data = level_2 , # borders of all districts
              color = "blue", 
              fill = NA,
              weight = 1) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "red", 
              fill = NA,
              weight = 1.5) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 4)


# World map for location:
# turn off axis elements in ggplot for better visual comparison
newTheme <- list(theme(line = element_blank(),
                       axis.text.x = element_blank(),
                       axis.text.y = element_blank(),
                       axis.ticks = element_blank(), # turn off ticks
                       axis.title.x = element_blank(), # turn off titles
                       axis.title.y = element_blank(),
                       legend.position = "none")) # turn off legend

worldBound <- readOGR(dsn = "ne_110m_land.shp")

# convert to dataframe
worldBound_df <- fortify(worldBound)

ggplot(worldBound_df, aes(long,lat, group = group)) +
  geom_polygon() +
  coord_equal() +
  labs(x = "Longitude (Degrees)",
       y = "Latitude (Degrees)",
       title = "Global Map - Geographic Coordinate System",
       subtitle = "WGS84 Datum, Units: Degrees - Latitude / Longitude")





