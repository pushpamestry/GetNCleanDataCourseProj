library(data.table)
library(dplyr)

#Read activity labels and feature names
d_featuresnames <-read.table("UCI HAR Dataset/features.txt", header = FALSE)
d_activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt", header = FALSE)
d_activityLabels[,2] = as.character(d_activityLabels[,2])

#Read Test data

d_featurestest<-read.table("UCI HAR Dataset/test/X_test.txt", header = FALSE)
d_activitytest<-read.table("UCI HAR Dataset/test/Y_test.txt", header = FALSE)
d_subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", header = FALSE)

#Read Train data

d_featurestrain<-read.table("UCI HAR Dataset/train/X_train.txt", header = FALSE)
d_activitytrain<-read.table("UCI HAR Dataset/train/Y_train.txt", header = FALSE)
d_subject_train<- read.table("UCI HAR Dataset/train/subject_train.txt", header = FALSE)

#1 : Merge the training and the test sets to create one data set.
d_subjectAll <- rbind(d_subject_train, d_subject_test)
d_activityAll <- rbind(d_activitytrain, d_activitytest)
d_featuresAll <- rbind(d_featurestrain, d_featurestest)

#Assign column names from features.txt
colnames(d_featuresAll) <- d_featuresnames[,2]

#Merge the data for have a consolidated data set
dt <- cbind(Activity = d_activityAll[,1],Subject = d_subjectAll[,1],d_featuresAll)

#remove tables from memory that are no more required
rm(d_subjectAll)
rm(d_activityAll)
rm(d_featuresAll)
rm(d_featurestest)
rm(d_activitytest)
rm(d_subject_test)
rm(d_featurestrain)
rm(d_activitytrain)
rm(d_subject_train)
rm(d_featuresnames)

#2 : Extracts only the measurements on the mean and standard deviation for each measurement

colFilter <- grep(".*std.*|.*mean.*", ignore.case=TRUE, names(dt))
dt <- data.table(dt[,c(1,2,colFilter)])

#3 : Use descriptive activity names to name the activities in the data set
for (i in 1:nrow(d_activityLabels)){
  dt$Activity[dt$Activity == i] <- as.character(d_activityLabels[i,2])
}

#4 : Appropriately label the data set with descriptive variable names. 
names(dt)<-gsub("^t", "Time", names(dt))
names(dt)<-gsub("^f", "Frequency", names(dt))
names(dt)<-gsub("BodyBody", "Body", names(dt))
names(dt)<-gsub("-mean()", "Mean", names(dt), ignore.case = TRUE)
names(dt)<-gsub("-std()", "STD", names(dt), ignore.case = TRUE)
names(dt)<-gsub("-freq()", "Frequency", names(dt), ignore.case = TRUE)
names(dt)<-gsub("Mag", "Magnitude", names(dt))
names(dt)<-gsub("Acc", "Accelerometer", names(dt))
names(dt)<-gsub("Gyro", "Gyroscope", names(dt))
names(dt)<-gsub("angle", "Angle", names(dt))
names(dt)<-gsub("gravity", "Gravity", names(dt))
names(dt)<-gsub("tBody", "TimeBody", names(dt))

#List new column names
print(names(dt))

# 5 : From the data set in step 4, creates a second, independent tidy data set with the average of each variable 
#for each activity and each subject


dt$Subject <- as.factor(dt$Subject)

tidyData <- aggregate(. ~Subject + Activity, dt, mean)
tidyData <- tidyData[order(tidyData$Subject,tidyData$Activity),]
write.table(tidyData, file = "TidyData.txt", row.names = FALSE)

