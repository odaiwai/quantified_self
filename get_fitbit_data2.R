library(lubridate)
library(plyr)
library(dplyr)
library(fitbitScraper)

cookie = login("odaiwai@gmail.com", "ceG4Ayb1nAf5hEk", rememberMe = TRUE)
startdate = as.Date('2015-08-07', format = "%Y-%m-%d")
enddate = today()
s = seq(startdate, enddate, by="days")

completeness = hr_data %>% group_by(dte = as.Date(time)) %>% summarise(comp = mean(hrate > 0))
incomp.days = which(completeness$comp < .9)
missing.days = which(s %in% completeness$dte == FALSE)
days.to.process = c(incomp.days, missing.days)

for (i in days.to.process) {
  df = get_intraday_data(cookie, "heart-rate", date=sprintf("%s",s[i]))
  names(df) = c("time","hrate")

  # If the newly downloaded data are for a day already in
  # the pre-existing dataframe, then the following applies:

  if (mean(df$time %in% hr_data$time) == 1) {

    # Get pct of nonzero hrate values in the pre-existing dataframe
    # where the timestamp is the same
    # as the current timestamp being processed in the for loop.

    pct.complete.of.local.day = mean(hr_data$hrate[yday(hr_data$time) == yday(s[i])] > 0)

    # Get pct of nonzero hrate values in the temporary dataframe
    # where the timestamp is the same
    # as the current timestamp being processed in the for loop.

    pct.complete.of.server.day = mean(df$hrate[yday(df$time) == yday(s[i])] > 0)

    # If the newly downloaded data are more complete for this day
    # than what is pre-existing, overwrite the heart rate data
    # for that day.

    if (pct.complete.of.local.day < pct.complete.of.server.day) {
      rows = which(hr_data$time %in% df$time)
      hr_data$hrate[rows] = df$hrate}
  }
  else {

    # If the newly downloaded data are for a day not already in
    # the pre-existing dataframe, then use rbind to just add them!

    hr_data = rbind(hr_data, df)
  }
  rm(df)
}

