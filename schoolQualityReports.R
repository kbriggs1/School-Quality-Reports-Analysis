#Script Name: Cleaning/cleanSQRData.R
#Created By: Krystal Briggs
#Created On: 2/24/2020
#Description: Cleaning and Merging SQR_hs_summary tables for years 2018-2019. 
#Required/Related Scripts: [OPTIONAL]
#Controller file(s) that call this script: [OPTIONAL]
ptb <- proc.time()

source('~/R-Data-Processing/Environment/warehouseConnection.R')


# Script-specific functions or variables ----------------------------------------------------------------
scriptName <- "Cleaning/cleanSQRData.R"



#get the list of tables in the stag_public schema
tableList <- dbGetQuery(myconn, "SELECT distinct table_name, column_name, 
 ordinal_position, data_type
 FROM nvpsdev.information_schema.columns
 WHERE table_schema = 'stag_public';")

#get the indices for the tables that have 2012-2019 in their titles
tableIndices <- grep("sqr_2019_hs.|sqr_2018_hs.|sqr_2017_hs.|sqr_2016_hs.|sqr_2015_hs.|sqr_2014_hs.|sqr_2013_hs.|sqr_2012_hs", tableList[,1])

## subset the table indices for the sqr tables of interest
sqrPublicTable <- as.data.table(tableList[tableIndices, ])

sqrPublicTable[,unique(table_name)]

# hs summary tables
summaryTables <- unique(sqrPublicTable[grepl("summary", table_name), table_name])
summaryTableNames <- copy(summaryTables)

# hs additional info tables
additionalInfo <- unique(sqrPublicTable[grepl("additional_info", table_name), table_name])
additionalInfoNames <- copy(additionalInfo)

# student achievement tables
studentAchievement <- unique(sqrPublicTable[grepl("student_achievement", table_name), table_name])
studentAchievementNames <- copy(studentAchievement)

# closing the achievement gap
closingTheAchievementGap <- unique(sqrPublicTable[grepl("closing_the_achievement_gap", table_name), table_name])
closingTheAchievementGapNames <- copy(closingTheAchievementGap)


# targets
targets <- unique(sqrPublicTable[grepl("targets", table_name), table_name])
targetsNames <- copy(targets)

# framework
framework <- unique(sqrPublicTable[grepl("framework", table_name), table_name])
frameworkNames <- copy(framework)



# Load Data ---------------------------------------------------------------------------------------------

## pull in all tables and combine into one list
#summary
summaryTables <- lapply(summaryTables, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(summaryTables) <- summaryTableNames

#additionalInfo
additionalInfo <- lapply(additionalInfo, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(additionalInfo) <- additionalInfoNames

#studentAchievement
studentAchievement<- lapply(studentAchievement, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(studentAchievement) <- studentAchievementNames

#closing the achievement gap
closingTheAchievementGap<- lapply(closingTheAchievementGap, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(closingTheAchievementGap) <- closingTheAchievementGapNames

#targets
targets<- lapply(targets, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(targets) <- targetsNames 

#framework
framework<- lapply(framework, function(x) sqlDbPull(table = paste0("stag_public.", x)))
names(framework) <- frameworkNames 



# Pre-process -------------------------------------------------------------------------------------------

# add a schoolYear column to each table
summaryTables <- mapply(cbind, summaryTables, schoolYear = substring(names(summaryTables), 5, 8))
# add ta tableName column to each table
summaryTables <- mapply(cbind, summaryTables, tableName = "hsSummary")


# add a schoolYear column to each table for additonalInfo
additionalInfo <- mapply(cbind, additionalInfo, schoolYear = substring(names(additionalInfo), 5, 8))
# add ta tableName column to each table
additionalInfo <- mapply(cbind, additionalInfo, tableName = "hsAdditionalInfo")

# add a schoolYear column to each table for studentAchievement
studentAchievement <- mapply(cbind, studentAchievement, schoolYear = substring(names(studentAchievement), 5, 8))
# add ta tableName column to each table
studentAchievement<- mapply(cbind, studentAchievement, tableName = "hsStudentAchievement")

# add a schoolYear column to each table for closing the achievement gap
closingTheAchievementGap <- mapply(cbind, closingTheAchievementGap, schoolYear = substring(names(closingTheAchievementGap), 5, 8))
# add ta tableName column to each table
closingTheAchievementGap <- mapply(cbind, closingTheAchievementGap, tableName = "hsClosingTheAchievementGap")

# add a schoolYear column to each table for targets
targets <- mapply(cbind, targets, schoolYear = substring(names(targets), 5, 8))
# add ta tableName column to each table
targets <- mapply(cbind, targets, tableName = "hsTargets")

# add a schoolYear column to each table for framework
framework <- mapply(cbind, framework, schoolYear = substring(names(framework), 5, 8))
# add ta tableName column to each table
framework <- mapply(cbind, framework, tableName = "hsFramework")

#subset each table into its own data.table for comparison
summary12 <- summaryTables$sqr_2012_hs_summary
summary13 <- summaryTables$sqr_2013_hs_summary
summary14 <- summaryTables$sqr_2014_hs_summary
summary15 <- summaryTables$sqr_2015_hs_summary
summary16 <- summaryTables$sqr_2016_hs_summary
summary17 <- summaryTables$sqr_2017_hs_summary
summary18 <- summaryTables$sqr_2018_hs_summary
summary19 <- summaryTables$sqr_2019_hs_summary



#subset each table into its own data.table for comparison
additionalInfo12 <- additionalInfo$sqr_2012_hs_additional_info
additionalInfo13 <- additionalInfo$sqr_2013_hs_additional_info
additionalInfo14 <- additionalInfo$sqr_2014_hs_additional_info
additionalInfo15 <- additionalInfo$sqr_2015_hs_additional_info
additionalInfo16 <- additionalInfo$sqr_2016_hs_additional_info
additionalInfo17 <- additionalInfo$sqr_2017_hs_additional_info
additionalInfo18 <- additionalInfo$sqr_2018_hs_additional_info
additionalInfo19 <- additionalInfo$sqr_2019_hs_additional_info


#subset each table into its own data.table for comparison
studentAchievement12 <- studentAchievement$sqr_2012_hs_student_achievement
studentAchievement13 <- studentAchievement$sqr_2013_hs_student_achievement
studentAchievement14 <- studentAchievement$sqr_2014_hs_student_achievement
studentAchievement15 <- studentAchievement$sqr_2015_hs_student_achievement
studentAchievement16 <- studentAchievement$sqr_2016_hs_student_achievement
studentAchievement17 <- studentAchievement$sqr_2017_hs_student_achievement
studentAchievement18 <- studentAchievement$sqr_2018_hs_student_achievement
studentAchievement19 <- studentAchievement$sqr_2019_hs_student_achievement

#subset each table into its own data.table for comparison
closingTheAchievementGap12 <- closingTheAchievementGap$sqr_2012_hs_closing_the_achievement_gap
closingTheAchievementGap13 <- closingTheAchievementGap$sqr_2013_hs_closing_the_achievement_gap
closingTheAchievementGap14 <- closingTheAchievementGap$sqr_2014_hs_closing_the_achievement_gap
closingTheAchievementGap15 <- closingTheAchievementGap$sqr_2015_hs_closing_the_achievement_gap
closingTheAchievementGap16 <- closingTheAchievementGap$sqr_2016_hs_closing_the_achievement_gap
closingTheAchievementGap17 <- closingTheAchievementGap$sqr_2017_hs_closing_the_achievement_gap
closingTheAchievementGap18 <- closingTheAchievementGap$sqr_2018_hs_closing_the_achievement_gap
closingTheAchievementGap19 <- closingTheAchievementGap$sqr_2019_hs_closing_the_achievement_gap


#subset each table into its own data.table for comparison
targets12 <- targets$sqr_2012_hs_targets
targets13 <- targets$sqr_2013_hs_targets
targets14 <- targets$sqr_2014_hs_targets
targets15 <- targets$sqr_2015_hs_targets
targets16 <- targets$sqr_2016_hs_targets
targets17 <- targets$sqr_2017_hs_targets
targets18 <- targets$sqr_2018_hs_targets
targets19 <- targets$sqr_2019_hs_targets

#subset each table into its own data.table for comparison
framework12 <- framework$sqr_2012_hs_framework
framework13 <- framework$sqr_2013_hs_framework
framework14 <- framework$sqr_2014_hs_framework
framework15 <- framework$sqr_2015_hs_framework
framework16 <- framework$sqr_2016_hs_framework
framework17 <- framework$sqr_2017_hs_framework
framework18 <- framework$sqr_2018_hs_framework
framework19 <- framework$sqr_2019_hs_framework

# compare the first two table names, make changes as necessary, then combine. (possible column order)
summary12[, .(colsNotInCommon = outersect(names(summary12), names(summary13)))]
summary12[, .(colsInCommon = intersect(names(summary12), names(summary13)))]
# cbind will recycle the shorter vector, just for inspection purposes
cbind(summmary12 = names(summary12), summary13 = names(summary13)) 
 #summary12 change pct to percent
setnames(summary12, gsub("pct", "percent", names(summary12)))
setnames(summary12, gsub("pctStudentsWithDisabilties", "percentStudentsWithDisabilities", names(summary12)))
setnames(summary12, gsub("pctEll", "percentEll", names(summary12)))
setnames(summary12, gsub("pctOverage", "percentOverAge", names(summary12)))
setnames(summary13, gsub("pctOverage", "percentOverAge", names(summary13)))
setnames(summary13, gsub("pct", "percent", names(summary13)))
setnames(summary13, gsub("pctEll", "percentEll", names(summary13)))
setnames(summary13, gsub("pctStudentsWithDisabilties", "percentStudentsWithDisabilities", names(summary13)))

allSummaryTables <- rbind(summary12, summary13, use.names = T, fill = T)

# repeat comparison step
allSummaryTables[, .(colsInCommon = intersect(names(allSummaryTables), names(summary14)))]
allSummaryTables[, .(colsNotInCommon = outersect(names(allSummaryTables), names(summary14)))]
ncol(allSummaryTables)
ncol(summary14)
cbind( allSummaryTables = names(allSummaryTables), summary14 = names(summary14))

setnames(summary14, gsub("strongFamilycommunity", "strongFamilyCommunity", names(summary14)))
setnames(summary14, gsub("percentHraEligible", "percentHRAEligible", names(summary14)))
setnames(summary14, gsub("percentOverage", "percentOverAge", names(summary14)))
setnames(summary14, gsub("pct", "percent", names(summary14)))
## combine summary14 with the rest and then compare summary15
allSummaryTables <- rbind(allSummaryTables, summary14, use.names = T, fill = T)

#continue comparisons from summary '15 to summary '19
allSummaryTables[, . (colsInCommon = intersect(names(allSummaryTables), names(summary15)))]
allSummaryTables[, . (colsNotInCommon = outersect(names(allSummaryTables), names(summary15)))]
ncol(allSummaryTables)
ncol(summary15)
cbind( allSummaryTables = names(allSummaryTables), summary15 = names(summary15))
setnames(summary15, gsub("percentOverage", "percentOverAge", names(summary15)))
setnames(summary15, gsub("pct", "percent", names(summary15)))
#changes made was to change "age" to "Age"
allSummaryTables <- rbind(allSummaryTables, summary15, use.names = T, fill = T)


#continue comparisons from summary '16 to summary '19
allSummaryTables[, . (colInCommon = intersect(names(allSummaryTables), names(summary16)))]
allSummaryTables[, . (colsNotInCommon = outersect(names(allSummaryTables), names(summary16)))]
ncol(allSummaryTables)
ncol(summary16)
cbind(allSummaryTables = names(allSummaryTables), summary16 = names(summary16))
setnames(summary16, gsub("percentOverage", "percentOverAge", names(summary16)))
setnames(summary16, gsub("pct", "percent", names(summary16)))
#changes made was to change "age" to "Age"
allSummaryTables <- rbind(allSummaryTables, summary16, use.names = T, fill = T)

#continue comparisons from summary '17 to summary '19
allSummaryTables[, . (colInCommon = intersect(names(allSummaryTables), names(summary17)))]
allSummaryTables[, . (colsNotInCommon = outersect(names(allSummaryTables), names(summary17)))]
ncol(allSummaryTables)
ncol(summary17)
cbind(allSummaryTables = names(allSummaryTables), summary17 = names(summary17))
setnames(summary17, gsub("percentOverage", "percentOverAge", names(summary17)))
setnames(summary17, gsub("pct", "percent", names(summary17)))
#changes made was to change "age" to "Age"
allSummaryTables <- rbind(allSummaryTables, summary17, use.names = T, fill = T)


#continue comparisons from summary '18 to summary '19
allSummaryTables[, . (colInCommon = intersect(names(allSummaryTables), names(summary18)))]
allSummaryTables[, . (colsNotInCommon = outersect(names(allSummaryTables), names(summary18)))]
ncol(allSummaryTables)
ncol(summary18)
cbind(allSummaryTables = names(allSummaryTables), summary18 = names(summary18))
setnames(summary18, gsub("percentOverage", "percentOverAge", names(summary18)))
setnames(summary18, gsub("pct", "percent", names(summary18)))

#changes made was to change "age" to "Age"
allSummaryTables <- rbind(allSummaryTables, summary17, use.names = T, fill = T)

#continue comparisons to '19
allSummaryTables[, . (colInCommon = intersect(names(allSummaryTables), names(summary19)))]
allSummaryTables[, . (colsNotInCommon = outersect(names(allSummaryTables), names(summary19)))]
ncol(allSummaryTables)
ncol(summary19)
cbind(allSummaryTables = names(allSummaryTables), summary19 = names(summary19))
setnames(summary19, gsub("percentOverage", "percentOverAge", names(summary19)))
setnames(summary19, gsub("pct", "percent", names(summary19)))
setnames(summary19, gsub("pctBlackOrHispanic", "percentBlackOrHispanic", names(summary19)))
#changes made was to change "age" to "Age"
allSummaryTables <- rbind(allSummaryTables, summary19, use.names = T, fill = T)

## repeat for hs additionalInfo tables
additionalInfo12[, .(colsNotInCommon = outersect(names(additionalInfo12), names(additionalInfo12)))]
additionalInfo13[, .(colsInCommon = intersect(names(additionalInfo13), names(additionalInfo13)))]

# cbind will recycle the shorter vector, just for inspection purposes
cbind(additionalInfo12 = names(additionalInfo12), additionalInfo13 = names(additionalInfo13)) 
ncol(additionalInfo12)
ncol(additionalInfo13)
#change casing differenes below
setnames(additionalInfo12, gsub("^pct", "percent", names(additionalInfo12)))
setnames(additionalInfo12, gsub("pct", "Percent", names(additionalInfo12)))
setnames(additionalInfo12, gsub("Pct", "percent", names(additionalInfo12)))
setnames(additionalInfo12, gsub("trig", "Trig", names(additionalInfo12)))
setnames(additionalInfo12, gsub("^Percent", "percent", names(additionalInfo12)))
setnames(additionalInfo12, gsub("recognize", "Recognize", names(additionalInfo12)))
setnames(additionalInfo12, gsub("^Percentage", "percentage", names(additionalInfo12)))
setnames(additionalInfo12, gsub("percentageEarningAGradeOfc", "percentageEarningAGradeOfC", names(additionalInfo12)))
setnames(additionalInfo12, gsub("additionalinformationSchool", "additionalInformationSchool", names(additionalInfo12)))
setnames(additionalInfo12, gsub("percentagePassingAcpcccourse", "percentagePassingACpccCourse", names(additionalInfo12)))
setnames(additionalInfo12, gsub("percentEarningAGradeOfcOrHigherForCollegeCredit", 
 "percentEarningAGradeOfCOrHigherForCollegeCredit", names(additionalInfo12)))
setnames(additionalInfo12, gsub("percentEarningADiplomaWithACteEndorsement", 
 "percentEarningADiplomaWithActeEndorsement", names(additionalInfo12)))
setnames(additionalInfo12, gsub("ACpcc", "Acpcc", names(additionalInfo12)))
setnames(additionalInfo13, gsub("^pct", "percent", names(additionalInfo13)))
setnames(additionalInfo13, gsub("^Percentage", "percentage", names(additionalInfo13)))
setnames(additionalInfo13, gsub("Percent", "percent", names(additionalInfo13)))
setnames(additionalInfo13, gsub("^Recognize", "recognize", names(additionalInfo13)))
setnames(additionalInfo13, gsub("percentEarningAGradeOfcOrHigherForCollegeCredit", 
 "percentEarningAGradeOfCOrHigherForCollegeCredit", names(additionalInfo13)))
setnames(additionalInfo13, gsub("additionalinformationSchool", "additionalInformationSchool", names(additionalInfo13)))
setnames(additionalInfo13, gsub("percentagePassingAcpcccourse", "percentagePassingACpccCourse", names(additionalInfo13)))
setnames(additionalInfo13, gsub("percentEarningAGradeOfcOrHigherForCollegeCredit", 
 "percentEarningAGradeOfCOrHigherForCollegeCredit", names(additionalInfo13)))
setnames(additionalInfo13, gsub("percentEarningADiplomaWithACteEndorsement", 
 "percentEarningADiplomaWithActeEndorsement", names(additionalInfo13)))
setnames(additionalInfo13, gsub("^Cuny", "cuny", names(additionalInfo13)))
setnames(additionalInfo13, gsub("ACpcc", "Acpcc", names(additionalInfo13)))
setnames(additionalInfo13, gsub("trig", "Trig", names(additionalInfo13)))
setnames(additionalInfo13, gsub("pct", "Percent", names(additionalInfo13)))
#combine then compare combined to additionalInfo14
allAdditionalInfoTables <- rbind(additionalInfo12, additionalInfo13, use.names = T, fill = T)

#continue comparisons from additionalInfo '14 to additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo14)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo14)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo14)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo14 = names(additionalInfo14)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo14)
#change casing differences below
setnames(additionalInfo14, gsub("^Percentage", "percentage", names(additionalInfo14)))
setnames(additionalInfo14, gsub("^Cuny", "cuny", names(additionalInfo14)))
setnames(additionalInfo14, gsub("recognize", "Recognize", names(additionalInfo14)))
setnames(additionalInfo14, gsub("PercentageEarningAGradeOfcOrHigherForcollegecredit", 
 "PercentageEarningAGradeOfCOrHigherForCollegeCredit", names(additionalInfo14)))
setnames(additionalInfo14, gsub("plus", "Plus", names(additionalInfo14)))
setnames(additionalInfo14, gsub("additionalinformationSchool", "additionalInformationSchool", names(additionalInfo14)))
setnames(additionalInfo14, gsub("PercentagePassingAcpcccourse", "PercentagePassingAcpccCourse", names(additionalInfo14)))
setnames(additionalInfo14, gsub("chemistry", "Chemistry", names(additionalInfo14)))
setnames(additionalInfo14, gsub("ACT", "Act", names(additionalInfo14)))
setnames(additionalInfo14, gsub("college", "College", names(additionalInfo14)))
setnames(additionalInfo14, gsub("critical", "Critical", names(additionalInfo14)))
setnames(additionalInfo14, gsub("ACpcc", "Acpcc", names(additionalInfo14)))
setnames(additionalInfo14, gsub("trig", "Trig", names(additionalInfo14)))
setnames(additionalInfo14, gsub("Percentage", "percentage", names(additionalInfo14)))
setnames(additionalInfo14, gsub("cripercent", "criPercentage", names(additionalInfo14)))
setnames(additionalInfo14, gsub("^College", "college", names(additionalInfo14)))
#combine then compare combined to additionalInfo14
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo14, use.names = T, fill = T)

#continue comparisons from additionalInfo '15 to additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo15)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo15)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo15)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo15 = names(additionalInfo15)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo15)
#change casing differences below
setnames(additionalInfo15, gsub("^pct", "percent", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentPassing", "percentPassing", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentEarning", "percentEarning", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentAttaining", "percentAttaining", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentOf", "percentOf", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentCollege", "percentCollege", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentAt", "percentAt", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PercentScoring", "percentScoring", names(additionalInfo15)))
setnames(additionalInfo15, gsub("^recognize", "Recognize", names(additionalInfo15)))
setnames(additionalInfo15, gsub("pct", "percent", names(additionalInfo15)))
setnames(additionalInfo15, gsub("cUNY", "cuny", names(additionalInfo15)))
setnames(additionalInfo15, gsub("CUNY", "Cuny", names(additionalInfo15)))
setnames(additionalInfo15, gsub("^Cuny", "cuny", names(additionalInfo15)))
setnames(additionalInfo15, gsub("nYS", "nys", names(additionalInfo15)))
setnames(additionalInfo15, gsub("perCent", "percent", names(additionalInfo15)))
setnames(additionalInfo15, gsub("plus", "Plus", names(additionalInfo15)))
setnames(additionalInfo15, gsub("sChool", "school", names(additionalInfo15)))
setnames(additionalInfo15, gsub("sCoring", "scoring", names(additionalInfo15)))
setnames(additionalInfo15, gsub("sCore", "score", names(additionalInfo15)))
setnames(additionalInfo15, gsub("voCational", "vocational", names(additionalInfo15)))
setnames(additionalInfo15, gsub("additionalinformationSchool", "additionalInformationSchool", names(additionalInfo15)))
setnames(additionalInfo15, gsub("cRI", "cri", names(additionalInfo15)))
setnames(additionalInfo15, gsub("Cri", "cri", names(additionalInfo15)))
setnames(additionalInfo15, gsub("publiCServiCe18Months", "publiCServiCe18Months", names(additionalInfo15)))
setnames(additionalInfo15, gsub("SCore", "Score", names(additionalInfo15)))
setnames(additionalInfo15, gsub("postseCondary", "postsecondary", names(additionalInfo15)))
setnames(additionalInfo15, gsub("SCienCe", "Science", names(additionalInfo15)))
setnames(additionalInfo15, gsub("critiCal", "critical", names(additionalInfo15)))
setnames(additionalInfo15, gsub("PhysiCs", "Physics", names(additionalInfo15)))
setnames(additionalInfo15, gsub("percentPassingACPCCCourse", "percentPassingAcpccCourse", names(additionalInfo15)))
setnames(additionalInfo15, gsub("ACT", "Act", names(additionalInfo15)))
setnames(additionalInfo15, gsub("critical", "Critical", names(additionalInfo15)))
setnames(additionalInfo15, gsub("trig", "Trig", names(additionalInfo15)))
setnames(additionalInfo15, gsub("Percentage", "percentage", names(additionalInfo15)))
setnames(additionalInfo15, gsub("cripercent", "criPercentage", names(additionalInfo15)))
setnames(additionalInfo15, gsub("^College", "college", names(additionalInfo15)))
#combine then compare combined to additionalInfo15
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo15, use.names = T, fill = T)

#continue comparisons from additionalInfo '16 to additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo16)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo16)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo16)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo16 = names(additionalInfo16)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo16)
#change casing differences below
setnames(additionalInfo16, gsub("CUNY", "Cuny", names(additionalInfo16)))
setnames(additionalInfo16, gsub("ACT", "Act", names(additionalInfo16)))
setnames(additionalInfo16, gsub("pct", "Percent", names(additionalInfo16)))
setnames(additionalInfo16, gsub("ACPCC", "Acpcc", names(additionalInfo16)))
setnames(additionalInfo16, gsub("Percentage", "percentage", names(additionalInfo16)))
setnames(additionalInfo16, gsub("cripercent", "criPercentage", names(additionalInfo16)))
setnames(additionalInfo16, gsub("^College", "college", names(additionalInfo16)))
#combine then compare combined to additionalInfo16
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo16, use.names = T, fill = T)

#continue comparisons from additionalInfo '17 to additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo17)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo17)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo17)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo17 = names(additionalInfo17)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo17)
#change casing differences below
setnames(additionalInfo17, gsub("CUNY", "Cuny", names(additionalInfo17)))
setnames(additionalInfo17, gsub("ACT", "Act", names(additionalInfo17)))
setnames(additionalInfo17, gsub("pct", "Percent", names(additionalInfo17)))
setnames(additionalInfo17, gsub("ACPCC", "Acpcc", names(additionalInfo17)))
setnames(additionalInfo17, gsub("Percentage", "percentage", names(additionalInfo17)))
setnames(additionalInfo17, gsub("cripercent", "criPercentage", names(additionalInfo17)))
setnames(additionalInfo17, gsub("^College", "college", names(additionalInfo17)))
#combine then compare combined to additionalInfo16
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo17, use.names = T, fill = T)

#continue comparisons from additionalInfo '18 to additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo18)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo18)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo18)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo18 = names(additionalInfo18)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo18)
#change casing differences below
setnames(additionalInfo18, gsub("CUNY", "Cuny", names(additionalInfo18)))
setnames(additionalInfo18, gsub("ACT", "Act", names(additionalInfo18)))
setnames(additionalInfo18, gsub("pct", "Percent", names(additionalInfo18)))
setnames(additionalInfo18, gsub("ACPCC", "Acpcc", names(additionalInfo18)))
setnames(additionalInfo18, gsub("NYS", "Nys", names(additionalInfo18)))
setnames(additionalInfo18, gsub("Percentage", "percentage", names(additionalInfo18)))
setnames(additionalInfo18, gsub("cripercent", "criPercentage", names(additionalInfo18)))
setnames(additionalInfo18, gsub("^College", "college", names(additionalInfo18)))
#combine then compare combined to additionalInfo16
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo18, use.names = T, fill = T)

#continue comparisons from additionalInfo '19
allAdditionalInfoTables[, .(colsInCommon = intersect(names(allAdditionalInfoTables), names(additionalInfo19)))]
allAdditionalInfoTables[, .(colsNotInCommon = outersect(names(allAdditionalInfoTables), names(additionalInfo19)))]
ncol(allAdditionalInfoTables)
ncol(additionalInfo19)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allAdditionalInfoTables = names(allAdditionalInfoTables), additionalInfo18 = names(additionalInfo19)) 
ncol(allAdditionalInfoTables)
ncol(additionalInfo19)
#change casing differences below 
setnames(additionalInfo19, gsub("CUNY", "Cuny", names(additionalInfo19)))
setnames(additionalInfo19, gsub("ACT", "Act", names(additionalInfo19)))
setnames(additionalInfo19, gsub("pct", "Percent", names(additionalInfo19)))
setnames(additionalInfo19, gsub("ACPCC", "Acpcc", names(additionalInfo19)))
setnames(additionalInfo19, gsub("NYS", "Nys", names(additionalInfo19)))
setnames(additionalInfo19, gsub("Percentage", "percentage", names(additionalInfo19)))
setnames(additionalInfo19, gsub("cripercent", "criPercentage", names(additionalInfo19)))
setnames(additionalInfo19, gsub("^College", "college", names(additionalInfo19)))
#combine then compare combined to additionalInfo16
allAdditionalInfoTables <- rbind(allAdditionalInfoTables, additionalInfo18, use.names = T, fill = T)


## repeat for hs hs studentAchievement tables
# compare the first two table names, make changes as necessary, then combine. (2012 does not have a table called "student_achievement)
studentAchievement13[, .(colsNotInCommon = outersect(names(studentAchievement13), names(studentAchievement14)))]
studentAchievement13[, .(colsInCommon = intersect(names(studentAchievement13), names(studentAchievement14)))]

# cbind will recycle the shorter vector, just for inspection purposes
cbind(studentAchievement13 = names(studentAchievement13), studentAchievement14 = names(studentAchievement14)) 
#studentAchievement case changes below
setnames(studentAchievement13, gsub("pct", "Percent", names(studentAchievement13)))
setnames(studentAchievement14, gsub("plus", "Plus", names(studentAchievement14)))
setnames(studentAchievement14, gsub("Nonremediation", "NonRemediation", names(studentAchievement14)))

#combine then compare combined sqr tables to studentAchievement '15 
allStudentAchievementTables <- rbind(studentAchievement13, studentAchievement14, use.names = T, fill = T)

# repeat comparison step
allStudentAchievementTables[, .(colsInCommon = intersect(names(allStudentAchievementTables), names(studentAchievement15)))]
allStudentAchievementTables[, .(colsNotInCommon = outersect(names(allStudentAchievementTables), names(studentAchievement15)))]
ncol(allStudentAchievementTables)
ncol(studentAchievement15)
cbind( allStudentAchievementTables = names(allStudentAchievementTables), studentAchievement15 = names(studentAchievement15))

#change casing differences below 
setnames(studentAchievement15, gsub("year", "Year", names(studentAchievement15)))
setnames(studentAchievement15, gsub("pct", "Percent", names(studentAchievement15)))
setnames(studentAchievement15, gsub("CRI", "Cri", names(studentAchievement15)))


## combine combined tables with studentAchievement15
allStudentAchievementTables <- rbind(allStudentAchievementTables, studentAchievement15, use.names = T, fill = T)

#continue comparisons from studentAchievement '16 to studentAchievement '19
# repeat comparison step
allStudentAchievementTables[, .(colsInCommon = intersect(names(allStudentAchievementTables), names(studentAchievement16)))]
allStudentAchievementTables[, .(colsNotInCommon = outersect(names(allStudentAchievementTables), names(studentAchievement16)))]
ncol(allStudentAchievementTables)
ncol(studentAchievement16)
cbind( allStudentAchievementTables = names(allStudentAchievementTables), studentAchievement16 = names(studentAchievement16))

#change "pct" to "percent" 
setnames(studentAchievement16, gsub("pct", "Percent", names(studentAchievement16)))

## combine combined tables with studentAchievement16
allStudentAchievementTables <- rbind(allStudentAchievementTables, studentAchievement16, use.names = T, fill = T)

#continue comparisons from studentAchievement '17 to studentAchievement '19
# repeat comparison step
allStudentAchievementTables[, .(colsInCommon = intersect(names(allStudentAchievementTables), names(studentAchievement17)))]
allStudentAchievementTables[, .(colsNotInCommon = outersect(names(allStudentAchievementTables), names(studentAchievement17)))]
ncol(allStudentAchievementTables)
ncol(studentAchievement17)
cbind( allStudentAchievementTables = names(allStudentAchievementTables), studentAchievement17 = names(studentAchievement17))

#change "pct" to "percent" 
setnames(studentAchievement17, gsub("pct", "Percent", names(studentAchievement17)))
## combine combined tables with studentAchievement17
allStudentAchievementTables <- rbind(allStudentAchievementTables, studentAchievement17, use.names = T, fill = T)

#continue comparisons from studentAchievement '18 to studentAchievement '19
# repeat comparison step
allStudentAchievementTables[, .(colsInCommon = intersect(names(allStudentAchievementTables), names(studentAchievement18)))]
allStudentAchievementTables[, .(colsNotInCommon = outersect(names(allStudentAchievementTables), names(studentAchievement18)))]
ncol(allStudentAchievementTables)
ncol(studentAchievement18)
cbind( allStudentAchievementTables = names(allStudentAchievementTables), studentAchievement18 = names(studentAchievement18))

#change "pct" to "percent" 
setnames(studentAchievement18, gsub("pct", "Percent", names(studentAchievement18)))
## combine combined tables with studentAchievement18
allStudentAchievementTables <- rbind(allStudentAchievementTables, studentAchievement18, use.names = T, fill = T)


#continue comparisons to studentAchievement19
# repeat comparison step
allStudentAchievementTables[, .(colsInCommon = intersect(names(allStudentAchievementTables), names(studentAchievement19)))]
allStudentAchievementTables[, .(colsNotInCommon = outersect(names(allStudentAchievementTables), names(studentAchievement19)))]
ncol(allStudentAchievementTables)
ncol(studentAchievement19)
cbind( allStudentAchievementTables = names(allStudentAchievementTables), studentAchievement19 = names(studentAchievement19))

#change "pct" to "percent" 
setnames(studentAchievement19, gsub("pct", "Percent", names(studentAchievement19)))
## combine combined tables with studentAchievement19
allStudentAchievementTables <- rbind(allStudentAchievementTables, studentAchievement19, use.names = T, fill = T)




## repeat for hs hs closingTheAchievementGap tables
# compare the first two table names, make changes as necessary, then combine
closingTheAchievementGap12[, .(colsNotInCommon = outersect(names(closingTheAchievementGap12), names(closingTheAchievementGap13)))]
closingTheAchievementGap12[, .(colsInCommon = intersect(names(closingTheAchievementGap12), names(closingTheAchievementGap13)))]

# cbind will recycle the shorter vector, just for inspection purposes
cbind(closingTheAchievementGap12 = names(closingTheAchievementGap12), closingTheAchievementGap13 = names(closingTheAchievementGap13)) 
#change cases below
setnames(closingTheAchievementGap12, gsub("pct", "Percent", names(closingTheAchievementGap12)))
setnames(closingTheAchievementGap12, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap12)))
setnames(closingTheAchievementGap12, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap12)))
setnames(closingTheAchievementGap12, gsub("year", "Year", names(closingTheAchievementGap12)))
setnames(closingTheAchievementGap12, gsub("PercentPercent", "Percent", names(closingTheAchievementGap12)))
setnames(closingTheAchievementGap12, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap12)))

