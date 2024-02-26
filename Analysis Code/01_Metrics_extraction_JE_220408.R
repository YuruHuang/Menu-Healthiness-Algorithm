##############################################
# Functions to extract attributes from menus #
# 17 Feb 2022 Yuru Huang                     #
##############################################

# Number of water 
extract_water = function(dat){
  item_name_cleaned = gsub(pattern="\\(.*\\)","",dat$`Item Name`)
  item_name_cleaned1 = gsub(pattern="-.*",'',item_name_cleaned)
  # remove oz and g 
  item_name_cleaned2 = gsub(pattern='[0-9]+g|[0-9]+oz','',item_name_cleaned1)
  # remove space 
  item_name_cleaned3 = gsub(pattern = ' ','',tolower(item_name_cleaned2))
  n_water = sum(item_name_cleaned3=='water'|
                  item_name_cleaned3=='smartwater'|
                  item_name_cleaned3=='bottledwater'|
                  grepl(item_name_cleaned3,pattern='princesgate')|
                  grepl(item_name_cleaned3,pattern='still.*water')|
                  grepl(item_name_cleaned3,pattern='sparkling.*water')|
                  grepl(item_name_cleaned3,pattern = 'mineral.*water')|
                  grepl(item_name_cleaned3,pattern = 'water.*mineral')|
                  grepl(item_name_cleaned3,pattern = 'water.*still')|
                  grepl(item_name_cleaned3,pattern = 'water.*sparkling')|
                  grepl(item_name_cleaned3,pattern = 'evian.*water')|
                  grepl(item_name_cleaned3,pattern = 'greggs.*water')
  )
  return (n_water)
}

# Number of milk
extract_milk = function(dat){
  item_name_cleaned = gsub(pattern="\\(.*\\)","",dat$`Item Name`)
  item_name_cleaned1 = gsub(pattern="-.*",'',item_name_cleaned)
  # remove oz and g 
  item_name_cleaned2 = gsub(pattern='[0-9]+g|[0-9]+oz','',item_name_cleaned1)
  # remove space 
  item_name_cleaned3 = gsub(pattern = ' ','',item_name_cleaned2)
  n_milk = sum(tolower(item_name_cleaned3)=='milk'|
                 tolower(item_name_cleaned3)=='hotsteamedmilk'|
                 tolower(item_name_cleaned3)=='steamedmilk'|
                 tolower(item_name_cleaned3)=='dairymilk'|
                 tolower(item_name_cleaned3) == 'aglassofmilk'|
                 tolower(item_name_cleaned3)=='organicsemiskimmedmilk'|
                 tolower(item_name_cleaned3)=='semiskimmedmilk'|
                 tolower(item_name_cleaned3)=='skimmedmilk'|
                 tolower(item_name_cleaned3)=='wholemilk'|
                 tolower(item_name_cleaned3)=='organicwholemilk')
  return (n_milk)
}

# Number of Special Offers
extract_specialoffers = function(dat){
  # capture meal deals: menu section, item name, or the description contain "meal deal"
  dat$combined_name = paste(dat$`Menu Section`,dat$`Menu Section Description`,
                            dat$`Item Name`,dat$`Item Description`,sep=' ')
  n_mealdeal = sum(grepl(pattern='meal deal|set meal|set menu|sharing|share|for two|for one|bundle|for three|
                         for four|special offer|set dinner',ignore.case = TRUE, dat$combined_name))
  return(n_mealdeal)
}

# Diversity of vegetables 
vegetable_list = xlsx::read.xlsx('vegetables.xlsx', 2,header = FALSE)$X1

extract_vegetables= function(dat){
  name_desc_string = paste(tolower(dat$`Item Name`), tolower(dat$`Item Description`), collapse = '')
  n_vegetable = sum(unlist(lapply(vegetable_list, function(x){grepl(
    pattern= paste(paste("\\b",x,"\\b",sep = ''), paste("\\b",x,"s\\b",sep = ''),paste("\\b",x,"es\\b",sep = ''),sep='|'),
    name_desc_string)})))
  return(n_vegetable)
}

# Number of chips -------------------------->
extract_chips= function(dat){
  n_chip = sum(grepl('chips|fries|wedges',tolower(dat$`Item Name`))|grepl('chips|fries|wedges',tolower(dat$`Item Description`)))
  return(n_chip)
}

# Number of Salads --------------------------------------------------------------->
salad_keywords = c('salad','coleslaw','tabouleh','caprese di bufala','mixed green')

# function to extract the number of salads
extract_salads = function(dat){
  n_salads = sum(grepl(paste(salad_keywords,collapse = '|'),tolower(dat$`Item Name`))|tolower(dat$`Menu Section`)=='salad'|
                   grepl(paste(salad_keywords,collapse = '|'),tolower(dat$`Item Description`))|
                   tolower(dat$`Menu Section`)=='salads'
  )
  return(n_salads)
}

# Number of desserts ---------------------->
dessert_keywords = c('dessert','mousse','sundae','panna cotta',
                     'pannacotta','choc pot','creme caramel',
                     'chocolate','ice cream','choc ice','magnum',
                     'sorbet','icecream','mcflurry','cornetto',
                     'arctic roll','ben and jerry','ben & jerry',
                     'mince pie','eclairs','\\bcake\\b','brownie',
                     'doughnut','donut','custard','swiss roll',
                     'cupcake','caramel shortcake','choux','vanilla slice',
                     'battenburg','lemon meringue pie','apple pie',
                     'jam tart','treacle tart','cherry pie','mud pie',
                     'choc sponge','gateau','bakewell tart','jellabi',
                     'jalebi','torte','sweet waffle','pudding','jelly',
                     'toffee','cheesecake','angel delight','spotted dick',
                     'trifle','crumble','tiramisu','banoffee','blancmange',
                     'milky way','maltesers','cadbury','kinder','mars bar',
                     'bounty bar','kit kat','creme egg','mintolai','double decker',
                     'crunchie bar','snickers','wispa','toblerone','turkish delight',
                     'bitz bar','sweets','popcorn.*sweet','candies','candy','ice lollies',
                     'mintoes','nutella','halva','marshmallow','fruit winder','fudge',
                     'magaj','bear yoyo','profiterole','victoria sponge','fruit pie',
                     'cream slice','nougat','haagen dazs','churros','cookie','milkshake'
)

dessert_exclude = c('fish cake','crab cake','fishcake','rice cake','ricecake',
                    'potato cake')
dessert_menusection_keywords = c('dessert','sweet','treats','ice cream','cake','sundaes','cookies',
                                 'pudding','brownies','doughnut','churros','confectionery','waffle','milkshake')

# extract number of desserts available in each outlet 
extract_desserts = function(dat){
  n_desserts = sum((grepl(paste(dessert_keywords,collapse = '|'),tolower(dat$`Item Name`))|
                      grepl(paste(dessert_menusection_keywords,collapse="|"),tolower(dat$`Menu Section`))) & 
                     (!grepl(paste(dessert_exclude,collapse ='|'),tolower(dat$`Item Name`))))
  return(n_desserts)
}

