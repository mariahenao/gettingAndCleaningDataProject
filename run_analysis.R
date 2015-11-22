library(reshape2)

fileName <- "dataset.zip"

## 1. Download and unzip the dataset if it doesn't exist already:
if (!file.exists(fileName)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, fileName)
}  
if (!file.exists("UCI HAR Dataset")) { 
  unzip(fileName) 
}

# 2. Load activity labels and features tables
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# 3- Extract the mean and the standard deviation
filteredFeatures <- grep(".*mean.*|.*std.*", features[,2])
filteredFeatures.names <- features[filteredFeatures,2]
filteredFeatures.names = gsub('-mean', 'Mean', filteredFeatures.names)
filteredFeatures.names = gsub('-std', 'Std', filteredFeatures.names)
filteredFeatures.names <- gsub('[-()]', '', filteredFeatures.names)


# 4. Load  train and test datasets
train <- read.table("UCI HAR Dataset/train/X_train.txt")[filteredFeatures]
trainActivities <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[filteredFeatures]
testActivities <- read.table("UCI HAR Dataset/test/Y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# 5. now, merge datasets and add appropiate labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", filteredFeatures.names)

# 6. turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

# 7. Finally, save to tidy.txt
write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)