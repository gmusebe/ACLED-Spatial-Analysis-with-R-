# ACLED Analysis

# Download packages:
install.packages(c('acled.api', 'dplyr', 'tibble', 'janitor', 'plotly', 'ggplot2'))

# load packages
# ACLED data import:
library(acled.api)

# Packages for data feature engineering:
library(dplyr)
library(tibble)
library(janitor)

# Visualisations:
library(plotly)
library(ggplot2)

# Acled Data import: Crime Data from 2017 in Zimbabwe
# Let us download the data

Crime_in_Zimababwe <- acled.api(
  email.address = "africa.sis@castorvali.com",
  access.key = "*dQCLqPYi1UOBlJHgvJp",
  country = "Zimbabwe",
  start.date = "2005-01-01",
  end.date = "2021-07-01",
  add.variables = c("latitude","longitude", "geo_precision", "time_precision")
)

# Cleaning and Feature Engineerings:
# Change the timestamp:
# Unix timestamp automatically generated from the api recording each time an event is uploaded in the api
# number of seconds passed when since 1970-01-01. What the latest events are.

Crime_in_Zimababwe <- Crime_in_Zimababwe %>% 
  add_column(
    # time
    time = format(as.POSIXct(Crime_in_Zimababwe$timestamp, origin="1970-01-01"), format = "%H:%M:%S"),
    # day of the week
    dow = weekdays(as.Date(Crime_in_Zimababwe$event_date), abbreviate = T),
    #Month of the Year
    month = months(as.Date(Crime_in_Zimababwe$event_date), abbreviate = TRUE)
  )

# Plotly plots
#Visualisation:
# Location Crime Count:
Location <- data.frame(table(Crime_in_Zimababwe$location))

# Change the names of locations:
names(Location) <- c('loc', 'Count')

# Top 10 locations of crime activity:
Location = head(Location[order(Location$Count, decreasing = TRUE),], 10)

Location$loc <- factor(Location$loc, levels = unique(Location$loc)[order(Location$Count, decreasing = TRUE)])
plot_ly(Location, x = ~loc, y = ~Count, type = "bar",
        name = "Location",
        text = ~Count, textposition = 'auto',
        marker = list(color = c("#2c1429") ))%>%
  layout(title = "Security Incidents Rates by Location",
         xaxis = list(title = "Location",
                      zeroline = FALSE),
         yaxis = list(title = "Count",
                      zeroline = FALSE))

# Admin 1 security rates
Admin1 <- data.frame(table(Crime_in_Zimababwe$admin1))
names(Admin1) <- c('Admin', 'Count')

Admin1$perc <- Admin1$Count / sum(Admin1$Count)*100

Admin1 %>% plot_ly(x = ~Count, y = ~reorder(Admin, Count), name = 'Crime Zones',
                   type = 'bar', orientation = 'h',
                   marker = list(color = "#2c1429", width = 1)) %>% 
  layout(yaxis = list(showgrid = FALSE, showline = FALSE, showticklabels = TRUE, domain= c(0, 0.85)),
         xaxis = list(zeroline = FALSE, showline = FALSE, showticklabels = TRUE, showgrid = TRUE)) %>%
  layout(xaxis = list(title = "",
                      zeroline = FALSE),
         yaxis = list(title = "",
                      zeroline = FALSE)) %>%
  add_annotations(xref = 'x1', yref = 'Admin',
                  x = ~Count * 2.1 + 3,  y = ~Admin,
                  text = paste(round(Admin1$perc, 2), '%'),
                  font = list(family = 'San Serif', size = 12, color = 'rgb(128,0,0)'),
                  showarrow = FALSE)

# Monthly Crime Rate:
# Subset data for the crime categories:
coi <- Crime_in_Zimababwe[Crime_in_Zimababwe$sub_event_type %in%
                            c('Abduction/forced disappearance', 'Mob violence', 'Looting/property destruction',
                              'Peaceful protest', 'Violent demonstration'), ]

# Subset data foror the first five months:
coi <- coi[coi$month %in% c('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'), ]

security_by_crime <- tabyl(coi, month, sub_event_type)
names(security_by_crime) <- c('month', 'abduction', 'looting', 'mob', 'protest', 'demonstration')

