Tidy Data Assignment
==================

- [Assignment Summary](#summary)
- [Repository Contents](#repo)
- [The Script Process](#process)
- [How to Run run_analysis.R](#howtorun)
- [The Output File: tidydata.txt](#tidy)


<h1 id=summary>Assignment Summary</h1>

## Getting and Cleaning Data Course Project

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## Data Source

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

<h1 id=repo>Repository Contents</h1>

The mlbdenver/reponame repository holds four files, per the assignment instructions. They are:
<table>
<tr><th>File</th><th>Description</th></tr>
<tr><td>README.md</td><td>Description of the assignment, script algorithm, etc.</td></tr>
<tr><td>codebook.md</td><td>file description</td></tr>
<tr><td>run_analysis.R</td><td>R script that tidies provided data and creates new output dataset, tidydata.txr</td></tr>
<tr><td>tidydata.txt</td><td>Output file of run_analysis.R script</td></tr>
</table>

<h1 id=process>The Script Process</h1>

####The basic steps the run_analysis.R script takes are:

Load required libraries (dplyr & data.table)
 ```
    require(dplyr)
    require(data.table)
 ```
Determine if data subdirectory exists in working directory, create if not
```
    ## Determine if data subdirectory exists in working directory, create if not
    if (!file.exists("data")) {dir.create("data")}
 ```
Download and unzip file in working subdirectory
```
    ## Set download URL and download zip file
    cat("Downloading file...")
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
    download.file(fileURL, destfile = "./data/data.zip", method = "curl")
    dateDownloaded <- date()
  
    ## Unzip data file - unloads into working directory as UCI HAR Dataset
    cat("Unzipping file...", "\n")
    unzip("./data/data.zip")
```
Read all relevant files into R (excludes Inertial Signals directories/files)
```
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
```
Set Test and Train data variable names using activity_labels and features dataframes
```    
    ## Read names of Variables for X data and set column names
    cat("Setting column labels...", "\n")
    colnames(activityLabels) <- c("activity", "activitydesc")
    colnames(xTest) <- features[,2]
    colnames(xTrain) <- features[,2]
```
Bind subject(x), activity(y) and data(feature) dataframes into one each of Test and Train dataframes
``` 
   ## Bind X and Y data to subject dataframes
    cat("Combining datasets...", "\n")
    testData <- cbind(subjectTest,yTest,xTest)
    trainData <- cbind(subjectTrain,yTrain,xTrain)
```
Combine Test and Train dataframes into one dataframe
```
    ## Combine Test and Train dataframes
    cat("Combining test and train datasets into one...", "\n")
    totalData <- rbind(testData,trainData)
```
Rename remaining unnamed columns
```
    ## Rename unnamed columns
    colnames(totalData)[1] <- "subject"
    colnames(totalData)[2] <- "activity"
```
Select subject and activity (identifying) columns and all mean() or std() data, discard remainder (including meanFreq)
```
    ## Select identifying columns and all mean or std data 
    ## (excluding meanFreq as not specifically a mean() calc)
    cat("Cleaning up unneeded columns...", "\n")
    colKeep <- grep('mean\\(|std\\(', as.character(features[,2])) +2
    slimData <- totalData[, c(1,2,colKeep)]
```
Clean up feature variable names with more-readable/descriptive names
 ```
    ## Clean up variable names
    cat("Giving variables better names...", "\n")
    names(slimData) <- names(slimData) %>% tolower %>% gsub("-","",.) %>% gsub("\\(\\)","", .) %>% gsub("^t","time", .) %>% gsub("^f","freq", .) %>% gsub("acc","accelerator", .) %>% gsub("gyro","gyrometer", .)
```
Replace activity codes with activity description
```
    ## Replace activity codes with activity description
    cat("Replacing activity codes with descriptions...", "\n")
    slimData <- left_join(slimData, activityLabels, by = "activity")
    slimData$activity <- tolower(slimData$activitydesc)
    slimData <- select(slimData, -activitydesc)
    cat("Data set officially tidy! Not long now...", "\n")
 ```
Group by subject and activity and show mean of measurement variables for each grouping
```
    ## Group by subject and activity and show mean of measurement variables
    cat("Creating final data frame...", "\n")
    finalData <- slimData
    finalSet <- finalData %>% group_by(subject, activity) %>% summarise_each(funs(mean))
 ```
Write final dataset to txt file
```
    write.table(finalSet, file="tidydata.txt", sep=" ")
    cat("Done! See tidydata.txt in your working directory for your output file.") 
```
<h1 id=howtorun>How to run run_analysis.R</h1>

To run the script, first you need to make sure you are in your desired working directory using the <code>setwd()</code> command. 

Then, load the script using source()
```
    source("run_analysis.R")
```
Execute run_analysis - that's it!
```
    run_analysis()
```
<h1 id=tidy>The Output File: tidydata.txt</h1>

###How to read resulting text file into R

To read tidydata.txt into R or RStudio, make sure your working directory is where the txt file is stored. Then you can read it into a dataframe "tidydata" by running:
```
    tidyData <- read.table("tidydata.txt", sep=" ")
 ```   


###What's In the Output File?

The output file, tidydata.txt, is more fully described in great detail in the Code Book. However, there were some choices that needed to be made based on a) ambiguity in the assignment, and b) the appropriate form of dataset (wide or long). 

The specific instructions were to 
> create a second, independent tidy data set with the average of each variable for each activity and each subject.

Whether to show each activity for each subject, and the resulting measurement means, or to summarize all subjects and all of the activities was unclear. This analysis shows each of 6 activities for all 30 subjects, resulting in a table of 180 records.

#####Wide or Long?
When faced with the choice of a wider data set (like tidydata.txt) or a long one (where each measurement variable is considered a separate observation), this analyst chose the wider data set. With 66 measurement variables, the resulting narrow data set would have been extremely long (6 x 30 x 66). Therefore, a wide data set was created.


## What Makes a Tidy Data Set

tidydata.txt is a tidy data set, as it conforms to the following rules:

1. Each variable shall be in its own column
2. Each observation of that variable shall be in its own row
3. There shall be one table for each kind of variable
4. Multiple tables should each include a column (key) to link the various tables

Also,
- Each table should have a row at the top with variable names
- Variable names should be descriptive and human readable
- One file per table

Although the variable names for the various measurements are long and complicated, any effort to reduce the complexity of the variable name would have resulted in the elimination of important information.
