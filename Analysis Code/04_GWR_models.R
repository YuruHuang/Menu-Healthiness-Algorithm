#################################################
# In this script, I will run GWR or LMM models  #
#################################################
library(lme4)
library(lmerTest)
library(spgwr)
library(data.table)
library(dplyr)
library(jtools)

poi_lsoa = fread('POI_predicted_matchedLSOA.csv')

# 0. seperate models for seperate countries 
england = poi_lsoa[ctry=='E92000001'] 
scotland = poi_lsoa[ctry=='S92000003']
wales = poi_lsoa[ctry=='W92000004']

# 1. create IMD ranking deciles for each country 
create_deciles = function(data){
  # first summarise it on the lsoa level
  dat_lsoa = data %>% group_by(lsoa11) %>% summarise(imd = unique(imd))
  # create deciles 
  dat_lsoa$imd_decile = factor(ntile(-dat_lsoa$imd,10))
  # match back to the dataset 
  data = left_join(data, dat_lsoa, by='lsoa11')
  return(data)
}
england = create_deciles(england)
scotland = create_deciles(scotland)
wales = create_deciles(wales)

# 2. Generalised linear models 
for (dat in list(england, scotland,wales)){
  model0 = lm(predicted_score ~ imd.x,data = dat)
  print('-------------------------')
  print(summary(model0))
  model1 = lm(predicted_score~imd_decile,data= dat)
  effect_plot(model1,pred = imd_decile, interval = TRUE, data=dat)
  print(summary(model1))
}

# 3. Linear mixed models 
for (dat in list(england, scotland,wales)){
  print('-------------------------')
  model2 = lmer(predicted_score~ imd_decile+(1|lsoa11), data=dat)
  effect_plot(model2,pred = imd_decile, interval = TRUE, data=dat)
  print(summary(model2))
}

#4. Geospatially weighted regression 
GWRbandwidth <- gwr.sel(predicted_score ~imd_decile, data=england, coords=cbind(lat,lon),adapt=T) 