# Define percentages of rows
percentages <- round(security_by_crime[,-1]/rowSums(security_by_crime[,-1]), 3) *100

# plot
fig <- plot_ly(security_by_crime, x = ~abduction,
               y = ~factor(month, levels =c('Jun', 'May', 'Apr', 'Mar', 'Feb', 'Jan')), type = 'bar', orientation = 'h', name="Abduction",
               marker = list(color = '#a68196',
                             line = list(color = 'rgb(248, 248, 249)', width = 1))) %>% 
  add_trace(x = ~looting, marker = list(color = '#4a3340'), name="Property destruction") %>% 
  add_trace(x = ~mob, marker = list(color = '#7e7e7f'), name="Mob violence")  %>% 
  add_trace(x = ~protest, marker = list(color = '#7e6070'), name="Peaceful protest") %>%
  add_trace(x = ~demonstration, marker = list(color = '#535252'), name="Violent demonstration") %>%
  layout(xaxis = list(title = "",
                      showgrid = FALSE,
                      showline = FALSE,
                      showticklabels = FALSE,
                      zeroline = FALSE,
                      domain = c(0.15, 1)),
         yaxis = list(title = "",
                      showgrid = FALSE,
                      showline = FALSE,
                      showticklabels = FALSE,
                      zeroline = FALSE),
         barmode = 'stack',
         paper_bgcolor = 'rgb(248, 248, 255)', plot_bgcolor = 'rgb(248, 248, 255)',
         margin = list(l = 120, r = 10, t = 140, b = 80),
         showlegend = TRUE) %>%
  add_annotations(xref = 'paper', yref = 'month', x = 0.14, y = ~month,
                  xanchor = 'right',
                  text = ~month,
                  font = list(family = 'San Serif', size = 12,
                              color = 'rgb(67, 67, 67)'),
                  showarrow = FALSE, align = 'right') 

fig <- fig %>% add_annotations(xref = 'x', yref = 'month',
                               x = security_by_crime$abduction / 2, y = ~month,
                               text = paste(percentages[,"abduction"]),
                               font = list(family = 'San Serif', size = 12,
                                           color = 'rgb(248, 248, 255)'),
                               showarrow = FALSE) %>%
  add_annotations(xref = 'x', yref = 'month',
                  x = security_by_crime$abduction + security_by_crime$looting / 2, y = ~month,
                  text = paste(percentages[,"looting"]),
                  font = list(family = 'San Serif', size = 12,
                              color = 'rgb(248, 248, 255)'),
                  showarrow = FALSE) %>%
  add_annotations(xref = 'x', yref = 'month',
                  x = security_by_crime$abduction  + security_by_crime$looting +security_by_crime$mob / 2, y = ~month,
                  text = paste(percentages[,"mob"]),
                  font = list(family = 'San Serif', size = 12,
                              color = 'rgb(248, 248, 255)'),
                  showarrow = FALSE) %>%
  add_annotations(xref = 'x', yref = 'month',
                  x = security_by_crime$abduction + security_by_crime$looting +security_by_crime$mob +
                    security_by_crime$protest/ 2, y = ~month,
                  text = paste(percentages[,"protest"]),
                  font = list(family = 'San Serif', size = 12,
                              color = 'rgb(248, 248, 255)'),
                  showarrow = FALSE) %>%
  add_annotations(xref = 'x', yref = 'month',
                  x = security_by_crime$abduction + security_by_crime$looting +security_by_crime$mob +
                    security_by_crime$protest + security_by_crime$demonstration  / 2, y = ~month,
                  text = paste(percentages[,"demonstration"]),
                  font = list(family = 'San Serif', size = 12,
                              color = 'rgb(248, 248, 255)'),
                  showarrow = FALSE) %>%
  layout(legend = list(orientation = "h",   # show entries horizontally
                       xanchor = "center",  # use center of legend as anchor
                       x = 0.5))
fig

# Pie for sub_event_type
# Color
color <- c('#a68196', '#4a3340', '#7e7e7f', '#7e6070', '#535252', '#dbdada', '#a4a4a5')

Admin_table <- Crime_in_Zimababwe[Crime_in_Zimababwe$sub_event_type %in%
                                    c("Mob violence", "Peaceful protest", "Looting/property destruction",
                                      "Violent demonstration","Armed clash"), ]
