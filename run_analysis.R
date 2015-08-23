packages <- c("data.table", "reshape2")
sapply(packages, require, character.only = TRUE, quietly = TRUE)

library(data.table)

## read metadata
featName <- read.table("UCI HAR Dataset/features.txt")
actLabel <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)

## read all data
subjectTr <- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)
activityTr <- read.table("UCI HAR Dataset/train/y_train.txt", header = FALSE)
featuresTr <- read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)

subjectTe <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)
activityTe <- read.table("UCI HAR Dataset/test/y_test.txt", header = FALSE)
featuresTe <- read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)

## merge training and test data
## concatenate the data tables by rows
subject <- rbind(subjectTr, subjectTe)
activity <- rbind(activityTr, activityTe)
features <- rbind(featuresTr, featuresTe)

## load column names
colnames(features) <- t(featName[2])

## merge the data
colnames(activity) <- "Activity"
colnames(subject) <- "Subject"
compData <- cbind(features,activity,subject)

## extract mean and standard deviation
## extract columns with mean or std
colMeanSTD <- grep(".*Mean.*|.*Std.*", names(compData), ignore.case=TRUE)

## add activity and subject column to list
reqColumns <- c(colMeanSTD, 562, 563)

## create extData
extData <- compData[,reqColumns]


## change activity to character
extData$Activity <- as.character(extData$Activity)
for (i in 1:6){
  extData$Activity[extData$Activity == i] <- as.character(actLabel[i,2])
}

extData$Activity <- as.factor(extData$Activity)

## rename the labels of the data set
names(extData)<-gsub("^t", "Time", names(extData))
names(extData)<-gsub("^f", "Freq", names(extData))
names(extData)<-gsub("Acc", "Accel", names(extData))
names(extData)<-gsub("BodyBody", "Body", names(extData))
names(extData)<-gsub("mean()", "Mean", names(extData), ignore.case = TRUE)
names(extData)<-gsub("std()", "STD", names(extData), ignore.case = TRUE)
names(extData)<-gsub("freq()", "Freq", names(extData), ignore.case = TRUE)
names(extData)<-gsub("angle", "Angle", names(extData))
names(extData)<-gsub("gravity", "Gravity", names(extData))
names(extData)<-gsub("tBody", "TimeBody", names(extData))

names(extData)<-gsub("-X", "X-Axis", names(extData))
names(extData)<-gsub("-Y", "Y-Axis", names(extData))
names(extData)<-gsub("-Z", "Z-Axis", names(extData))
names(extData)<-gsub("X", "X-Axis", names(extData))
names(extData)<-gsub("Y", "Y-Axis", names(extData))
names(extData)<-gsub("Z", "Z-Axis", names(extData))


## set subject as factor variable
extData$Subject <- as.factor(extData$Subject)
extData <- data.table(extData)

## create tidyData
tidyData <- aggregate(. ~Subject + Activity, extData, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]

## write data to tidy data.txt
write.table(tidyData, file = "tidy data.txt", row.names = FALSE)

