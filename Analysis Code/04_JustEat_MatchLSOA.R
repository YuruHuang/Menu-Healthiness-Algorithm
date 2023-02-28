## Match Just Eat postcodes to LSOA ##
library(data.table)
justeat = fread('JustEat_extracted_220422.csv')

lookup_table = readr::read_csv('/Users/huangyuru/Downloads/NSPL_AUG_2021_UK/Data/NSPL_AUG_2021_UK.csv', guess_max = 100000)
View(head(lookup_table,20L))

justeat_lsoa = left_join(justeat, lookup_table,by=c('postcode'='pcds'))

fwrite('JustEat_extracted_220422_lsoa.csv')