Admin_table <- data.frame(table(Admin_table$sub_event_type))

plot_ly(Admin_table, labels = ~Var1, values = ~Freq, type = 'pie',
        textposition = 'inside',
        textinfo = 'label+percent',
        insidetextfont = list(color = '#FFFFFF'),
        hoverinfo = 'text',
        text = ~paste('$', Freq, ' billions'),
        marker = list(colors = color,
                      line = list(color = '#FFFFFF', width = 1)),
        #The 'pull' attribute can also be used to create space between the sectors
        showlegend = FALSE)

# Line Graph
yearly_trend <- tabyl(Crime_in_Zimababwe, month, year)

# Order Month
yearly_trend <- yearly_trend[order(match(yearly_trend$month, month.abb)), ]

yearly_trend$month <- factor(yearly_trend$month, levels = yearly_trend[["month"]])

plot_ly(x = yearly_trend$month, y = yearly_trend$`2021`, type = 'scatter',
        text = ~yearly_trend$`2021`,
        mode = 'lines+markers', line = list(color = 'rgb(205, 12, 24)', width = 4),
        name = "2021") %>%
  add_trace(y = yearly_trend$`2020`, name = '2020', line = list(color = 'rgb(22, 96, 167)', width = 4)) %>%
  add_trace(y = yearly_trend$`2019`, name = '2019', line = list(color = 'purple', width = 4))

# Security event distribution per year
four_years <- Crime_in_Zimababwe[Crime_in_Zimababwe$year %in%
                                                      c(2016, 2017, 2018, 2019, 2020), ]
event_per_year <- tabyl(four_years, year, event_type)

event_per_year %>% plot_ly() %>%
  add_trace(x = ~year, y = ~Battles, type = 'bar',
            text = ~Battles, textposition = 'auto',
            marker = list(color = '#a68196',
                          line = list(color = 'rgb(8,48,107)', width = 1.5)), name = "Battles") %>% 
  add_trace(x = ~year, y = ~Protests, type = 'bar',
            text = ~Protests, textposition = 'auto',
            marker = list(color = '#4a3340',
                          line = list(color = 'rgb(8,48,107)', width = 1.5)), name = "Protests") %>%
  add_trace(x = ~year, y = ~Riots, type = 'bar',
            text = ~Riots, textposition = 'auto',
            marker = list(color = '#7e7e7f',
                          line = list(color = 'rgb(8,48,107)', width = 1.5)), name = "Riots") %>%
  add_trace(x = ~year, y = ~`Explosions/Remote violence`, type = 'bar',
            text = ~`Explosions/Remote violence`, textposition = 'auto',
            marker = list(color = '#7e6070',
                          line = list(color = 'rgb(8,48,107)', width = 1.5)), name = "Explosions") %>%
  add_trace(x = ~year, y = ~`Violence against civilians`, type = 'bar',
            text = ~`Violence against civilians`, textposition = 'auto',
            marker = list(color = '#535252',
                          line = list(color = 'rgb(8,48,107)', width = 1.5)), name = "Violence") %>%
 layout(title = "Yearly Event-Type Trend",
             barmode = 'group',
             xaxis = list(title = ""),
             yaxis = list(title = ""))

# Security Rate against mens population:
# Lets us take a look at 2018 data. Seeming it registered high number of Security events.
Crime_in_Zimababwe_2018 <- Crime_in_Zimababwe[which(Crime_in_Zimababwe$year == 2018),]
Crime_per_Admin1 <- data.frame(table(Crime_in_Zimababwe_2018$admin1))
names(Crime_per_Admin1) <- c("Province", "Crime_Count")

# Zimbabwe population data as at 2017:
path = "/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/zimbabwe_pop_data.csv"
zim_pop_data <- read.csv(path, header = TRUE, na.strings = "")