setnames(closingTheAchievementGap13, gsub("pct", "Percent", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("year", "Year", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("percent", "Percent", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("PercentPercent", "Percent", names(closingTheAchievementGap13)))
setnames(closingTheAchievementGap13, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap13)))

#combine then compare combined sqr tables to closingTheAchievementGap '12-'13
allClosingTheAchievementGapTables <- rbind(closingTheAchievementGap12, closingTheAchievementGap13, use.names = T, fill = T)

# repeat comparison step for closingTheAchievementGap14
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), 
 names(closingTheAchievementGap14)))]

allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), 
 names(closingTheAchievementGap14)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap14)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap14 = names(closingTheAchievementGap14))

#change casing differences below 
setnames(closingTheAchievementGap14, gsub("pct", "Percent", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("year", "Year", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("percent", "Percent", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("PercentPercent", "Percent", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("PercentPercent", "Percent", names(closingTheAchievementGap14)))
setnames(closingTheAchievementGap14, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap14)))

## combine combined tables with closingTheAchievementGap14
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap14, use.names = T, fill = T)

#repeat comparison step for closingTheAchievementGap15
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap15)))]
allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap15)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap15)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap15 = names(closingTheAchievementGap15))

#change casing differences below 
setnames(closingTheAchievementGap15, gsub("pct", "Percent", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("year", "Year", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("percent", "Percent", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("PercentPercent", "Percent", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("PER", "Per", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("CTTOrSETSS", "CttOrSetss", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("PercentPercent", "Percent", names(closingTheAchievementGap15)))
setnames(closingTheAchievementGap15, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap15)))

## combine combined tables with closingTheAchievementGap15
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap15, use.names = T, fill = T)

#repeat comparison step for closingTheAchievementGap16
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap16)))]
allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap16)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap16)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap16 = names(closingTheAchievementGap16))

