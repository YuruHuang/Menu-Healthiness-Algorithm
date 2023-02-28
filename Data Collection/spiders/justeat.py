# -*- coding: utf-8 -*-
import scrapy
import datetime
import json
import requests
import pandas as pd


class JusteatSpider(scrapy.Spider):
    name = 'justeat'
    allowed_domains = ['www.just-eat.co.uk']
    def start_requests(self):

    # start_urls = ['https://www.just-eat.co.uk']

        # postcodes = pd.read_csv("C:/Users/yh459/OneDrive - University of Cambridge/Just Eat/"
        #                         "Justeat/justeat/UK_postcode_districts_10112020.csv")
        # for postcode in postcodes['postcode_district'][3109:3113]:
        #postcode = postcode.lower()
        postcode ='CB1'
        url = f'https://www.just-eat.co.uk/area/{postcode}'
        yield scrapy.Request(url=url, callback=self.parse, meta={'areaCode': postcode})

    def parse(self, response):
        # print(response.request.url)
        areaCode = response.request.meta['areaCode']
        rest_urls = response.xpath('//section[@data-test-id="restaurant"]')
        for url in rest_urls:
            rest_url = 'https://www.just-eat.co.uk' + url.xpath('./a/@href').get().replace('/menu', '')
            rest_id = url.xpath('./@data-restaurant-id').get()
            yield {'url':rest_url,
                   'areaCode':areaCode,
                   'rest_id':rest_id}
    #         yield scrapy.Request(url=rest_url, callback=self.parse_item, meta={'areaCode': areaCode,'rest_id': rest_id})
    #
    # def parse_item(self, response):
    #     areaCode = response.request.meta['areaCode']
    #     rest_id = response.request.meta['rest_id']
    #     hg_rating = requests.get(f'https://hygieneratingscdn.je-apis.com/api/uk/restaurants/{rest_id}').json()
    #     offers = requests.get(
    #         f'https://uk.api.just-eat.io/consumeroffers/notifications/uk?restaurantIds={rest_id}').json().get(
    #         'description')
    #     delivery_date = [date.strip() for date in response.xpath(
    #         '//div[@data-test-id="info-tab"]//p[@data-test-id="opening-times-day"]/span/text()').getall()]
    #     delivery_time = [time.strip() for time in response.xpath(
    #         '//div[@data-test-id="info-tab"]//span[@data-test-id="opening-time-hours"]/text()').getall()]
    #     delivery_dict = dict(zip(delivery_date, delivery_time))
    #     current_time = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
    #     query_params = {'orderTime': current_time, 'areaId': areaCode}
    #     params_coded = urllib.parse.urlencode(query_params)
    #     deliver_fees = requests.get(
    #         f'https://uk.api.just-eat.io/restaurant/uk/82349/menu/dynamic?{params_coded}').json()
    #     rest_dict = {
    #         'request url': response.request.url,
    #         'Postal Code': areaCode,
    #         'Collection time': current_time,
    #         'Food outlet name': response.xpath(
    #             'normalize-space(//h1[@data-test-id="restaurant-heading"]/text())').get(),
    #         'Cuisine': [cuisine.strip() for cuisine in
    #                     response.xpath('//span[@data-test-id="cuisines-list"]/span/text()').getall()],
    #         'Number of reviews': response.xpath(
    #             'normalize-space(//strong[@data-test-id="rating-count-description"]/text())').get(),
    #         'Average rating': response.xpath(
    #             'normalize-space(//span[@data-test-id="rating-description"]/text())').get(),
    #         'Street address': response.xpath(
    #             'normalize-space(//span[@data-test-id="header-restaurantAddress"]/text())').get(),
    #         'Delivery cost': deliver_fees.get('DeliveryFees').get('Bands'),
    #         'Minimum order': deliver_fees.get('DeliveryFees').get('MinimumOrderValue'),
    #         'Special offers': offers,
    #         'Notes': [note.strip() for note in response.xpath('//div[@data-js-test="header-note"]/p/text()').getall()],
    #         'Food hygiene rating': hg_rating.get('rating'),
    #         'Food hygiene inspection date': hg_rating.get('lastInspectionDate')
    #         # 'Food hygiene rating': response.xpath('//div[@class="c-foodHygieneRating-wrapper"]/img/@alt').get(),
    #         # 'Food hygiene inspection date': response.xpath(
    #         #     'normalize-space(//p[@data-test-id="last-inspection-date"]/text())').get()
    #     }
    #     rest_dict.update(delivery_dict)
    #     yield rest_dict