# Join the two in regard to Province
Crime_per_Admin1 <- merge(Crime_per_Admin1, zim_pop_data, by="Province")
Crime_per_Admin1 <- Crime_per_Admin1[order(Crime_per_Admin1$Province),]
slope <- 2.666051223553066e-05
Crime_per_Admin1$size <- sqrt(Crime_per_Admin1$Pop * slope)*8
colors <- c('#4AC6B7', '#1972A4', '#965F8A', '#FF7070', '#C61951')
plot_ly(Crime_per_Admin1, x = ~Crime_Count, y = ~Male, color = ~Province, size = ~size*100, colors = colors,
        type = 'scatter', mode = 'markers', sizes = c(min(Crime_per_Admin1$size), max(Crime_per_Admin1$size)),
        marker = list(symbol = 'circle', sizemode = 'diameter',
                      line = list(width = 2, color = '#FFFFFF')),
        text = ~paste('Province:', Province, '<br>Male Pop:', Male, '<br>GDP:', Crime_Count,
                      '<br>Pop.:', Pop)) %>%
  layout(title = 'Crime Count v. Male Population, 2018',
         xaxis = list(title = 'Crime Count',
                      gridcolor = 'rgb(255, 255, 255)',
                      range = c(0,60),
                      zerolinewidth = 1,
                      ticklen = 5,
                      gridwidth = 2),
         yaxis = list(title = 'Male Count',
                      gridcolor = 'rgb(255, 255, 255)',
                      zerolinewidth = 1,
                      ticklen = 5,
                      gridwith = 2),
         paper_bgcolor = 'rgb(243, 243, 243)',
         plot_bgcolor = 'rgb(243, 243, 243)')

#_______________
# Part 2:
# Spatial Analysis:

# Download packages:
install.packages(c("sf", "leaflet", "leaflet.providers", "leaflet.opacity", "cartography"))

#load the packages:
library(sf)
library(leaflet) 
library(leaflet.providers)
library(leaflet.opacity)
library(cartography)
library(RColorBrewer)

# ________________

# Admin boundaries:
# ShapeFile installed
# Level 0 [Country]
zim <- st_read("/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/Zimbabwe ShapeFiles/Admin0/zwe_admbnda_adm0_zimstat_ocha_20180911.shp", 
               stringsAsFactors = FALSE)
# Add Level 1 Boundaries:
level_1 <- st_read("/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/Zimbabwe ShapeFiles/Admin1/zwe_admbnda_adm1_zimstat_ocha_20180911.shp",
                   stringsAsFactors = FALSE)
# Add Level 2 Boundaries:
level_2 <- st_read("/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/Zimbabwe ShapeFiles/Admin2/zwe_admbnda_adm2_zimstat_ocha_20180911.shp",
                   stringsAsFactors = FALSE)
# Add Level 3 Boundaries:
level_3 <- st_read("/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/Zimbabwe ShapeFiles/Admin3/zwe_admbnda_adm3_zimstat_ocha_20180911.shp",
                   stringsAsFactors = FALSE)
library(tmap)
library(tmaptools)

# _____________________________________________________

# ShapeFile installed
# Admin boundaries:

zim <- st_read("zwe_admbnda_adm0_zimstat_ocha_20180911.shp",stringsAsFactors = FALSE) # country boundaries
level_1 <- st_read("zwe_admbnda_adm1_zimstat_ocha_20180911.shp", stringsAsFactors = FALSE) # provincial boundaries
level_2 <- st_read("zwe_admbnda_adm2_zimstat_ocha_20180911.shp",stringsAsFactors = FALSE) # district boundaries
level_3 <- st_read("zwe_admbnda_adm3_zimstat_ocha_20180911.shp",stringsAsFactors = FALSE) # ward boundaries

# country and provincial visual:
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

# country visual:
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 1.5)

# country, provincial & districts visual:
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

# country, provincial, districts and wards visuals:
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

# country and districts visuals:
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = level_2 , # borders of all districts
              color = "blue", 
              fill = NA,
              weight = 1.5) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 4)

# country, districts and wards visual:
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
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 4)

# country and wards:
leaflet() %>%
  addProviderTiles(providers$OpenStreetMap.HOT) %>%
  addPolygons(data = level_3 , # borders of all wards
              color = "grey", 
              fill = NA,
              weight = 0.8) %>%
  addPolygons(data = zim , # borders of the Country
              color = "grey", 
              fill = NA,
              weight = 4)

