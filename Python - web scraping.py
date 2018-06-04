
# coding: utf-8

# In[1]:


import requests
import pandas as pd


# ## get list html

# In[2]:


base = 'https://en.wikipedia.org'
path = '/wiki/List_of_accidents_and_incidents_involving_commercial_aircraft'
response = requests.get(base + path)


# ## get list soup

# In[3]:


from bs4 import BeautifulSoup

page = BeautifulSoup(response.text, 'html.parser')


# ## find bolded links

# In[4]:


bs = page.find_all('b')
bs = bs[:-1] # remove the last one


# ## find accident links

# In[5]:


accidents = []
for b in bs:
    accidents.extend(b.find_all('a'))


# In[6]:


# get only accidents with wiki articles linked to them to get the info tables

accident_links = []
prefix = '/wiki/'
for a in accidents:
    if a.attrs['href'].startswith(prefix):
        accident_links.append(a)


# ## define function to get accident soups

# In[7]:


def get_accident_page(accident_link):
    """
    Given an accident link get a beautifulsoup page
    """
    accident_response = requests.get(                        base + accident_link.attrs['href'])
    return BeautifulSoup(accident_response.text, 'html.parser')


# ## get accident soups

# In[8]:


accident_soups = []
for link in accident_links:
    soup = get_accident_page(link)
    accident_soups.append(soup)


# ## define headers to iterate over

# In[9]:


Date = 'Date'
Operator = 'Operator'
Flight_origin = 'Flight origin'
Destination = 'Destination'
Fatalities = 'Fatalities'
headers = [Date, Operator, Flight_origin, Destination, Fatalities]


# ## define function to get all info for accident pages

# In[10]:


def get_table_data(accident_page, headers):
    """
    Given accident page, return its info
    """
    info = {}
    info['Name'] = accident_page.find('title').text # I find it easier \
    # to get accident name from its own page instead of from list page
    for header in headers:
        try: # skip pages with missing pieces of info
            th = accident_page.find('th', text = header)
            td = th.find_next('td').text
            info[header] = td
        except(AttributeError):
            pass
    return info


# ## get info for all accident pages

# In[11]:


accident_infos = []
for soup in accident_soups:
    print(soup.find('title').text) # print accident names to watch progress
    acc_info = get_table_data(soup, headers)
    accident_infos.append(acc_info)


# ## convert to df and write into csv

# In[13]:


incidents = pd.DataFrame(accident_infos)


# In[15]:


incidents = incidents.drop_duplicates()
incidents.to_csv('accidents.csv', header=True, index=False, encoding='utf-8')

