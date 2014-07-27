---
Title: "Codebook"
Author: "Ricardo Costa"
Date: "July 27, 2014"
Output: html_document
---  
## Getting and Cleaning Data Programming Assignment - Codebook  
### Description  
The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data.  

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain.  

### Required Packages and Downloading Data  
For this script, there are two required packages to be loaded into your R environment: data.table-package {data.table} and reshape2-package {reshape2}. The following code tests if there is a need to download such packages:  
```{r Loading Packages, echo=FALSE}
if (!require("data.table")) {
  install.packages("data.table")
  library("data.table")
  message("Required data.table package is now in place.")
} else {
  message("Required data.table package is already in place.")
}
if (!require("reshape2")) {
  install.packages("reshape2")
  library("reshape2")
  message("Required reshape2 package is now in place.")
} else {
  message("Required reshape2 package is already in place.")
}
```  

The following code tests if the dataset was previously downloaded and unziped to the disk. If the unziped dataset is not detected, it tries to find the ziped dataset and unzip it right from the disk. If the ziped file and the dataset are not found, dataset is downloaded and unziped.  
```{r Downloading Dataset, echo=FALSE}
workingDir <- getwd()
datasetFile <- paste0(workingDir,"/getdata-projectfiles-UCI HAR Dataset.zip")
datasetRoot <- paste0(workingDir,"/UCI HAR Dataset")
datasetTest <- paste0(datasetRoot,"/test")
datasetTrain <- paste0(datasetRoot,"/train")
if (file.exists(datasetRoot)) {
    message("Dataset is already in place.")
    message("All set. Moving forward with the script.")
  } else {
    message("Unziped dataset not detected.")
    if (!file.exists(datasetFile)){
      message("Ziped dataset wasn't found. Please wait while it is downloaded and unziped.")
      TempFile <- tempfile()
      download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",TempFile, method="curl")
      unzip(TempFile)
      unlink(TempFile)
      message("All set. Moving forward with the script.")
    } else {
      message("Ziped dataset was found. Unziping its content. Please wait.")
      unzip(datasetFile)
      message("All set. Moving forward with the script.")
    }
  }
```  
### Loading and Merging Data  
The following code reads two data files to populate tables with activities and features:
```{r Loading Data, echo=FALSE}
message("Please wait while data is imported.")
datasetActivities <- read.table(
  paste0(datasetRoot, "/activity_labels.txt"), 
  header=FALSE, stringsAsFactors=FALSE)
message("Activities imported.")
datasetFeatures <- read.table(
  paste0(datasetRoot, "/features.txt"), 
  header=FALSE, stringsAsFactors=FALSE)
message("Features imported.")
message("All data was imported. Moving forward with the script.")
``` 
Once loaded, these activities and features are prepared for further analysis. First, test data:
```{r Merging Test Data, echo=FALSE}
datasetSubjectTestData <- read.table(paste0(datasetTest, "/subject_test.txt"), header=FALSE)
datasetSubjectTestDataX <- read.table(paste0(datasetTest, "/X_test.txt"), header=FALSE)
datasetSubjectTestDataY<- read.table(paste0(datasetTest, "/y_test.txt"), header=FALSE)
datasetTestTempFrame <- data.frame(
  Activity = factor(datasetSubjectTestDataY$V1, labels = datasetActivities$V2))
datasetTestData <- cbind(datasetTestTempFrame, datasetSubjectTestData, datasetSubjectTestDataX)
``` 
Then, train data:  
```{r Merging Train Data, echo=FALSE}
datasetSubjectTrainData <- read.table(paste0(datasetTrain, "/subject_train.txt"), header=FALSE)
datasetSubjectTrainDataX <- read.table(paste0(datasetTrain, "/X_train.txt"), header=FALSE)
datasetSubjectTrainDataY <- read.table(paste0(datasetTrain, "/y_train.txt"), header=FALSE)
datasetTrainTempFrame <- data.frame(Activity = factor(datasetSubjectTrainDataY$V1, labels = datasetActivities$V2))
datasetTrainData <- cbind(datasetTrainTempFrame, datasetSubjectTrainData, datasetSubjectTrainDataX)
```  
The project aims to focus exclusively on the mean and standard deviation for each measurement. The following code accomplishes this goal, and saves a file called "tidyData.txt" with the results:  

```{r Extract Mean and Std, echo=FALSE}
datasetTempTidyData <- rbind(datasetTestData, datasetTrainData)
names(datasetTempTidyData) <- c("Activity", "Subject", datasetFeatures[,2])
datasetMeanStdExtract <- datasetFeatures$V2[grep("mean\\(\\)|std\\(\\)", datasetFeatures$V2)]
datasetTidyData <- datasetTempTidyData[c("Activity", "Subject", datasetMeanStdExtract)]
write.table(datasetTidyData, file="./tidyData.txt", row.names=FALSE)
```  
As another goal for this project, the script will create a second, independent tidy data set with the average of each variable for each activity and each subject. The following code accomplishes this goal, and saves a file called "tidyAverageData.txt" with the results:  
```{r Average for Each Activity and Subject, echo=FALSE}
datasetMeltTidyData <- melt(datasetTidyData, id=c("Activity", "Subject"), 
                            measure.vars=datasetMeanStdExtract)
datasetMeanTidyData <- dcast(datasetMeltTidyData, Activity + Subject ~ variable, mean)
write.table(datasetMeanTidyData, file="./tidyAverageData.txt", row.names=FALSE)
```  





