## Loads all required libraries (data.table & reshape2)

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

## Tests if dataset was downloaded and unziped
## If can't find the unziped dataset, it unzips the downloaded zip file
## If can't find the unziped dataset, nor the zip file itself, it downloads and unzips it

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

## Loads the necessary data
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

# Prepare test data for the analysis
message("Please wait while test & train data are prepared for analysis.")
datasetSubjectTestData <- read.table(paste0(datasetTest, "/subject_test.txt"), header=FALSE)
datasetSubjectTestDataX <- read.table(paste0(datasetTest, "/X_test.txt"), header=FALSE)
datasetSubjectTestDataY<- read.table(paste0(datasetTest, "/y_test.txt"), header=FALSE)
datasetTestTempFrame <- data.frame(Activity = factor(datasetSubjectTestDataY$V1, labels = datasetActivities$V2))
datasetTestData <- cbind(datasetTestTempFrame, datasetSubjectTestData, datasetSubjectTestDataX)
datasetSubjectTrainData <- read.table(paste0(datasetTrain, "/subject_train.txt"), header=FALSE)
datasetSubjectTrainDataX <- read.table(paste0(datasetTrain, "/X_train.txt"), header=FALSE)
datasetSubjectTrainDataY <- read.table(paste0(datasetTrain, "/y_train.txt"), header=FALSE)
datasetTrainTempFrame <- data.frame(Activity = factor(datasetSubjectTrainDataY$V1, labels = datasetActivities$V2))
datasetTrainData <- cbind(datasetTrainTempFrame, datasetSubjectTrainData, datasetSubjectTrainDataX)
message("Train and test data are ready. Moving forward with the script.")

# Extracting mean and standard deviation for the analysis
message("Please wait while the Mean and Standard Deviation are extracted from the dataset, and saved.")
datasetTempTidyData <- rbind(datasetTestData, datasetTrainData)
names(datasetTempTidyData) <- c("Activity", "Subject", datasetFeatures[,2])
datasetMeanStdExtract <- datasetFeatures$V2[grep("mean\\(\\)|std\\(\\)", datasetFeatures$V2)]
datasetTidyData <- datasetTempTidyData[c("Activity", "Subject", datasetMeanStdExtract)]
write.table(datasetTidyData, file="./tidyData.txt", row.names=FALSE)
message("Mean and Standard Deviation extracted, and saved. Moving forward with the script.")

# Creates and saves a second, independent tidy data for each activity and subject  
message("Please wait while a tidy set per activity and subject is prepared and saved.")
datasetMeltTidyData <- melt(datasetTidyData, id=c("Activity", "Subject"), measure.vars=datasetMeanStdExtract)
datasetMeanTidyData <- dcast(datasetMeltTidyData, Activity + Subject ~ variable, mean)
write.table(datasetMeanTidyData, file="./tidyAverageData.txt", row.names=FALSE)
message("End of script.")