#change casing differences below 
setnames(closingTheAchievementGap16, gsub("pct", "Percent", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("year", "Year", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("percent", "Percent", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("PercentPercent", "Percent", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("PER", "Per", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("TeachingOrSsetss", "TeachingOrSetss", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("Citywide", "CityWide", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("PercentPercent", "Percent", names(closingTheAchievementGap16)))
setnames(closingTheAchievementGap16, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap16)))

## combine combined tables with closingTheAchievementGap16
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap16, use.names = T, fill = T)


#repeat comparison step for closingTheAchievementGap17
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap17)))]
allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap17)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap17)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap16 = names(closingTheAchievementGap17))

#change casing differences below 
setnames(closingTheAchievementGap17, gsub("pct", "Percent", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("year", "Year", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("percent", "Percent", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("PercentPercent", "Percent", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("PER", "Per", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("TeachingOrSETSS", "TeachingOrSetss", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("Citywide", "CityWide", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("PercentPercent", "Percent", names(closingTheAchievementGap17)))
setnames(closingTheAchievementGap17, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap17)))
## combine combined tables with closingTheAchievementGap '17
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap17, use.names = T, fill = T)


#repeat comparison step for closingTheAchievementGap18
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap18)))]
allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap18)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap18)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap18 = names(closingTheAchievementGap18))

