import requests
from bs4 import BeautifulSoup
import mysql.connector


def get(url, isJson=True):
    try:
        response = requests.get(url)
        response.raise_for_status() 
        if isJson:
            data = response.json()
        else:
            data = response.text
        return data
    except Exception as err:
        print(f"Erro: {err}")

api_url = 'https://www.teamusa.com/api/athletes?limit=1&sort_field=last_name.keyword'

api_data = get(api_url)




def extractOlympics():
    url = "https://pt.wikipedia.org/wiki/Lista_dos_Jogos_Ol%C3%ADmpicos_da_Era_Moderna"

    soup = BeautifulSoup(get(url, isJson=False), 'html.parser')

    tables = soup.find_all('table', {'class': 'wikitable'})

    summer_table = tables[0]
    winter_table = tables[1]

    summer_data = []
    for tr in summer_table.find_all('tr'):
        cells = tr.find_all(['td', 'th'])
        primeira_quatro_cells = cells[:4]
        summer_data.append([cell.get_text(strip=True) for cell in primeira_quatro_cells])


    winter_data = []
    for tr in winter_table.find_all('tr'):
        cells = tr.find_all(['td', 'th'])
        primeira_quatro_cells = cells[:4]
        winter_data.append([cell.get_text(strip=True) for cell in primeira_quatro_cells])

    summer_data.pop(0)
    winter_data.pop(0)

    return summer_data, winter_data
    
    

try:
    cnx = mysql.connector.connect(user='root', password='admin',
                                host='127.0.0.1',
                                database='olympic_participation')
except Exception as err:
    print(f"Erro de conexão: {err}")


summerArr, winterArr = extractOlympics()

for data in summerArr:
    cursor = cnx.cursor()
    #if(len(data) == 4):
        #cursor.execute("INSERT INTO Olympics (year, city, edition, country, season) VALUES (%s, %s, %s, %s, %s)", [data[0], data[2], data[1], data[3][3:], 'Summer'])
    cnx.commit()
    cursor.close()

for data in winterArr:
    cursor = cnx.cursor()
    #if(len(data) == 4):
        #cursor.execute("INSERT INTO Olympics (year, city, edition, country, season) VALUES (%s, %s, %s, %s, %s)", [data[0], data[2], data[1], data[3][3:], 'Winter'])
    cnx.commit()
    cursor.close()


athletes = get('https://www.teamusa.com/api/athletes?limit=200&sort_field=last_name.keyword')['entries']

cursor = cnx.cursor()    
for athlete in athletes:
    if(athlete['medals'] and (athlete['medals']['bronze'] or athlete['medals']['gold'] or athlete['medals']['silver'])):
        if( 'Paralympian' not in athlete['past_olympics']):
            for sport in athlete['sport']:
                cursor.execute('SELECT * FROM Sport WHERE Sport.name = %s', [sport['title']])
                result = cursor.fetchall()
                if(len(result) == 0):
                        cursor.execute('INSERT INTO Sport (name, season) VALUES (%s, %s)', [sport['title'], sport['season']])
                        cnx.commit()


cnx.close()

