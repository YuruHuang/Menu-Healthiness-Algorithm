library(ggplot2)
library(scales)
library(ggpubr)


# Function factory for secondary axis transforms
train_sec <- function(primary, secondary, na.rm = TRUE) {
  # Thanks Henry Holm for including the na.rm argument!
  from <- range(secondary, na.rm = na.rm)
  to   <- range(primary, na.rm = na.rm)
  # Forward transform for the data
  forward <- function(x) {
    rescale(x, from = from, to = to)
  }
  # Reverse transform for the secondary axis
  reverse <- function(x) {
    rescale(x, from = to, to = from)
  }
  list(fwd = forward, rev = reverse)
}


# PLOTTING ALL -------------------------------------------------------------------------> 

# select contrasting colors 
library(RColorBrewer)
colors = brewer.pal(name = "BrBG",n=10)
col1 = colors[9]
col2 = "dark grey" # oh well, spent the afternoon selecting colors!! not again

# jitter points and error bars - align
myjit <- ggproto("fixJitter", PositionDodge,
                 width = 0.3,
                 dodge.width = 0.3,
                 jit = NULL,
                 compute_panel =  function (self, data, params, scales) 
                 {
                   
                   #Generate Jitter if not yet
                   if(is.null(self$jit) ) {
                     self$jit <-jitter(rep(0, nrow(data)), amount=self$dodge.width)
                   }
                   
                   data <- ggproto_parent(PositionDodge, self)$compute_panel(data, params, scales)
                   
                   data$x <- data$x + self$jit
                   #For proper error extensions
                   if("xmin" %in% colnames(data)) data$xmin <- data$xmin + self$jit
                   if("xmax" %in% colnames(data)) data$xmax <- data$xmax + self$jit
                   data
                 } )

plot_func = function(data, title=None)
  {
  sec <- with(data, train_sec(predicted_score, n))
  ggplot(data, aes(x=imd_decile_cat)) +
  geom_point(aes(y = predicted_score), colour = col1) +
  geom_errorbar(aes(ymax=ymax.x, ymin=ymin.x), width =0, colour=col1)+
  geom_point(aes(y = sec$fwd(n)), colour = col2,position=myjit) +
  geom_errorbar(aes(ymax=sec$fwd(ymax.y), ymin=sec$fwd(ymin.y)), width=0,  colour=col2,position=myjit)+
  ylab('Predicted menu healthiness scores')+
  scale_y_continuous(sec.axis = sec_axis(~sec$rev(.), name = 'Number of food outlets (LSOA level)')) + theme_bw()+  theme(
    axis.title.y.left=element_text(color=col1),
    axis.text.y.left=element_text(color=col1),
    axis.title.y.right=element_text(color=col2),
    axis.text.y.right=element_text(color=col2),
    # axis.line.y.left = element_line(colour =col1),
    # axis.line.y.right = element_line(colour=col2),
    axis.line= element_line(colour='black'),
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_blank()
  ) + xlab('IMD Rank Deciles') + ggtitle(title)}

tiff("IMD_Healthiness_Overall_170822.tiff", units="in", width=4.4, height=3.2, res=300)

plot_func(model2_forplot, title='')

dev.off()

## Plotting the graph by type of food outlets ---------------------------------------->

table(data_forplot_all$type)
#restaurants 
p1 = plot_func(data_forplot_all[data_forplot_all$type=='Restaurants',], '(A) Restaurants')
# cafes, snack bars, and tea rooms
p2= plot_func(data_forplot_all[data_forplot_all$type=='Cafes and tea rooms',], '(B) Cafes, snack bars, and tea rooms')
# Pubs, bars, and inns
p3=plot_func(data_forplot_all[data_forplot_all$type=='Pubs, bars and inns',], '(C) Pubs, bars, and inns ')
#fast food and takeaways
p4= plot_func(data_forplot_all[data_forplot_all$type=='Fast food and takeaways',], '(D) Fast food and takeaways')


library(plyr)
diff_func = function(data){
  val = data[data$imd_decile_cat=='Least', ]$predicted_score - data[data$imd_decile_cat=='Most', ]$predicted_score
  return(val)
}
ddply(data_forplot_all, .(type), diff_func)


ddply(data_forplot_all,.(type), summarise, diff_func)

# arrange the plots 
tiff("IMD_Healthiness_ByType_12Oct22.tiff", units="in", width=9.45, height=5.66, res=300)

ggarrange(p1, p2, p3, p4,ncol = 2, nrow = 2)
dev.off()