#change casing differences below 
setnames(closingTheAchievementGap18, gsub("pct", "Percent", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("year", "Year", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("percent", "Percent", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("PercentPercent", "Percent", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("PER", "Per", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("TeachingOrSETSS", "TeachingOrSetss", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("Citywide", "CityWide", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("PercentPercent", "Percent", names(closingTheAchievementGap18)))
setnames(closingTheAchievementGap18, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap18)))

## combine combined tables with closingTheAchievementGap18
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap18, use.names = T, fill = T)


#repeat comparison step for closingTheAchievementGap19
allClosingTheAchievementGapTables[, .(colsInCommon = intersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap19)))]
allClosingTheAchievementGapTables[, .(colsNotInCommon = outersect(names(allClosingTheAchievementGapTables), names(closingTheAchievementGap19)))]
ncol(allClosingTheAchievementGapTables)
ncol(closingTheAchievementGap19)
cbind(allClosingTheAchievementGapTables= names(allClosingTheAchievementGapTables), closingTheAchievementGap19 = names(closingTheAchievementGap19))

#change casing differences below 
setnames(closingTheAchievementGap19, gsub("pct", "Percent", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("closingtheachievementgap", "closingTheAchievementGap", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("containedictsetss", "ContainedIctSetss", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("year", "Year", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("percent", "Percent", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("PercentPercent", "Percent", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("Nonremediation", "NonRemediation", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("PER", "Per", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("TeachingOrSETSS", "TeachingOrSetss", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("Citywide", "CityWide", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("PercentPercent", "Percent", names(closingTheAchievementGap19)))
setnames(closingTheAchievementGap19, gsub("Blackhispanic", "BlackHispanic", names(closingTheAchievementGap19)))

## combine combined tables with closingTheAchievementGap19
allClosingTheAchievementGapTables <- rbind(allClosingTheAchievementGapTables, closingTheAchievementGap19, use.names = T, fill = T)



## repeat for hs hs targets tables
# compare the first two table names, make changes as necessary, then combine (no targets12)
targets13[, .(colsNotInCommon = outersect(names(targets13), names(targets14)))]
targets13[, .(colsInCommon = intersect(names(targets14), names(targets14)))]

# cbind will recycle the shorter vector, just for inspection purposes
cbind(targets13 = names(targets13), targets13 = names(targets14)) 
#change cases below
setnames(targets13, gsub("pct", "percent", names(targets13)))
setnames(targets13, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets13)))
setnames(targets13, gsub("Blackhispanic", "BlackHispanic", names(targets13)))
setnames(targets13, gsub("plus", "Plus", names(targets13)))
setnames(targets13, gsub("Regentscc", "RegentsCc", names(targets13)))
setnames(targets13, gsub("Regentsnoncc", "RegentsNonCc", names(targets13)))
setnames(targets13, gsub("PER", "Per", names(targets13)))
setnames(targets13, gsub("90percent", "90Percent", names(targets13)))
setnames(targets13, gsub("Citywide", "CityWide", names(targets13)))


setnames(targets14, gsub("Blackhispanic", "BlackHispanic", names(targets14)))
setnames(targets14, gsub("pct", "percent", names(targets14)))
setnames(targets14, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets14)))
setnames(targets14, gsub("Blackhispanic", "BlackHispanic", names(targets14)))
setnames(targets14, gsub("plus", "Plus", names(targets14)))
setnames(targets14, gsub("Regentscc", "RegentsCc", names(targets14)))
setnames(targets14, gsub("Regentsnoncc", "RegentsNonCc", names(targets14)))
setnames(targets14, gsub("PER", "Per", names(targets14)))
setnames(targets14, gsub("90percent", "90Percent", names(targets14)))
setnames(targets14, gsub("Citywide", "CityWide", names(targets14)))


#combine then compare combined sqr tables to targets '13-'14
allTargetsTables <- rbind(targets13, targets14, use.names = T, fill = T)

# compare the first two table names, make changes as necessary, then combine (no targets12)
allTargetsTables[, .(colsNotInCommon = outersect(names(allTargetsTables), names(targets15)))]
allTargetsTables[, .(colsInCommon = intersect(names(allTargetsTables), names(targets15)))]
ncol(allTargetsTables)
ncol(targets15)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allTargetsTables = names(allTargetsTables), targets15 = names(targets15)) 
#change cases below
setnames(targets15, gsub("pct", "percent", names(targets15)))
setnames(targets15, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets15)))
setnames(targets15, gsub("Blackhispanic", "BlackHispanic", names(targets15)))
setnames(targets15, gsub("plus", "Plus", names(targets15)))
setnames(targets15, gsub("Regentscc", "RegentsCc", names(targets15)))
setnames(targets15, gsub("Regentsnoncc", "RegentsNonCc", names(targets15)))
setnames(targets15, gsub("CTTOrSETSS", "CttOrSetss", names(targets15)))
setnames(targets15, gsub("PER", "Per", names(targets15)))
setnames(targets15, gsub("90percent", "90Percent", names(targets15)))
setnames(targets15, gsub("PER", "Per", names(targets15)))
setnames(targets15, gsub("Citywide", "CityWide", names(targets15)))

#combine then compare combined sqr tables to targets '15
allTargetsTables <- rbind(allTargetsTables, targets15, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no targets12)
allTargetsTables[, .(colsNotInCommon = outersect(names(allTargetsTables), names(targets16)))]
allTargetsTables[, .(colsInCommon = intersect(names(allTargetsTables), names(targets16)))]
ncol(allTargetsTables)
ncol(targets16)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allTargetsTables = names(allTargetsTables), targets16 = names(targets16)) 
#change cases below
setnames(targets16, gsub("pct", "percent", names(targets16)))
setnames(targets16, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets16)))
setnames(targets16, gsub("Blackhispanic", "BlackHispanic", names(targets16)))
setnames(targets16, gsub("plus", "Plus", names(targets16)))
setnames(targets16, gsub("Regentscc", "RegentsCc", names(targets16)))
setnames(targets16, gsub("Regentsnoncc", "RegentsNonCc", names(targets16)))
setnames(targets16, gsub("CTTOrSETSS", "CttOrSetss", names(targets16)))
setnames(targets16, gsub("TeachingOrSETSS", "TeachingOrSetss", names(targets16)))
setnames(targets16, gsub("PER", "Per", names(targets16)))
setnames(targets16, gsub("90percent", "90Percent", names(targets16)))
setnames(targets16, gsub("Citywide", "CityWide", names(targets16)))

#combine then compare combined sqr tables to targets '16
allTargetsTables <- rbind(allTargetsTables, targets16, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no targets12)
allTargetsTables[, .(colsNotInCommon = outersect(names(allTargetsTables), names(targets17)))]
allTargetsTables[, .(colsInCommon = intersect(names(allTargetsTables), names(targets17)))]
ncol(allTargetsTables)
ncol(targets17)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allTargetsTables = names(allTargetsTables), targets17 = names(targets17)) 
#change cases below
setnames(targets17, gsub("pct", "percent", names(targets17)))
setnames(targets17, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets17)))
setnames(targets17, gsub("Blackhispanic", "BlackHispanic", names(targets17)))
setnames(targets17, gsub("plus", "Plus", names(targets17)))
setnames(targets17, gsub("Regentscc", "RegentsCc", names(targets17)))
setnames(targets17, gsub("Regentsnoncc", "RegentsNonCc", names(targets17)))
setnames(targets17, gsub("CTTOrSETSS", "CttOrSetss", names(targets17)))
setnames(targets17, gsub("TeachingOrSETSS", "TeachingOrSetss", names(targets17)))
setnames(targets17, gsub("PER", "Per", names(targets17)))
setnames(targets17, gsub("90percent", "90Percent", names(targets17)))
setnames(targets17, gsub("Citywide", "CityWide", names(targets17)))

