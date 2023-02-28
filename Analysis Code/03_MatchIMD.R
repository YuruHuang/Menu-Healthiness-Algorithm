#############################################
#   Match the predicted score with IMD      #
#############################################
library(data.table)
library(dplyr)
library(openxlsx)
library(readr)
library(jtools)
library(tidyr)

predicted = fread('poi_fastai_220722.csv')
colnames(predicted)[29]<-'predicted_score'

dim(predicted)
head(predicted)

# match the postcodes to corresponding LSOAs 
hist(predicted$predicted_score)

# predicted score should range between 0 -12 (below 0 -->0, above 12 -->12)
predicted = data.table(predicted)
predicted[predicted_score>12,predicted_score:=12]
predicted[predicted_score<0,predicted_score:=0]

lookup_table = readr::read_csv('NSPL_AUG_2021_UK/Data/NSPL_AUG_2021_UK.csv', guess_max = 100000)
View(head(lookup_table,20L))
poi_lsoa = left_join(predicted,lookup_table, by=c('postcode'='pcds'))

###--> how many of them cannot be matched? 
sum(is.na(poi_lsoa$pcd2)) #916 unmatched postcodes --> 0.5% what are these?
poi_lsoa[is.na(pcd2),'postcode'] ##delete these unmatched
poi_lsoa = poi_lsoa[!is.na(pcd2),]
dim(poi_lsoa)

## convert the predicted scores to ratings 
poi_lsoa$rating= 'NA'
poi_lsoa[predicted_score<5.33, rating:='0']
poi_lsoa[predicted_score>=5.33 & predicted_score <6.66, rating:='1']
poi_lsoa[predicted_score>=6.66 & predicted_score <7.99, rating:='2']
poi_lsoa[predicted_score>=7.99& predicted_score <9.33, rating:='3']
poi_lsoa[predicted_score>=9.33& predicted_score <10.66, rating:='4']
poi_lsoa[predicted_score>=10.66, rating:='5']

fwrite(poi_lsoa,'POI_predicted_matchedLSOA_fastai_220722.csv') #IMD column is the rank


## next, match the aggregated data to IMD scores (2019, England only)
imd = read.csv('imd2019lsoa.csv') # English IMD scores only --> not exactly comparable 
head(imd)

# reshape the file 
imd = imd %>% spread(Measurement, Value)
imd= imd[imd$Indices.of.Deprivation=="a. Index of Multiple Deprivation (IMD)",]
dim(imd)

imd$imd_decile = ntile(imd$Rank,10)

lsoa_summary_poi =  left_join(poi_lsoa,imd,by=c('lsoa11'='FeatureCode'))
dim(lsoa_summary_poi)
lsoa_summary_poi= lsoa_summary_poi[!is.na(lsoa_summary_poi$Score),]
dim(lsoa_summary_poi) #--> England only


## divide imd score into decile 
lsoa_summary_poi$Decile = factor(lsoa_summary_poi$Decile)
lsoa_avghs = lm(predicted_score ~  Decile,data = lsoa_summary_poi)
effect_plot(lsoa_avghs,pred = Decile, interval = TRUE)
