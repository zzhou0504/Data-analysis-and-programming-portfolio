
import pandas as pd
import requests


# variables I am picking:
# (1) Household income in the past 12 months
# (2) Estimated number of people covered by Medicare
# (3) Estimate number of foreign-born people who speak another language
path='https://api.census.gov/data/2016/acs/acs5?get=NAME,B25122_001E,C27006_001E,B16005F_009E&for=county:*&in=state:51'
data = requests.get(path).json()


# write into dataframe
acs = pd.DataFrame(data)
# change header and drop redundant row
acs.columns = acs.iloc[0]
acs = acs.reindex(acs.index.drop(0))
# drop unuseful columns
acs = acs.drop(['state', 'county'], axis=1)
# clean county/city names
acs['NAME']=acs['NAME'].map(lambda x: x.rstrip(' ,Virginia'))


# rename columns
cols = ['County/City','Household Income', 'Medicare Coverage', 'Foreign Born']
acs.columns = cols



acs.to_csv('acs.csv', index=False)
