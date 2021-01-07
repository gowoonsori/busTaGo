# 선택한 정류소의 버스리스트들을 출력

import requests, xmltodict, json
import pandas as pd
from pandas import DataFrame as df

serviceKey = 'Q2kheZxOB4Se5Iqm4ZVPAaA6Vaf9%2BdfUAIvymf%2BBWd3VoYvRmkjMQrQmE9LrIyizUYlkkW65HDZTmswAPgDDVA%3D%3D'

# 정류소 ID
stationId = 224000639

endpoint = 'http://openapi.gbis.go.kr/ws/rest/busstationservice/route?serviceKey={}&stationId={}'.format(serviceKey, stationId)
print(endpoint)

content = requests.get(endpoint).content # GET요청
dict=xmltodict.parse(content) # XML을 dictionary로 파싱
# 파싱은 어떤 페이지(문서, html 등)에서 내가 원하는 데이터를 특정 패턴이나 순서로 추출해 가공하는 것

jsonString = json.dumps(dict['response']['msgBody']['busRouteList'], ensure_ascii=False) # dict을 json으로 변환
jsonObj = json.loads(jsonString) # json을 dict으로 변환

df1 = pd.DataFrame(jsonObj)
print(df1)