#combine then compare combined sqr tables to targets '17
allTargetsTables <- rbind(allTargetsTables, targets17, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no targets12)
allTargetsTables[, .(colsNotInCommon = outersect(names(allTargetsTables), names(targets18)))]
allTargetsTables[, .(colsInCommon = intersect(names(allTargetsTables), names(targets18)))]
ncol(allTargetsTables)
ncol(targets18)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allTargetsTables = names(allTargetsTables), targets18 = names(targets18)) 
#change cases below
setnames(targets18, gsub("pct", "percent", names(targets18)))
setnames(targets18, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets18)))
setnames(targets18, gsub("Blackhispanic", "BlackHispanic", names(targets17)))
setnames(targets18, gsub("plus", "Plus", names(targets18)))
setnames(targets18, gsub("Regentscc", "RegentsCc", names(targets18)))
setnames(targets18, gsub("Regentsnoncc", "RegentsNonCc", names(targets18)))
setnames(targets18, gsub("CTTOrSETSS", "CttOrSetss", names(targets18)))
setnames(targets18, gsub("TeachingOrSETSS", "TeachingOrSetss", names(targets18)))
setnames(targets18, gsub("PER", "Per", names(targets18)))
setnames(targets18, gsub("90percent", "90Percent", names(targets18)))
setnames(targets18, gsub("Citywide", "CityWide", names(targets18)))

