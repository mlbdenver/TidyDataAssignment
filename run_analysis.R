run_analysis <- function() {
  
  require(dplyr)
  
  ## Determine if data subdirectory exists in working directory
  ## If not, then create data subdirectory
  if (!file.exists("data")) {dir.create("data")}
    
  ## Set download URL and download zip file
  cat("Downloading file...")
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, destfile = "./data/data.zip", method = "curl")
  dateDownloaded <- date()
  
  ## Unzip data file - unloads into working directory as UCI HAR Dataset
  cat("Unzipping file...", "\n")
  unzip("./data/data.zip")
 
  ## Set directory variables for file reading
  directory <- "./UCI HAR Dataset/"
  directoryTest <- paste(directory,"test/", sep = "")
  directoryTrain <- paste(directory,"train/", sep = "")
  
  ## Read all relevant files into R
  cat("Reading txt files into R...", "\n")
  subjectTest <- read.table(paste(directoryTest,"subject_test.txt", sep=""))
  xTest <- read.table(paste(directoryTest,"x_test.txt", sep=""))
  yTest <- read.table(paste(directoryTest,"y_test.txt", sep=""))
  subjectTrain <- read.table(paste(directoryTrain,"subject_train.txt", sep=""))
  xTrain <- read.table(paste(directoryTrain,"x_train.txt", sep=""))
  yTrain <- read.table(paste(directoryTrain,"y_train.txt", sep=""))
  activityLabels <- read.table(paste(directory, "activity_labels.txt", sep = ""))
  features <- read.table(paste(directory, "features.txt", sep = ""))
  
  ## Read names of Variables for X data and set column names
  cat("Setting column labels...", "\n")
  colnames(activityLabels) <- c("activity", "activitydesc")
  colnames(xTest) <- features[,2]
  colnames(xTrain) <- features[,2]
  
  ## Bind X and Y data to subject dataframes
  cat("Combining datasets...", "\n")
  testData <- cbind(subjectTest,yTest,xTest)
  trainData <- cbind(subjectTrain,yTrain,xTrain)
 
  ## Combine Test and Train dataframes
  cat("Combining test and train datasets into one...", "\n")
  totalData <- rbind(testData,trainData)
  
  ## Rename unnamed columns
  colnames(totalData)[1] <- "subject"
  colnames(totalData)[2] <- "activity"
  
  ## Select three identifying columns and all mean or std data, discard remainder 
  ## There has to be a better way to do this.
  cat("Cleaning up unneeded columns...", "\n")
  colKeep <- grep('mean\\(|std\\(', as.character(features[,2])) +2
  slimData <- totalData[, c(1,2,colKeep)]
  
  ## Clean up variable names (go lowercase and remove symbols)
  cat("Giving variables better names...", "\n")
  names(slimData) <- tolower(names(slimData))
  names(slimData) <- gsub("-","", names(slimData))
  names(slimData) <- gsub("\\(\\)","", names(slimData))
  
  ## Replace activity codes with activity description
  cat("Replacing activity codes with descriptions...", "\n")
  slimData <- left_join(slimData, activityLabels, by = "activity")
  slimData$activity <- tolower(slimData$activitydesc)
  slimData <- select(slimData, -activitydesc)
  cat("Data set officially tidy! Not long now...", "\n")
  ## THIS DATA SET IS NOW TIDY!!!!!
  
  ## Group by activity and show mean of measurement variables
  cat("Creating final data frame...", "\n")
  finalData <- slimData
  byActivity <- finalData %>% group_by(activity) %>% summarise_each(funs(mean)) %>% mutate(subject = NA)
  bySubject <- finalData %>% group_by(subject) %>% summarise_each(funs(mean))
  bySubject = bySubject[, c(2,1,3:ncol(bySubject))] # Swaps first two columns to match byActivity
  finalSet <- rbind(byActivity,bySubject)  #Binds the two sets together
  write.csv(finalSet, file="finalanswer.csv", row.names = FALSE)
  cat("Done! See finalanswer.csv for your output file.")
}