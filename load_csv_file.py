import pandas as pd 
from sqlalchemy import create_engine

#connect python to postgresql 
conn_string= 'postgresql://postgres:maroo@localhost/painting'
db = create_engine(conn_string)

conn  = db.connect()

# df= pd.read_csv('/Users/user/SQL_Prooject_1/artist.csv')
# #print(df.info)

# df.to_sql('artist', con=conn, if_exists='replace', index=False)

files = ['artist','canvas_size','image_link','museum_hours','museum','product_size','subject','work']

for file in files:
   df= pd.read_csv(f'/Users/user/SQL_Prooject_1/{file}.csv')
   df.to_sql(file, con=conn, if_exists='replace', index=False)