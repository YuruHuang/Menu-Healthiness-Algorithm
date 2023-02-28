######################################
## attempt to improve Louis' model ##
#####################################
library(readr)
library(dplyr)
library(data.table)
library(ggplot2)
library(MASS)
library(broom)

uhr = read_csv('supplementary.csv')
colnames(uhr)

###################### before adding non-linear terms------->
# Fit the full model -> the original model Louis presented 
full.model <- lm(`Expert health score` ~., data = uhr[3:18])
# Stepwise regression model
step.model <- stepAIC(full.model, direction = "both", 
                      trace = FALSE)
summary(step.model)

##################### Remove multi-size items -------------->
# Fit the full model 
full.model2 <- lm(`Expert health score` ~., data = uhr[c(3:4, 6:18)])
# Stepwise regression model
step.model2 <- stepAIC(full.model2, direction = "both", 
                      trace = FALSE)
summary(step.model2) ## could be overfitting if we actually come up with spline terms based on the distribution of the data 

for (var in colnames(uhr)[4:18]){
  print(var)
  print(ggplot(data = uhr, aes(x = uhr[[var]], y = `Expert health score`)) +
    geom_point() + xlab(var)+
    # geom_smooth(method = "lm", col = "blue", se = F) +
    geom_smooth(method = "loess", col = "red", se = T))
}

# modify each terms to improve the prediction
# linear: multi-size, smaller portions, healthier options, 
# 1: special offers
uhr$specialOffers = ifelse(uhr$`Special offers`>10,10,uhr$`Special offers`)
sum(uhr$`Special offers`>10)/dim(uhr)[1]
# 2. desserts: quadratic term
# 3. Salads: quadratic term
# 3. Chips: 
uhr$chips = ifelse(uhr$Chips>15,15,uhr$Chips)
sum(uhr$Chips>15)/dim(uhr)[1]
# 4. dietary requirements
uhr$diet_r = ifelse(uhr$`Dietary requirements`>20,20,uhr$`Dietary requirements`)
# 5. Salads 
uhr$salads = ifelse(uhr$Salads>20,20,uhr$Salads)

###################### after adding non-linear terms------->
# Fit the full model 
full.model.nonlinear<- lm(`Expert health score` ~specialOffers+
                   `Smaller portions`+`Healthy/ier options`+diet_r+
                   Desserts+ salads + chips+ Vegetables+`Nutrition info`+
                   `Sugary drinks`+`Diet drinks`+ Milk + Water+ Alcohol, data= uhr)
# Stepwise regression model
step.model.nonlinear <- stepAIC(full.model.nonlinear, direction = "both", 
                      trace = FALSE)
summary(step.model.nonlinear)

summ(step.model.nonlinear)
export_summs(step.model.nonlinear, ci_level=0.95,error_format ="[{conf.low}, {conf.high}]",to.file = 'word',file.name="ModifiedLouisModel_210422.docx")


#################### desserts and salads ----------------->
# desserts_lm = lm(`Expert health score`~Desserts,data = uhr)
# desserts_poly = lm(`Expert health score`~poly(Desserts,2),data = uhr)
# desserts_lm.aug <- augment(desserts_lm, uhr)
# desserts_poly.aug<- augment(desserts_poly, uhr)
# 
# ggplot(uhr, aes(x = Desserts, y = `Expert health score`)) +
#   geom_point() +
#   geom_line(data = desserts_lm.aug, aes(x = Desserts, y = .fitted), 
#             col = "blue", size = 1.25) +
#   geom_line(data = desserts_poly.aug, aes(x = Desserts, y = .fitted),
#             col = "black", size = 1.25) 
# 
# salads_lm = lm(`Expert health score`~Salads,data = uhr)
# salads_poly = lm(`Expert health score`~poly(Salads,2),data = uhr)
# salads_lm.aug <- augment(salads_lm, uhr)
# salads_poly.aug<- augment(salads_poly, uhr)
# 
# ggplot(uhr, aes(x = Salads, y = `Expert health score`)) +
#   geom_point() +
#   geom_line(data = salads_lm.aug, aes(x = Salads, y = .fitted), 
#             col = "red", size = 1.25) +
#   geom_line(data = salads_poly.aug, aes(x = Salads, y = .fitted),
#             col = "black", size = 1.25) + 
#   geom_smooth(method='loess')+
#   geom_text(x = 33, y = 9.8, label = "Linear Fit", col = "red") +
#   geom_text(x = 8, y = 7.5, label = "Quadratic Fit", col = "black") +
#   geom_text(x = 20, y = 9.5, label = "Loess Smoothing", col = "blue") +
#   labs(title = "Linear and Quadratic Fits Predicting Expert Scores with the Number of Salads") +
#   theme_bw()
# 
# 
#   
