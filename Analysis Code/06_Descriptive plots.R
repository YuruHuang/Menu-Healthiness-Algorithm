########################################
#  Generate graphs for the manuscript ##
########################################
library(ggplot2)
library(gmodels)
library("ggsci")

poi_lsoa[type %in% c("fast food and takeaway outlets","fast food delivery services",
                    "fish and chip shops"), type:='fast food and takeaways']

plot_histogram <- function(df, feature) {
  plt <- ggplot(df, aes(x=eval(parse(text=feature)))) +
    geom_histogram(aes(y = ..density..), alpha=0.7, fill="#33AADE", color="black") +
    geom_vline(aes(xintercept=mean(eval(parse(text=feature)))), color="black", linetype="dashed", size=1) +
    labs(x=feature, y = "Density") + theme_bw()+ xlab('Predicted Menu Healthiness Score')
  print(plt)
}

plot_multi_histogram <- function(df, feature, label_column) {
  plt <- ggplot(df, aes(x=eval(parse(text=feature)), fill=eval(parse(text=label_column)))) +
    #geom_histogram(alpha=0.2, position="identity", aes(y = ..density..), color="black") +
    geom_density(alpha=0.3, bw=10*bw)+
    #geom_vline(aes(xintercept=mean(eval(parse(text=feature)))), color="black", linetype="dashed", size=1) +
    labs(x=feature, y = "Density")+scale_fill_npg() + theme_bw() +xlab('Predicted Menu Healthiness')
  plt + guides(fill=guide_legend(title='Type of Food Outlets'))}

bw <- bw.nrd0(poi_lsoa$predicted_score)
plot_multi_histogram(poi_lsoa, 'predicted_score','type')
ggsave(filename = 'PredictedScore_type_density 130522.tiff',width = 7, height = 3, device='tiff', dpi=300)


je_lsoa$Source = 'Just Eat'
poi_lsoa$Source = 'Ordnance Survey'

plot_histogram(poi_lsoa,'predicted_score')
ggsave(filename = 'PredictedScore_130522.tiff',width = 5, height = 3, device='tiff', dpi=300)
t.test(poi_lsoa$predicted_score)

poi_lsoa %>% group_by(type) %>% summarise(gmodels::ci(predicted_score))


rbind.da(je_lsoa[,c('predict','Source')], poi_lsoa[,c('predicted_score','Source')])

                      