# Crime by admin 1
# Mappings the security incidents
# ___________The security per Province_______________________________________________
# The admin1 is  the province.
# Admin 1 is the count table.
# Plot the coloured map of the crimes with crimes rates on the scale:
crime <- log10(Admin1$Count)

pal <- colorNumeric(c("#a4a4a5", "#7e7e7f", "#a68097", "#7e6171", "#4a3340"), NULL)
leaflet(level_1) %>% addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(log10(Admin1$Count)),
              label = ~paste0(Admin1$Admin, ": ", formatC(Admin1$Count, big.mark = ","))) %>%
  addLegend(pal = pal, values = ~crime, opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x)))

# Using the cartography package
level_1$security_count <- Admin1$Count

# Plot Provinces
plot(st_geometry(level_1), col = "grey80", border = "grey")
propSymbolsLayer(
  x = level_1, 
  var = "security_count", 
  inches = 0.25, 
  col = "brown4",
  legend.pos = "topright",  
  legend.title.txt = "InSecurity Rate"
)
layoutLayer(title = "Provincial Security Rate in Zimbabwe",
            sources = "Sources: ACLED",
            author = paste0("cartography ", packageVersion("cartography")),
            frame = FALSE, north = FALSE, tabtitle = TRUE)
# north arrow
north(pos = "topleft")


# ___________The security per Districts_______________________________________________

# Crime by admin 2:
Admin2 <- data.frame(table(Crime_in_Zimababwe$admin2))
names(Admin2) <- c('District', 'Count')

# find the distict shape file of the districts reported with incidents:
dist <- level_2[level_2$ADM2_EN %in% Admin2$District, ]
Admin2 <- Admin2[Admin2$District %in% dist$ADM2_EN,]
dist$security_count <- Admin2$Count

# find the polygon shape of the Districts as they do not match the level2 names:
plot(st_geometry(dist), col = NA, border = NA, bg = "#aadaff")
# plot population density
choroLayer(
  x = dist, 
  var = "security_count",
  method = "geom",
  nclass=5,
  col = carto.pal(pal1 = "red.pal", n1 = 5),
  border = "white", 
  lwd = 0.5,
  legend.pos = "topleft", 
  legend.title.txt = "Insecurity Rate",
  add = TRUE
) 
# layout
layoutLayer(title = "District Security Rate in Zimbabwe", 
            sources = "Sources: ACLED, 2017 - 2021",
            author = paste0("cartography ", packageVersion("cartography")), 
            frame = FALSE, north = FALSE, tabtitle = TRUE, theme= "sand.pal") 
# north arrow
north(pos = "topright")


# ___________The security Against Population____________________________________
# Population against Security incidents:
# Lets us take a look at 2018 data. Seeming it registered high number of Security events.
Crime_in_Zimababwe_2018 <- Crime_in_Zimababwe[which(Crime_in_Zimababwe$year ==2018),]
Crime_per_Admin1 <- data.frame(table(Crime_in_Zimababwe_2018$admin1))
names(Crime_per_Admin1) <- c("Province", "Crime_Count")

# Zimbabwe population data as at 2017:
path = "/home/imusebe/code/R/Spatial Data Analysis and Visualisation/ShapeFiles/zimbabwe_pop_data.csv"
zim_pop_data <- read.csv(path, header = TRUE, na.strings = "")

# Join the two in regard to Province
Crime_per_Admin1 <- merge(Crime_per_Admin1, zim_pop_data, by="Province")
Crime_per_Admin1 <- Crime_per_Admin1[order(Crime_per_Admin1$Province),]

level_1$Pop <- Crime_per_Admin1$Pop
level_1$security_count <- Crime_per_Admin1$Crime_Count

plot(st_geometry(level_1), col="darkseagreen3", border="darkseagreen4",  
     bg = "lightblue1", lwd = 0.5)
# Plot symbols with choropleth coloration
propSymbolsChoroLayer(
  x = level_1, 
  var = "Pop", 
  border = "grey50",
  lwd = 1,
  legend.var.pos = "topright", 
  legend.var.title.txt = "Population",
  var2 = "security_count",
  method = "equal", 
  nclass = 4, 
  col = carto.pal(pal1 = "sand.pal", n1 = 4),
  legend.var2.values.rnd = -2,
  legend.var2.pos = "left", 
  legend.var2.title.txt = "Insecurity Rate"
) 
# layout
layoutLayer(title = "Population & Security Rate in Zimbabwe, 2018", 
            sources = "Sources: ACLED, 2017 - 2021",
            author = paste0("cartography ", packageVersion("cartography")), 
            frame = FALSE, north = FALSE, tabtitle = TRUE, theme= "sand.pal") 