#combine then compare combined sqr tables to targets '18
allTargetsTables <- rbind(allTargetsTables, targets18, use.names = T, fill = T)


#compare the first two table names, make changes as necessary, then combine (no targets12)
allTargetsTables[, .(colsNotInCommon = outersect(names(allTargetsTables), names(targets19)))]
allTargetsTables[, .(colsInCommon = intersect(names(allTargetsTables), names(targets19)))]
ncol(allTargetsTables)
ncol(targets19)

# cbind will recycle the shorter vector, just for inspection purposes
cbind(allTargetsTables = names(allTargetsTables), targets19 = names(targets19)) 
#change cases below
setnames(targets19, gsub("pct", "percent", names(targets19)))
setnames(targets19, gsub("Selfcontainedictsetss", "SelfContainedIctSetss", names(targets19)))
setnames(targets19, gsub("Blackhispanic", "BlackHispanic", names(targets19)))
setnames(targets19, gsub("plus", "Plus", names(targets19)))
setnames(targets19, gsub("Regentscc", "RegentsCc", names(targets19)))
setnames(targets19, gsub("Regentsnoncc", "RegentsNonCc", names(targets19)))
setnames(targets19, gsub("CTTOrSETSS", "CttOrSetss", names(targets19)))
setnames(targets19, gsub("TeachingOrSETSS", "TeachingOrSetss", names(targets19)))
setnames(targets19, gsub("PER", "Per", names(targets19)))
setnames(targets19, gsub("90percent", "90Percent", names(targets19)))
setnames(targets19, gsub("Citywide", "CityWide", names(targets19)))

