import pandas as pd
import os
from datetime import date

# run the first spider to get all the URLs
path = './justeat' + '_' + date.today().strftime("%b-%d-%Y")
os.mkdir(path)
os.system("scrapy crawl justeat"  + " -o " + path + '/urls.csv')
urls = pd.read_csv(path +'/urls.csv')

# drop duplicates
urls.drop_duplicates(subset =["rest_id",'url'],keep = 'first', inplace=True)
urls.to_csv(path +'/urls_unique.csv')

# use the URLs to run the second spider
os.system("scrapy crawl justeat_details"  + " -o " + path + '/Birmingham_details.csv')