# north arrow
 north(pos = "topleft")

# _________________Country Province__________________________________________
# The Midlands map:
mid_province <- level_1[which(level_1$ADM1_EN == "Midlands"),]

# View it:
leaflet() %>%
  addProviderTiles(providers$Stamen) %>%
  addPolygons(data = mid_province , # borders of the midlands
              color = "red", 
              fill = NA,
              weight = 5) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "black", 
              fill = "darkgrey",
              weight = 1)

# For the districts in Midlands lets extract them from the level_2 shapefiles.
mid_dist <- level_2[level_2$ADM2_EN %in% c("Chirumhanzu", "Gokwe North", "Gokwe South", "Gweru",
                                           "Kwekwe", "Mberengwa", "Shurugwi", "Zvishavane"), ]

leaflet() %>%
  addProviderTiles(providers$Stamen) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "black", 
              fill = "darkgrey",
              weight = 1) %>%
  addPolygons(data = mid_province , # borders of the midlands
              color = "#800000", 
              fill = NA,
              weight = 5) %>%
  addPolygons(data = mid_dist , # borders of all provinces
              color = "blue", 
              fill = NA,
              weight = 2)



# Crime in the Midlands districts
mid_security <- Crime_in_Zimababwe[Crime_in_Zimababwe$admin2 %in% c("Chirumhanzu", "Gokwe North", "Gokwe South", "Gweru",
                                                                    "Kwekwe", "Mberengwa", "Shurugwi", "Zvishavane"), ]

# Aggregate data by the districts:
mid_security_aggregate <- data.frame(table(mid_security$admin2))
names(mid_security_aggregate) <- c("ADM2_EN", "security_count")

# merge with mid_dist:
mid_dist <- merge(mid_dist, mid_security_aggregate, by="ADM2_EN")

#Plot the midlands map:
nhd_wms_url <- "https://basemap.nationalmap.gov/arcgis/services/USGSTopo/MapServer/WmsServer"
pal <- colorNumeric("viridis", NULL)
leaflet(mid_dist) %>% addProviderTiles(providers$CartoDB.DarkMatter) %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(log10(mid_dist$security_count)),
              label = ~paste0(mid_dist$ADM2_EN, ": ", formatC(mid_dist$security_count, big.mark = ","))) %>%
  addLegend(pal = pal, values = ~crime, opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x))) %>%
  addPolygons(data = level_1 , # borders of all provinces
              color = "grey", 
              fill = "darkgrey",
              weight = 1) %>%
  addWMSTiles(nhd_wms_url, layers = "1") %>%
  addMiniMap(zoomLevelOffset = -4) %>%
  addScaleBar() %>%
  addTerminator()

# ___MapView________

library(sf)
library(sp)
library(mapview)
states = st_read("USA_2_GADM_fips.shp")
mapview(level_1, zcol = "ADM1_EN")

# View incidents distribution:
Crime_in_Zimababwe$longitude <- as.numeric(Crime_in_Zimababwe$longitude)
Crime_in_Zimababwe$latitude <- as.numeric(Crime_in_Zimababwe$latitude)

data.Set2 <- data.table(Crime_in_Zimababwe)

coordinates(data.Set2) <- c("longitude", "latitude")
proj4string(data.Set2) <- CRS("+proj=longlat +datum=WGS84")

mapview(data.Set2)

# To categorically plot the event_type:
# change the Crime_in Zimbabwe into sf data.frame
projcrs <- "+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"
Crime_in_Zimababwe_sf <- st_as_sf(x = Crime_in_Zimababwe,                         
                                  coords = c("longitude", "latitude"),
                                  crs = projcrs)

mapview(level_1, zcol = "ADM1_EN") + mapview(data.Set2, zcol = "event_type", cex = "geo_precision", 
                                             col.regions = c("lightgoldenrod4", "pink", "#6FB000", "grey90", "black", "blue"))