#combine then compare combined sqr tables to targets '19
allTargetsTables <- rbind(allTargetsTables, targets19, use.names = T, fill = T)

## repeat for hs framework tables
# compare the first two table names, make changes as necessary, then combine (no framework 12)
framework14[, .(colsNotInCommon = outersect(names(framework14), names(framework15)))]
framework14[, .(colsInCommon = intersect(names(framework14), names(framework15)))]
ncol(framework14)
ncol(framework15)
# cbind will recycle the shorter vector, just for inspection purposes
cbind(framework14 = names(framework14), framework15 = names(framework15)) 
#change cases below
setnames(framework14, gsub("pct", "Percent", names(framework14)))
setnames(framework14, gsub("instruction", "Instruction", names(framework14)))

setnames(framework15, gsub("pct", "Percent", names(framework15)))
setnames(framework15, gsub("instruction", "Instruction", names(framework15)))

#combine then compare combined sqr tables to framework '14-'15
allFrameworkTables <- rbind(framework14, framework15, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no framework 12)
allFrameworkTables[, .(colsNotInCommon = outersect(names(allFrameworkTables), names(framework16)))]
allFrameworkTables[, .(colsInCommon = intersect(names(allFrameworkTables), names(framework16)))]
ncol(allFrameworkTables)
ncol(framework16)
# cbind will recycle the shorter vector, just for inspection purposes
cbind(allFrameworkTables = names(allFrameworkTables), framework16 = names(framework16)) 
#change cases below
setnames(framework16, gsub("pct", "Percent", names(framework16)))
setnames(framework16, gsub("instruction", "Instruction", names(framework16)))

