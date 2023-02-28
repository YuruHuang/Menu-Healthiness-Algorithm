# -*- coding: utf-8 -*-
import scrapy
import requests
from datetime import date
import pandas as pd


class JusteatMenuSpider(scrapy.Spider):
    name = 'justeat_menu'
    allowed_domains = ['www.just-eat.co.uk']

    def start_requests(self):
        urls_tb = pd.read_csv('CB1_takeaways_250621.csv')
        for row in urls_tb.itertuples():
            url = row.url + '/menu'
            rest_id = row.rest_id
            areaCode = row.areaCode
            yield  scrapy.Request(url = url,callback=self.parse,meta={'areaCode': areaCode,'rest_id': rest_id})

    def parse(self,response):
        rest_id = response.request.meta['rest_id']
        rest_name = response.xpath('normalize-space(//h1[@data-test-id="restaurant-heading"]/text())').get()
        address = response.xpath('normalize-space(//span[@data-test-id="header-restaurantAddress"]/text())').get()
        cuisines = [cuisine.strip() for cuisine in response.xpath('//span[@data-test-id="cuisines-list"]/span/text()').getall()]
        categories =response.xpath('//section[@data-test-id="menu-category-item"]')
        hg_rating = requests.get(f'https://hygieneratingscdn.je-apis.com/api/uk/restaurants/{rest_id}').json()
        offers = requests.get(f'https://uk.api.just-eat.io/consumeroffers/notifications/uk?restaurantIds={rest_id}').json()
        if offers.get('offerNotifications'):
            offer = offers.get('offerNotifications')[0].get('description')
        else:
            offer = None
        for category in categories:
            cat_name = category.xpath('normalize-space(./header//h2/text())').get()
            cat_description = category.xpath('normalize-space(.//p[@data-test-id="note-inline"]/text())').get()
            menu_items = category.xpath('.//div[@data-test-id="menu-item"]')
            for menu_item in menu_items:
                item_name = menu_item.xpath('normalize-space(.//h3[@data-test-id="menu-item-name"]/text())').get()
                item_price = menu_item.xpath('normalize-space(.//p[@data-js-test="menu-item-price"]/text())').get()
                yield{
                    'Restaurant ID':rest_id,
                    'Restaurant Name': rest_name,
                    'Address': address,
                    'Area Code': response.request.meta['areaCode'],
                    'Hygiene Rating': hg_rating,
                    'Special Offers': offers,
                    'Cuisines': cuisines,
                    'Menu Section': cat_name,
                    'Menu Section Description': cat_description,
                    'Item Name': item_name,
                    'Item Description':menu_item.xpath('normalize-space(.//p[@data-test-id="menu-item-description"]/'
                                                       'text())').get(),
                    'Item Price': item_price,
                    'URL': response.url
                }




