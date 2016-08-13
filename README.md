Tidy Data Assignment
==================

One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:

http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

Here are the data for the project:

https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## The Script: run_analysis.R 

The basic algorithm of the run_analysis.R script is:

- Load required libraries (dplyr)
- Determine if data subdirectory exists in working directory, create if not
- Download and unzip file in working subdirectory
- Read all relevant files into R (excludes Inertial Signals directories/files)
- Set Test and Train data variable names using activity_labels and features dataframes
- Bind subject(x), activity(y) and data(feature) dataframes into one each of Test and Train dataframes
- Combine Test and Train dataframes into one dataframe
- Rename remaining unnamed columns
- Select subject and activity (identifying) columns and all mean() or std() data, discard remainder (including meanFreq)
- Clean up feature variable names with more-readable/descriptive names
- Replace activity codes with activity description
- Group by subject and activity and show mean of measurement variables for each grouping
- Write final dataset to txt file 

## How to run run_analysis.R

To run the script, first you need to make sure you are in your desired working directory using the setwd() command. 

Then, load the script using source()

Execute run_analysis - that's it!

## How to read resulting text file



## Creating a Tidy Data Set

According to the course materials (and generally accepted principles), tidy data has the following requirements

1. Each variable shall be in its own column
2. Each observation of that variable shall be in its own row
3. There shall be one table for each kind of variable
4. Multiple tables should each include a column (key) to link the various tables

Also,
- Each table should have a row at the top with variable names
- Variable names should be descriptive and human readable
- One file per table
