##########################
# summarise at la level ##
##########################
library(dplyr)

poi_la = poi_lsoa %>% group_by(laua) %>% summarise(score= mean(predicted_score))
je_la = je_lsoa %>% group_by(laua) %>% summarise(score= mean(predict))


View(poi_la)

# biggest difference between poi and je data in ranks 
poi_la$srank = rank(poi_la$score)
je_la$srank = rank(je_la$score)
poi_la$rank_poi = ntile(poi_la$score,10)
je_la$rank_je = ntile(je_la$score,10)


poi_je = left_join(poi_la, je_la, by='laua')

poi_je$rank_diff = poi_je$srank.x - poi_je$srank.y
poi_je$rank_d_diff = poi_je$rank_poi - poi_je$rank_je

View(poi_je)


summary(glm(poi_je$srank.x~poi_je$srank.y))
