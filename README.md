<p align="center">
  <img src="https://cdnjobs.net/cached_uploads/fit/140/140/2021/07/09/36625093-212503816078813-5737943919384068096-n-1625853678.png" alt="Sublime's custom image"/>
</p>

# Spatial Analysis of ACLED Data
>R tool for `geographically analysing` ACLED data.

# [ACLED](https://acleddata.com/#/dashboard)
The Armed Conflict Location & Event Data Project (ACLED) is a disaggregated `data collection`, `analysis`, and `crisis mapping` project
ACLED collects real-time data on the locations, dates, actors, fatalities, and types of all reported political violence and protest events around the world.

## Repository structure

* [Installations](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#installations)
* [Setting Environment](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#setting-environment)
* [Data](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#data)
* [Cleaning & Feature Engineering](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#cleaning--feature-engineering)
* [Visualization](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#visualization)
  - [Part 1: Summary Data](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#part-1-summary-data)
  - [Part 2: Spatial Analysis](https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-#part-2-spatial-analysis)


## Installations
Install the latest release version of required packages from [CRAN](https://cran.r-project.org/web/packages/available_packages_by_name.html) with :

```R
install.packages(c('acled.api','dplyr', 'tibble', 'janitor', 'plotly', 'ggplot2'))

install.packages(c("sf", "leaflet", "leaflet.providers", "leaflet.opacity", "cartography"))
```

## Setting Environment
Call the library functions from the installed packages as follows:
> ACLED API
```R
library(acled.api)
```
> Tools for data manipulation feature engineering:
```R
library(dplyr)
library(tibble)
library(janitor)
```
> Summary visuals
```R
library(plotly)
library(ggplot2)
library(RColorBrewer)
```
>Spatial Analysis and Visuals
```R
library(sf)
library(tmap)
library(leaflet)
library(tmaptools)
library(cartography)
library(leaflet.opacity)
library(leaflet.providers)
```
### [Plotly Image Export](https://plotly.com/r/chart-studio-image-export/)
Using ``Plotly`` R package for summary visuals we would also want to save the static images.
Set the environment variables in the R session using ``Sys.setenv()``.
```R
Sys.setenv("plotly_username" = "Musebe")
Sys.setenv("plotly_api_key" = "*********")
```
## Data
Export ACLED data to R usin the ACLED API:
```R
Crime_in_Zimababwe <- acled.api(
  email.address = "xxxx",
  access.key = "xxxx",
  country = "Zimbabwe",
  start.date = "2005-01-01",
  end.date = "2021-07-01",
  add.variables = c("latitude","longitude", "geo_precision", "time_precision")
```
The above function imitates the [ACLED data export tool](https://acleddata.com/data-export-tool/). The two credentials required for the API to function are the __email adress__ and the __access key__ which are availed upon subcribing to the platform. 

Sample view of the data:

| iso3  | year | event_date | source | admin1 | admin2 | location | event_type | sub_event_type | interaction | fatalities | timestamp | latitude | longitude | geo_precision | time_precision |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| ZWE | 2021 | 28-Jun-21 | Zimbabwean | Matabeleland North | Hwange Urban | Hwange | Protests | Protest with intervention | 16 | 0 | 1625510722 | -18.3693 | 26.5019 | 2 | 2 | |
| ZWE | 2021 | 18-Jun-21 | Zim Eye | Harare | Harare Urban | Harare | Violence against civilians | Attack | 17 | 0 | 1625510722 | -17.8277 | 31.0534 | 1 | 1 |
| ZWE | 2021 | 16-Jun-21 | New Zimbabwe | Mashonaland West | Kadoma Urban | Kadoma | Protests | Peaceful protest | 60 | 0 | 1625510721 | -18.35 | 29.9167 | 1 | 1 |
| ZWE | 2021 | 9-Jun-21 | Bulawayo24 | Bulawayo | Bulawayo | Bulawayo | Riots | Mob violence | 15 | 0 | 1624310472 | -20.15 | 28.58 | 1 | 1 |
| ZWE | 2021| 7-Jun-21 | Chronicle (Zimbabwe) | Bulawayo | Bulawayo | Bulawayo | Strategic developments | Looting/property destruction | 60 | 0 | 1624310472 | -20.15 | 28.58 | 1 | 1 |




## Cleaning & Feature Engineering
Adding a column time past since ``1979-01-01``. Also for purpose of summarizing data in the year create the ``day of the week`` and ``month`` variable. Both of them from the ``event_date`` variable.

__NB:__ Little cleaning is required for the ACLED data as most of the data is already sorted and ready for analysis. 
```R
Crime_in_Zimbabwe <- Crime_in_Zimbabwe %>% 
  add_column(
    # time
    time = format(as.POSIXct(
      Crime_in_Zimbabwe$timestamp, origin="1970-01-01"), format = "%H:%M:%S"),
    # day of the week
    dow = weekdays(as.Date(Crime_in_Zimbabwe$event_date), abbreviate = T),
    #Month of the Year
    month = months(as.Date(Crime_in_Zimbabwe$event_date), abbreviate = TRUE)
  )
```

## Visualization
### Part 1: Summary Data
Sample visuals extracted from the data are as follows:
#### Top Ten location with highest crisis rate

<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/graphs/top_zim_crisis_loc%20.png?raw=true" alt="Sublime's custom image"/>
</p>

> Harare faces high crime activity than other locations in the country.

#### Provincial crisis rate
<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/graphs/zim_provincial_crisis.png?raw=true" alt="Sublime's custom image"/>
</p>

> Harare province has the highest crisis rate. This is relative with Harare town being in the same province.

#### Monthly Crime Rate
Distribution of crime activity:
<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/graphs/monthly_crisis_in_5yrs%20.png?raw=true" alt="Sublime's custom image"/>
</p>

#### Crime Rate by sub_event
<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/graphs/crisis_activity.png?raw=true" alt="Sublime's custom image"/>
</p>

#### Crime Rate Against Male Population
<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/graphs/crimerate_against_malepop.png?raw=true" alt="Sublime's custom image"/>
</p>

> The visual suggests negative correlation between male population and the crime rate in all the provinces. An outlier is seen un the Harare province. This 

#### Part 2: Spatial Analysis
Geneat visuals of the administrative boundaries of Zimbabwe can be produced by:
```R
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
```



<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_1.png?raw=true" width="250" />
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_2.png?raw=true" width="248" /> 
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_3.png?raw=true" width="245" />
</p>

<p align="center">
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_4.png?raw=true" width="250" />
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_5.png?raw=true" width="248" /> 
  <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/adm_6.png?raw=true" width="250" />
</p>

Example:
##### Provicial Crime Rate
By ``leaflet`` package(left image) & ``cartography`` package:

  <p align="center">
    <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/provincial_crime_rate.jpg?raw=true" width="400" />
    <img src="https://github.com/Gmusebe/ACLED-Spatial-Analysis-with-R-/blob/master/spatial_visuals/provicial_crime_rate_1.png?raw=true" width="380" /> 
  </p>

## Copyright and license
The sample data used here belongs to and has been extracted from [ACLED](https://acleddata.com/#/dashboard).
