import requests
from bs4 import BeautifulSoup

def get(url):
    try:
        response = requests.get(url)
        response.raise_for_status() 
        return response.json()
    except Exception as err:
        print(f"Erro: {err}")

api_url = 'https://www.teamusa.com/api/athletes?limit=1&sort_field=last_name.keyword'

api_data = get(api_url)








