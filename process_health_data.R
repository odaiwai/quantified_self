## Script to process the health data
## Helper libraries give you new functions to use
library(devtools)
library(ggplot2)
#library(sqlutils)
#library(RSQLite)
#library(curl)

# basic dataframes
weightData <- read.csv("weight_bp_data.csv", sep=";", header=TRUE)
nutritionData <- read.csv("myFitnessPalData.dat", sep=";")
fitbitData <- read.csv("fitbit_data.csv", sep=";")

# fix the dates
weightData$newDate <- as.POSIXct(weightData$Date, format='%d-%B-%Y %H:%M')
nutritionData$newDate <- as.Date(nutritionData$Date, format='%d-%b-%y')
fitbitData$newDate <- as.Date(fitbitData$Date, format=' %B %d, %Y')

# some calculations
nutritionData$CalorieDeficit <- (nutritionData$Calories - nutritionData$FB.Cals)
weightData$BMI <- (weightData$Weight/(weightData$Height^2))

## What's the class?
#str(weightData)
#str(nutritionData)
#str(fitbitData)

# make a plot object
weightPlot <- ggplot(weightData, aes(x = newDate,y = Weight, size=BMI, color=BMI))
weightPlot + geom_point() 
weightPlot + geom_smooth(method="loess") 
weightPlot + labs(x="date", y="Weight (kg)")

# Need to make a model of intake over days n-x to n-1 and compare it to weight at day n


## Take our data and make a scatter plot

#p <- ggplot(weightData, aes(x=Age, y=Bodyfat_kg)) + geom_point() + geom_smooth(method="loess")                                                                      )
fitbitPlot <- ggplot(fitbitData, aes(x=newDate, y=Total_steps, size=Very_active)) + geom_point()
nutriPlot <- ggplot(nutritionData, aes(x=newDate, y=Calories))+geom_point() + geom_smooth(method="loess") 

# Things to do:
# Make a dataframe with Date, Weight for that Date, Calories in for last x days, calories out for last x days
