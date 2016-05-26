library(lubridate)
library(plyr)
library(dplyr)
library(fitbitScraper)
# from: http://rforwork.info/2015/08/08/hey-fitbit-my-data-belong-to-me/
hr_data = list(time = c(), hrate = c())

cookie = login("odaiwai@gmail.com", "ceG4Ayb1nAf5hEk", rememberMe = TRUE)
startdate = as.Date('2013-10-05', format = "%Y-%m-%d")
enddate = today()
s = seq(startdate, enddate, by="days")

for (i in 1:length(s)) {
  df = get_intraday_data(cookie, "heart-rate", date=sprintf("%s",s[i]))
  names(df) = c("time","hrate")
  hr_data = rbind(hr_data, df)
  rm(df)}


