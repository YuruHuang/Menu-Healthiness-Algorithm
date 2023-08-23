library(dplyr)

# Summarize POI and JE data at the LA (Local Authority) level by calculating the mean score
poi_summary_la <- poi_lsoa %>%
  group_by(laua) %>%
  summarise(mean_score_poi = mean(predicted_score))

je_summary_la <- je_lsoa %>%
  group_by(laua) %>%
  summarise(mean_score_je = mean(predict))

# View the summarized POI data
View(poi_summary_la)

# Calculate rank and decile rank for both POI and JE data
poi_summary_la$score_rank_poi <- rank(poi_summary_la$mean_score_poi)
je_summary_la$score_rank_je <- rank(je_summary_la$mean_score_je)
poi_summary_la$decile_rank_poi <- ntile(poi_summary_la$mean_score_poi, 10)
je_summary_la$decile_rank_je <- ntile(je_summary_la$mean_score_je, 10)

# Merge the POI and JE datasets by Local Authority (laua)
merged_data <- left_join(poi_summary_la, je_summary_la, by = 'laua')

# Calculate the differences in rank and decile rank between POI and JE
merged_data$rank_difference <- merged_data$score_rank_poi - merged_data$score_rank_je
merged_data$decile_rank_difference <- merged_data$decile_rank_poi - merged_data$decile_rank_je

# View the merged dataset
View(merged_data)

# Summary of the relationship between POI and JE rank using a Generalized Linear Model
summary(glm(merged_data$score_rank_poi ~ merged_data$score_rank_je))
