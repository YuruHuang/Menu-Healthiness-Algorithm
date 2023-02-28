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
# fd = open('./justeat_Nov-11-2020/Birmingham_details.csv' , mode='w', encoding='utf-8')
# fd.write('./justeat_Nov-11-2020/Birmingham_details.csv')

# import requests
# import urllib
# import datetime
# urls_tb = pd.read_csv(path + '/urls_unique.csv')
# dict = []
# for row in urls_tb.itertuples():
#     url = row.url
#     rest_id = row.rest_id
#     areaCode = row.areaCode
#     current_time = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
#     query_params = {'orderTime': current_time, 'areaId': areaCode}
#     params_coded = urllib.parse.urlencode(query_params)
#     deliver_fees = requests.get(f'https://uk.api.just-eat.io/restaurant/uk/{rest_id}/menu/dynamic?{params_coded}').json()
#     if deliver_fees.get('DeliveryFees'):
#         deliver_cost = deliver_fees.get('DeliveryFees').get('Bands')
#         min_order = deliver_fees.get('DeliveryFees').get('MinimumOrderValue')
#     else:
#         deliver_cost = None
#         min_order = None
#     dict.append({'rest_id':rest_id,'Delivery cost':deliver_cost, 'Minimum order':min_order, 'url':url})
#     deliver = pd.DataFrame(dict)
#
# details = pd.read_csv(path + '/Birmingham_details.csv')
# details.shape
# deliver.shape
# details = details.merge(deliver,how='left',left_on ='request url', right_on='url')
# details.to_csv(path + '/Birmingham_details2.csv')


