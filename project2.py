import pandas as pd
import psycopg2
from sqlalchemy import create_engine
import pandas as pd
#print(display)
host="localhost"
database="database1"
user="postgres"
password="viji"
port="5432"
enginestring=f"postgresql://{user}:{password}@{host}:{port}/{database}"
#enginestring='postgresql+psycopg2://localhost:1234@localhost:5432/database1'
engine=create_engine(enginestring)



"""data=pd.read_csv('C:/Users/Welcome/Desktop/projects.py/Stores.csv')
s=pd.DataFrame(data)
s.to_sql("new_stores_modified",engine,if_exists='replace',index=False)


data=pd.read_csv('C:/Users/Welcome/Desktop/projects.py/Products.csv')
s=pd.DataFrame(data)
s.to_sql("new_products_modified",engine,if_exists='replace',index=False)"""

data=pd.read_csv('C:/Users/Welcome/Desktop/projects.py/Customers.csv', encoding='latin-1')
s = pd.DataFrame(data)
s.to_sql("customers",engine,if_exists='replace',index=False)


"""data=pd.read_csv('C:/Users/Welcome/Desktop/projects.py/Sales.csv')
s=pd.DataFrame(data)
s.to_sql("new_sales_modified",engine,if_exists='replace',index=False)

data=pd.read_csv('C:/Users/Welcome/Desktop/projects.py/Exchange_Rates.csv')
s=pd.DataFrame(data)
s.to_sql("new_exchange_rates",engine,if_exists='replace',index=False)"""