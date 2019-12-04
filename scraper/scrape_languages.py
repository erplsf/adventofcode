import requests
import urllib.request
import time
from bs4 import BeautifulSoup

def tag_is_h2_and_has_id(tag):
    return tag.name == 'h2' and tag.has_attr('id')

url = 'https://medium.com/web-development-zone/a-complete-list-of-computer-programming-languages-1d8bc5a891f'

response = requests.get(url)

if response.status_code == 200:
    soup = BeautifulSoup(response.text, 'html.parser')
    languages = '\n'.join([x.text for x in soup.find_all(tag_is_h2_and_has_id)])
    with open('languages.txt', 'w') as f:
        f.write(languages)
