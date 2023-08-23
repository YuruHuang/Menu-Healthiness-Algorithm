#################################################
# In this script, I will run GLM or LMM models  #
#################################################
library(lme4)
library(lmerTest)
library(spgwr)
library(data.table)
library(dplyr)
library(ggplot2)
library(jtools)
library(ggeffects)

poi_lsoa = fread('POI_predicted_matchedLSOA.csv')
poi_lsoa$urban='Rural'
poi_lsoa[poi_lsoa$ru11ind %in% c('A1','B1','C1','C2'),'urban'] ='Urban'

england = poi_lsoa[ctry=='E92000001'] 
table(england$pos_accuracy)

# 1. create IMD ranking deciles for each country 
create_deciles = function(data){
  # first summarise it on the lsoa level
  dat_lsoa = data %>% group_by(lsoa11) %>% summarise(imd = unique(imd))
  # create deciles 
  dat_lsoa$imd_decile = factor(ntile(-dat_lsoa$imd,10))
  dat_lsoa$imd_decile_cat = dat_lsoa$imd_decile
  levels(dat_lsoa$imd_decile_cat) = c('Least','2','3','4','5','6','7','8',
                                      '9','Most')
  # match back to the dataset 
  data = left_join(data, dat_lsoa, by='lsoa11')
  return(data)
}

england = create_deciles(england)

# 2. Run GLM 
model0 = lm(predicted_score ~ imd.x,data = england)
print(summary(model0))
model1 = lm(predicted_score~imd_decile,data= england)
effect_plot(model1,pred = imd_decile, interval = TRUE, data=england)

#3. Linear Mixed Models
model2 = lmer(predicted_score~ imd_decile_cat+urban +(1|lsoa11), data=england)
model2_pred = make_predictions(model2, pred='imd_decile_cat',interval=TRUE)
# number of food outlets on the LSOA level 
england_n = england %>% group_by(lsoa11, imd_decile_cat) %>% summarise(n=n())
model2_n = lm(n~imd_decile_cat, data = england_n)
# construct a database to calculate the 95%CI 
# model2_pred_c<- ggpredict(model2, terms = "imd_decile_cat") the same results as the make_predictions function
model2_n_pred = make_predictions(model2_n, pred="imd_decile_cat",interval=TRUE, int.type='confidence')
model2_forplot = left_join(model2_pred, model2_n_pred, by='imd_decile_cat')
model2_con = lmer(predicted_score~ as.numeric(imd_decile)+urban +(1|lsoa11), data=england)
summary(model2_con)

# 4. Linear mixed models by type of food outlets 
england[type %in% c('fast food and takeaway outlets',
                    "fast food delivery services",
                    "fish and chip shops"),type:='fast food and takeaways']
types = unique(england$type)
types

## aggregate data for the plot 
data_forplot_all = data.frame()
for (rest_t in types){
  print(rest_t)
  data_temp = england[type==rest_t]
  model_con = lmer(predicted_score~ imd_decile_cat + urban +(1|lsoa11), data=data_temp)
  model_con_pred = make_predictions(model_con, pred='imd_decile_cat',interval=TRUE)
  type_n = data_temp %>% group_by(lsoa11, imd_decile_cat) %>% summarise(n=n())
  model_n = lm(formula = n~imd_decile_cat, data = type_n)
  n_pred = make_predictions(model_n, pred='imd_decile_cat',interval=TRUE)
  data_forplot = left_join(model_con_pred, n_pred, by='imd_decile_cat')
  data_forplot$type = rest_t
  data_forplot_all = rbind(data_forplot_all, data_forplot)
}

## test for p 
for (rest_t in types){
  print(rest_t)
  data_temp = england[type==rest_t]
  type_n = data_temp %>% group_by(lsoa11, imd_decile) %>% summarise(n=n())
  model_n = lm(formula = n~as.character(imd_decile), data = type_n)
  print(summary(model_n))
}

# 5. LSOA level total_n 
lsoa_england = england %>% group_by(lsoa11,imd_decile) %>% summarise(total_n = n())
model4 = glm(total_n ~ imd_decile , data=lsoa_england)
effect_plot(model4,pred = imd_decile, interval = TRUE, data=england, x.label='IMD Deciles',
            y.label='Total number of food outlets',line.thickness = 0.8, cluster='lsoa11',point.size = 0.5,
            cat.pred.point.size = 2,cat.interval.geom = 'linerange')

