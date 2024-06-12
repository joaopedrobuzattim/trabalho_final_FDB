import requests
from bs4 import BeautifulSoup
import re
from datetime import datetime
import mysql.connector


USA_URL = 'https://www.teamusa.com/api/athletes?limit=500&sort_field=last_name.keyword'
WIKI_URL = 'https://pt.wikipedia.org/wiki/Lista_dos_Jogos_Ol%C3%ADmpicos_da_Era_Moderna'

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

def extractOlympics():
    soup = BeautifulSoup(get(WIKI_URL, isJson=False), 'html.parser')

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


def loadOlympics():
    try:
        summerArr, winterArr = extractOlympics()

        for data in summerArr:
            cursor = cnx.cursor()
            if(len(data) == 4):
                cursor.execute("INSERT INTO Olympics (year, city, edition, country, season) VALUES (%s, %s, %s, %s, %s)", [data[0], data[2], data[1], data[3][3:], 'Summer'])
            cnx.commit()
            cursor.close()

        for data in winterArr:
            cursor = cnx.cursor()
            if(len(data) == 4):
                cursor.execute("INSERT INTO Olympics (year, city, edition, country, season) VALUES (%s, %s, %s, %s, %s)", [data[0], data[2], data[1], data[3][3:], 'Winter'])
            cnx.commit()
            cursor.close()
    except Exception as err:
        print(f"Erro em load Olympics: {err}")
        cnx.rollback()


def loadSports():
    try:
        athletes = get(USA_URL)['entries']

        cursor = cnx.cursor()    
        for athlete in athletes:
            if( (athlete['medals'] and (athlete['medals']['bronze'] or athlete['medals']['gold'] or athlete['medals']['silver'])) and ('Paralympian' not in athlete['past_olympics']) and (len(athlete['sport']) > 0)  ):
                for sport in athlete['sport']:
                    cursor.execute('SELECT * FROM Sport WHERE Sport.name = %s', [sport['title']])
                    result = cursor.fetchall()
                    if(len(result) == 0):
                            cursor.execute('INSERT INTO Sport (name, season) VALUES (%s, %s)', [sport['title'], sport['season']])
                            cnx.commit()
    except Exception as err:
        print(f"Erro em load Sports: {err}")
        cnx.rollback()

def loadAthletes():
    athletes = get(USA_URL)['entries']

    for athlete in athletes:
        try:
            if( (athlete['medals']['bronze'] or athlete['medals']['gold'] or athlete['medals']['silver']) and ('Paralympian' not in athlete['past_olympics']) and (len(athlete['sport']) > 0) ):
                
                sport_name = athlete['sport'][0]['title']
                cursor = cnx.cursor()
                cursor.execute('SELECT id FROM Sport WHERE Sport.name = %s', [sport_name])
                sport_id = cursor.fetchone()[0]
                cursor.close()
 
                participation_years = re.findall(r'\b\d{4}\b', athlete['past_olympics'])

            
                first_name = athlete['first_name']
                last_name = athlete['last_name']
                birthday = athlete['quick_facts']['birthday']
                deceased_date = athlete['quick_facts']['deceased_date'] if athlete['quick_facts'].get('deceased_date') else None

                if(not athlete['quick_facts'].get('age')):
                    birthday_date_format = datetime.fromisoformat(birthday)
                    if(not athlete['quick_facts'].get('deceased_date')):
                        today = datetime.now()
                        age = today.year - birthday_date_format.year
                        if (today.month, today.day) < (birthday_date_format.month, birthday_date_format.day):
                            age -= 1
                    else:
                        deceased_date_format = datetime.fromisoformat(deceased_date)
                        age = deceased_date_format.year - birthday.year
                        if (deceased_date_format.month, deceased_date_format.day) < (birthday_date_format.month, birthday_date_format.day):
                            age -= 1
                else:
                    age = athlete['quick_facts']['age']
                        
                height = athlete['quick_facts']['height'] if athlete['quick_facts'].get('height') else None
                state = athlete['quick_facts']['hometown']['state']
                city = athlete['quick_facts']['hometown']['city']
                hometown = f"{city}, {state}"
                education = athlete['quick_facts']['education'] if athlete['quick_facts'].get('education') else None
                gold_medals = athlete['medals']['gold']
                silver_medals = athlete['medals']['silver']
                bronze_medals = athlete['medals']['bronze']

                athlete_data = [first_name, last_name, age, birthday, deceased_date, height, hometown, education, gold_medals, silver_medals, bronze_medals, sport_id]
    

            
                cursor = cnx.cursor()
                cursor.execute('INSERT INTO Athlete (first_name,\
                                last_name,\
                                age,\
                                birthday,\
                                deceased_date,\
                                height, hometown,\
                                education,\
                                gold_medals,\
                                silver_medals,\
                                bronze_medals,\
                                sport_id\
                                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)', athlete_data)
                cursor.close()


                athlete_id = cursor.lastrowid
            
                for year in participation_years:
                    cursor = cnx.cursor()
                    cursor.execute('SELECT id FROM Olympics WHERE Olympics.year = %s and Olympics.season = %s', [year, athlete['sport'][0]['season']])
                    olympics_id = cursor.fetchone()[0]
                    cursor.execute('INSERT INTO Participation (athlete_id, olympics_id) VALUES (%s, %s)', [athlete_id, olympics_id])
                    cursor.close()

                cnx.commit()
        except Exception as err:
            print(f"Erro em load Atlhete: {err}")
            print(f'Atleta: {athlete['first_name']} {athlete['last_name']}')
            print(f'Realizando rollback...\n')
            cnx.rollback()
            continue

loadOlympics()
print('Dados de olímpiadas carregados com sucesso!\n')

loadSports()
print('Dados de esportes carregados com sucesso!\n')

loadAthletes()
print('Dados de atletas carregados com sucesso!\n')

cnx.close()

