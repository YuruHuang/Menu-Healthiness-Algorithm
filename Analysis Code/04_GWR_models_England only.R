#################################################
# In this script, I will run GLM or LMM models  #
#################################################
library(lme4)
library(lmerTest)
library(spgwr)
library(data.table)
library(dplyr)
library(jtools)
library(gridExtra)
library(effects)

poi_lsoa = fread('POI_predicted_matchedLSOA.csv')
poi_lsoa$urban='Rural'
poi_lsoa[poi_lsoa$ru11ind %in% c('A1','B1','C1','C2'),'urban'] ='Urban'

england = poi_lsoa[ctry=='E92000001'] 

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
# create rank values 
england$health_rank = rank(england$predicted_score)

# 2. Run GLM 
model0 = lm(predicted_score ~ imd.x,data = england)
print(summary(model0))
model1 = lm(predicted_score~imd_decile,data= england)
effect_plot(model1,pred = imd_decile, interval = TRUE, data=england)
ggsave(filename = 'IMD_Overall_120522.tiff',width = 4, height = 3.5, device='tiff', dpi=300)

#3. Linear Mixed Models
model2 = lmer(predicted_score~ imd_decile+urban +(1|lsoa11), data=england)
effect_plot(model2,pred = imd_decile, interval = TRUE, data=england, x.label='IMD Deciles',
            y.label='Menu Healthiness',line.thickness = 0.8, cluster='lsoa11',point.size = 0.5,
            cat.pred.point.size = 2,cat.interval.geom = 'linerange')
summary(model2)
as.data.frame(with(effect('imd_decile',model2),cbind(fit,lower,upper)))

# linear mixed models of rank 
model3 = lmer(health_rank~ imd_decile+urban +(1|lsoa11), data=england)
effect_plot(model3,pred = imd_decile, interval = TRUE, data=england, x.label='IMD Deciles',
            y.label='Menu Healthiness',line.thickness = 0.8, cluster='lsoa11',point.size = 0.5,
            cat.pred.point.size = 2,cat.interval.geom = 'linerange')
summary(model3)

#4. Linear mixed models by type of food outlets 
england[type %in% c("fast food and takeaway outlets","fast food delivery services",
                    "fish and chip shops"), type:='fast food and takeaways']


create_effect_plot = function(var){
  dat = england[england$type==var]
  model= lmer(predicted_score~ imd_decile+urban +(1|lsoa11), data=dat)
  return (effect_plot(model,pred = imd_decile, interval = TRUE, data=dat, x.label='IMD Deciles',
              y.label='Menu Healthiness',line.thickness = 0.8, cluster='lsoa11',point.size = 0.5,
              cat.pred.point.size = 2,cat.interval.geom = 'linerange',
              main.title=var))
}

p1 = create_effect_plot('restaurants')
p2 = create_effect_plot("pubs, bars, and inns")
p3 = create_effect_plot("cafes, snack bars, and tea rooms")
p4 = create_effect_plot("fast food and takeaways" )

p_a=grid.arrange(p1, p2,p3,p4,nrow = 2)

ggsave(filename = 'IMD_ByType_120522.tiff', p_a,width = 8, height = 7, device='tiff', dpi=300)
