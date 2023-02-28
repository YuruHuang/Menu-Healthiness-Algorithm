#############################################
#   Match the justeat score with IMD      #
#############################################
library(data.table)
library(dplyr)
library(openxlsx)
library(readr)
library(jtools)
library(tidyr)

justeat =fread('JustEat_extracted_220422.csv')

dim(justeat)
head(justeat)

justeat$predict

# justeat score should range between 0 -12 (below 0 -->0, above 12 -->12)
justeat = data.table(justeat)
justeat[predict>12,predict:=12]
justeat[predict<0,predict:=0]

lookup_table = readr::read_csv('NSPL_AUG_2021_UK/Data/NSPL_AUG_2021_UK.csv', guess_max = 100000)
View(head(lookup_table,20L))
je_lsoa = left_join(justeat,lookup_table, by=c('postcode'='pcds'))

###--> how many of them cannot be matched? 
sum(is.na(je_lsoa$pcd2)) #916 unmatched postcodes --> 0.5% what are these?
je_lsoa[is.na(pcd2),'postcode'] ##delete these unmatched
je_lsoa = je_lsoa[!is.na(pcd2),]
dim(je_lsoa)

## convert the justeat scores to ratings 
je_lsoa$rating= 'NA'
je_lsoa[predict<5.33, rating:='0']
je_lsoa[predict>=5.33 & predict <6.66, rating:='1']
je_lsoa[predict>=6.66 & predict <7.99, rating:='2']
je_lsoa[predict>=7.99& predict <9.33, rating:='3']
je_lsoa[predict>=9.33& predict <10.66, rating:='4']
je_lsoa[predict>=10.66, rating:='5']

fwrite(je_lsoa,'je_predicted_matchedLSOA.csv') #IMD column is the rank
## next, match the aggregated data to IMD scores (2019, England only)
imd = read.csv('imd2019lsoa.csv') # English IMD scores only --> not exactly comparable 
head(imd)

# reshape the file 
imd = imd %>% spread(Measurement, Value)
imd= imd[imd$Indices.of.Deprivation=="a. Index of Multiple Deprivation (IMD)",]
dim(imd)

imd$imd_decile = ntile(imd$Rank,10)

lsoa_summary_poi =  left_join(je_lsoa,imd,by=c('lsoa11'='FeatureCode'))
dim(lsoa_summary_poi)
lsoa_summary_poi= lsoa_summary_poi[!is.na(lsoa_summary_poi$Score),]
dim(lsoa_summary_poi) #--> England only


## divide imd score into decile 
lsoa_summary_poi$Decile = factor(lsoa_summary_poi$Decile)
lsoa_avghs = lm(predict ~  Decile,data = lsoa_summary_poi)
effect_plot(lsoa_avghs,pred = Decile, interval = TRUE)
