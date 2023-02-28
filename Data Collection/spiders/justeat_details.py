# -*- coding: utf-8 -*-
import scrapy
from datetime import date
import datetime
import pandas as pd
import requests
import urllib


class JusteatDetailsSpider(scrapy.Spider):
    name = 'justeat_details'
    allowed_domains = ['www.just-eat.co.uk']
    start_urls = ['http://www.just-eat.co.uk/']

    def start_requests(self):
        path = './justeat' + '_' + date.today().strftime("%b-%d-%Y")
        urls_tb = pd.read_csv(path +'/urls_unique.csv')
        for row in urls_tb.itertuples():
            url = row.url
            rest_id = row.rest_id
            areaCode = row.areaCode
            yield scrapy.Request(url = url,callback=self.parse,meta={'areaCode': areaCode,'rest_id': rest_id})

    def parse(self, response):
        areaCode = response.request.meta['areaCode']
        rest_id = response.request.meta['rest_id']
        hg_rating = requests.get(f'https://hygieneratingscdn.je-apis.com/api/uk/restaurants/{rest_id}').json()
        offers = requests.get(f'https://uk.api.just-eat.io/consumeroffers/notifications/uk?restaurantIds={rest_id}').json()
        current_time = datetime.datetime.utcnow().replace(tzinfo=datetime.timezone.utc).isoformat()
        query_params = {'orderTime': current_time, 'areaId': areaCode}
        params_coded = urllib.parse.urlencode(query_params)
        deliver_fees = requests.get(
            f'https://uk.api.just-eat.io/restaurant/uk/{rest_id}/menu/dynamic?{params_coded}').json()
        if deliver_fees.get('DeliveryFees'):
            deliver_cost = deliver_fees.get('DeliveryFees').get('Bands')
            min_order = deliver_fees.get('DeliveryFees').get('MinimumOrderValue')
        else:
            deliver_cost = None
            min_order = None
        if offers.get('offerNotifications'):
            offer = offers.get('offerNotifications')[0].get('description')
        else:
            offer = None
        delivery_date = [date.strip() for date in response.xpath(
            '//div[@data-test-id="info-tab"]//p[@data-test-id="opening-times-day"]/span[@data-test-id="day-name"]/text()').getall()]
        delivery_time = [time.strip() for time in response.xpath(
            '//div[@data-test-id="info-tab"]//span[@data-test-id="opening-time-hours"]/text()').getall()]
        delivery_dict = dict(zip(delivery_date, delivery_time))
        rest_dict = {
            'request url': response.request.url,
            'Postal Code': areaCode,
            'Collection time': current_time,
            'Food outlet name': response.xpath(
                'normalize-space(//h1[@data-test-id="restaurant-heading"]/text())').get(),
            'Cuisine': [cuisine.strip() for cuisine in
                        response.xpath('//span[@data-test-id="cuisines-list"]/span/text()').getall()],
            'Number of reviews': response.xpath(
                'normalize-space(//strong[@data-test-id="rating-count-description"]/text())').get(),
            'Average rating': response.xpath(
                'normalize-space(//span[@data-test-id="rating-description"]/text())').get(),
            'Street address': response.xpath(
                'normalize-space(//span[@data-test-id="header-restaurantAddress"]/text())').get(),
            'Delivery cost': deliver_cost,
            'Minimum order': min_order,
            'Special offers': offer,
            'Notes': [note.strip() for note in response.xpath('//div[@data-js-test="header-note"]/p/text()').getall()],
            'Food hygiene rating': hg_rating.get('rating'),
            'Food hygiene inspection date': hg_rating.get('lastInspectionDate')
            # 'Food hygiene rating': response.xpath('//div[@class="c-foodHygieneRating-wrapper"]/img/@alt').get(),
            # 'Food hygiene inspection date': response.xpath(
            #     'normalize-space(//p[@data-test-id="last-inspection-date"]/text())').get()
        }
        rest_dict.update(delivery_dict)
        yield rest_dict
