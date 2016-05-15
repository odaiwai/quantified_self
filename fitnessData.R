# R Script to input the various fitness Data files
# and come to a conclusion
#

#mfpData <- read.csv("myFitnessPalData.dat", sep="\t", header = TRUE)
mfpData <- read.csv("weightData.dat", sep="\t", header = TRUE)

# Need to consider a Linear model of the form:
# today's Weight = Starting Weight + previous day's calories / (cal/kg) + ... (previous calories too)
