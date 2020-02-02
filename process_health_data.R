## Script to process the health data
## Helper libraries give you new functions to use
library(devtools)
library(ggplot2)
#library(sqlutils)
library(DBI) # ref: https://db.rstudio.com/databases/sqlite/

# connnect to the database and get the data
con <- dbConnect(RSQLite::SQLite(), "~/Documents/health/analyse_health_data/health_data.sqlite")
#weightData <- dbReadTable(con, "ss_physical")
weightData <- dbGetQuery(con, "select * from ss_physical where timestamp > \'2010™%\'")
# fix the dates
weightData$date <- as.POSIXct(weightData$timestamp, tz="", format='%Y-%m-%d %H:%M:%S')
#nutritionData$newDate <- as.Date(nutritionData$Date, format='%d-%b-%y')
#fitbitData$newDate <- as.Date(fitbitData$Date, format=' %B %d, %Y')

## What's the class?
#str(weightData)

# make a plot object
weightPlot <- ggplot(data = weightData) +
  geom_point(mapping = aes(x = date,y = weight)) +
  geom_smooth(mapping = aes(x = date, y = weight)) +
  labs(x="date", y="Weight (kg)") +
  ggtitle("Body Weight Over Time")

weightPlot

# Need to make a model of intake over days n-x to n-1 and compare it to weight at day n


## Take our data and make a scatter plot

#p <- ggplot(weightData, aes(x=Age, y=Bodyfat_kg)) + geom_point() + geom_smooth(method="loess")                                                                      )
#fitbitPlot <- ggplot(fitbitData, aes(x=newDate, y=Total_steps, size=Very_active)) + geom_point()
#nutriPlot <- ggplot(nutritionData, aes(x=newDate, y=Calories))+geom_point() + geom_smooth(method="loess") 

# Things to do:
# Make a dataframe with Date, Weight for that Date, Calories in for last x days, calories out for last x days