#combine then compare combined sqr tables to framework '16
allFrameworkTables <- rbind(allFrameworkTables, framework16, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no framework 12)
allFrameworkTables[, .(colsNotInCommon = outersect(names(allFrameworkTables), names(framework17)))]
allFrameworkTables[, .(colsInCommon = intersect(names(allFrameworkTables), names(framework17)))]
ncol(allFrameworkTables)
ncol(framework17)
# cbind will recycle the shorter vector, just for inspection purposes
cbind(allFrameworkTables = names(allFrameworkTables), framework17 = names(framework17)) 
#change cases below
setnames(framework17, gsub("pct", "Percent", names(framework17)))
setnames(framework17, gsub("instruction", "Instruction", names(framework17)))

#combine then compare combined sqr tables to framework '17
allFrameworkTables <- rbind(allFrameworkTables, framework17, use.names = T, fill = T)

# compare the first two table names, make changes as necessary, then combine (no framework 12)
allFrameworkTables[, .(colsNotInCommon = outersect(names(allFrameworkTables), names(framework18)))]
allFrameworkTables[, .(colsInCommon = intersect(names(allFrameworkTables), names(framework18)))]
ncol(allFrameworkTables)
ncol(framework18)
# cbind will recycle the shorter vector, just for inspection purposes
cbind(allFrameworkTables = names(allFrameworkTables), framework18 = names(framework18)) 
#change cases below
setnames(framework18, gsub("pct", "Percent", names(framework18)))
setnames(framework18, gsub("instruction", "Instruction", names(framework18)))

#combine then compare combined sqr tables to framework '18
allFrameworkTables <- rbind(allFrameworkTables, framework18, use.names = T, fill = T)


# compare the first two table names, make changes as necessary, then combine (no framework 12)
allFrameworkTables[, .(colsNotInCommon = outersect(names(allFrameworkTables), names(framework19)))]
allFrameworkTables[, .(colsInCommon = intersect(names(allFrameworkTables), names(framework19)))]
ncol(allFrameworkTables)
ncol(framework19)
# cbind will recycle the shorter vector, just for inspection purposes
cbind(allFrameworkTables = names(allFrameworkTables), framework19 = names(framework19)) 
#change cases below
setnames(framework19, gsub("pct", "Percent", names(framework19)))
setnames(framework19, gsub("instruction", "Instruction", names(framework19)))

#combine then compare combined sqr tables to framework '19
allFrameworkTables <- rbind(allFrameworkTables, framework19, use.names = T, fill = T)


#melt combined table names 

allFrameworkTables <- melt(allFrameworkTables, id.vars = c('dbn', 'schoolName', 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')

allTargetsTables <- melt(allTargetsTables, id.vars = c('dbn', 'schoolName', 'schoolType', 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')

allClosingTheAchievementGapTables <- melt(allClosingTheAchievementGapTables, id.vars = c('dbn', 'schoolName', 
 'schoolType', 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')

allStudentAchievementTables <- melt(allStudentAchievementTables, id.vars = c('dbn', 'schoolName', 'schoolType',
 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')

allAdditionalInfoTables <- melt(allAdditionalInfoTables, id.vars = c('dbn', 'schoolName', 'schoolType', 
 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')

allSummaryTables <- melt(allSummaryTables, id.vars = c('dbn', 'schoolName', 'schoolType', 'schoolYear', 'tableName'),
 variable.name = 'measureName', value.name = 'measureValue')


# Process -----------------------------------------------------------------------------------------------
## Once changes are made for all tables, summary, additonalInfo, closingTheAchievementGap, etc. 
## Combine all tables!

prepSQRTables <- rbind(allSummaryTables, allAdditionalInfoTables, allStudentAchievementTables, 
 allClosingTheAchievementGapTables, allTargetsTables, allFrameworkTables, 
 use.names = T, fill = T)

prepSQRTables <- prepSQRTables[!dbn %in% c("", "DBN")]


## create new column called 'metric'
prepSQRTables[, metric := NA_character_]

#extract specific table names and cast them wide as new columns while populating with values from column names
prepSQRTables[grepl("nCount", measureName, ignore.case = T), `:=` 
 (nCount = measureValue,
 metric = gsub("nCount", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("exceedingTarget", measureName, ignore.case = T), `:=` 
 (exceedingTarget = measureValue,
 metric = gsub("exceedingTargetFor", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("approachingTarget", measureName, ignore.case = T), `:=` 
 (approachingTarget = measureValue,
 metric = gsub("approachingTargetFor", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("meetingTarget", measureName, ignore.case = T), `:=` 
 (meetingTarget = measureValue,
 metric = gsub("meetingTargetFor", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("metricScore", measureName, ignore.case = T), `:=` 
 (metricScore = measureValue,
 metric = gsub("metricScore", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("metricRating", measureName, ignore.case = T), `:=` 
 (metricRating = measureValue,
 metric = gsub("metricRating", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("comparisonGroup", measureName, ignore.case = T), `:=` 
 (comparisonGroup = measureValue,
 metric = gsub("comparisonGroup", "", measureName),
 measureValue = NA)]

prepSQRTables[grepl("metricValue", measureName, ignore.case = T), `:=` 
 (metric = gsub("metricValue", "", measureName))]

prepSQRTables[grepl("measureValue", measureName, ignore.case = T), `:=` 
 (metric = gsub("measureValue", "", measureName))]


#populate metric with measureName values 
prepSQRTables[is.na(metric), metric := measureName]


#Remove years from table names 
prepSQRTables[grepl("[0-9]{4}", metric, ignore.case = T), metric := gsub("[0-9]{4}", "", metric)]

#remove school name from measureValue

prepSQRTables[, metric := toLowerFirst(metric)]

prepSQR <- unique(prepSQRTables[, .(nCount = max(nCount, na.rm = T), 
 measureValue = max(measureValue, na.rm = T), 
 metricRating = max(metricRating, na.rm = T),
 meetingTarget = max(meetingTarget, na.rm = T), 
 approachingTarget = max(approachingTarget, na.rm = T),
 exceedingTarget = max(exceedingTarget, na.rm = T), 
 comparisonGroup = max(comparisonGroup, na.rm = T),
 metricScore = max(metricScore, na.rm = T)),
 .(dbn, schoolName, schoolType, tableName, schoolYear, metric)])



prepSQRTables[grepl("pct", metric, ignore.case = T)]

allMetric <- prepSQRTables[, .(metric = unique(metric))]
# Push Data ---------------------------------------------------------------------------------------------

# ptfinal <- proc.time()- ptb
# 
# loadToRedshift(script = scriptName,
# df = prepSQR,
# schema = "prep_public",
# filename = "sqr_hs_long",
# runtime = ptfinal,
# type = "create")

gWriteData(spreadsheetId = "13rA9tKBxQoekKoiN1cRlcs340sNGy_CM9BtlJWsZma4",
 sheetNames = "metricName",
 dataList = list(allMetric),
 includeHeader = T,
 stagingException = T)
 
 
 
 --


Krystal Briggs Computer Science & Data Analytics Resident

205 East 42nd Street, 4th Floor
New York, NY 10017

Tel    212 645 5110
www.newvisions.org

Facebook   •  Twitter



