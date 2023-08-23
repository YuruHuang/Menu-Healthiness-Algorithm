###################################
# Extracting Model metrics (new )#
##################################


library(data.table)
library(dplyr)
library(stringr)
source('01_Metrics_extraction_JE_220408.R')


# read in the August data from Just Eat 
menus = fread('C:\\Users\\yh459\\OneDrive - University of Cambridge\\OS POI\\menus_all_190821.csv')

# Extract the price information 
menus$price = str_extract(menus$`Item Price`, pattern='[0-9]+\\.[0-9]+')
# Extract the attributes 
menus_metrics = setDT(menus)[ , list(Desserts=extract_desserts(.SD),
                                           Vegetables=extract_vegetables(.SD), 
                                           Salads=extract_salads(.SD),
                                           Chips=extract_chips(.SD), 
                                           Water=extract_water(.SD), 
                                           Milk = extract_milk(.SD),
                                           'Special Offers' = extract_specialoffers(.SD),
                                           rest_name = unique(`Restaurant Name`),
                                           address = unique(Address),
                                           cuisines = unique(Cuisines),
                                           url = unique(URL),
                                           n_review = unique(`Number of Reviews`),
                                           rating_review = unique(`Average Review Ratings`),
                                           price_avg = mean(as.numeric(price),na.rm = TRUE),
                                           price_min = min(as.numeric(price), na.rm=TRUE),
                                           price_max = max(as.numeric(price), na.rm=TRUE)),
                              by = .(`Restaurant ID`)]


# Extract the zip code 
menus_metrics$postcode = str_extract(pattern='(?:[A-Z][A-HJ-Y]?[0-9][0-9A-Z]? ?[0-9][A-Z]{2}|GIR ?0A{2})',toupper(menus_metrics$address))
menus_metrics$postcode_district = str_split(menus_metrics$postcode,' ',simplify = TRUE)[,1]
length(unique(menus_metrics$postcode_district)) # 2199 unique postcode districts 
menus_metrics$review = str_extract(pattern = '[0-9]+',menus_metrics$n_reviews)

class(menus_metrics$`Special Offers`)
menus_metrics$specialOffers = ifelse(menus_metrics$`Special Offers`>10,10,menus_metrics$`Special Offers`)
menus_metrics$chips = ifelse(menus_metrics$Chips>15,15,menus_metrics$Chips)
menus_metrics$salads = ifelse(menus_metrics$Salads>20,20,menus_metrics$Salads)

menus_metrics$predict = predict(step.model.nonlinear,menus_metrics)
menus_metrics$rating2 = 'NA'
menus_metrics = data.table(menus_metrics)
menus_metrics[predict<5.33, rating2:='0']
menus_metrics[predict>=5.33 & predict <6.66, rating2:='1']
menus_metrics[predict>=6.66 & predict <7.99, rating2:='2']
menus_metrics[predict>=7.99& predict <9.33, rating2:='3']
menus_metrics[predict>=9.33& predict <10.66, rating2:='4']
menus_metrics[predict>=10.66, rating2:='5']

table(menus_metrics$rating2)

saveRDS(menus_metrics, file = "menus_metrics.rds")
#menus_metrics = read_csv('JustEat_extracted_170222.csv')
fwrite(menus_metrics,'JustEat_extracted_220422.csv')

# price by ratings
menus_metrics %>% group_by(rating2) %>% summarise(mean(price_avg))
