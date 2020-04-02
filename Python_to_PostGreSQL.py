# -*- coding: utf-8 -*-
"""
Created on Wed Apr  1 12:44:05 2020

@author: Anshul Arya
"""


# Import all modules required 
import pandas as pd
import numpy as np
import sys
import psycopg2 as ps

# Download a timeseries of daily deaths per country
url1 = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/"
url2 = "/master/csse_covid_19_data/csse_covid_19_time_series/"
url3 = "time_series_covid19_deaths_global.csv"
url = url1 + url2 + url3

# Use Pandas fucnction to read the csv file
death = pd.read_csv(url)
# Glimpse of daily data
death.head()
# Replcae Na with Space specially in Provinces
death = death.replace(np.nan, "", regex=True)
# rename column for the sake of simplicity
death.rename(columns = {'Province/State' : 'Province', 
                        'Country/Region' : 'Country'}, inplace=True)
# Convert data drom wide format to long format 
death = pd.melt(death, id_vars=['Province','Country','Lat','Long'],
                var_name="Date", value_name= "Death_Count")

# Convert the dates to proper date format
death.Date = pd.to_datetime(death.Date)
# Sort values by Country and Date to have a proper order in data
death.sort_values(["Country","Date"], axis = 0, ascending= True, 
                 inplace=True, na_position='last')

# Define a function to establish connection with PostGreSQL as I have access
# to PostGreSQL
def connect(param_dic):
    """ Connect to the PostgreSQL database server"""
    conn = None
    try:
        # Connect to the PostGreSQL Server
        print('Connecting to the PostGreSQL database...')
        conn = ps.connect(**param_dic)
    
    except(Exception, ps.DatabaseError) as Error:
        print(Error)
        sys.exit(1)
        
    return conn

# Define a function to Execute a single insert request
def single_insert(conn, insert_request):
    """Execute a single insert request"""
    cursor = conn.cursor()
    try:
        cursor.execute(insert_request)
        conn.commit()
    except (Exception, ps.DatabaseError) as Error:
        print("Error: %s" % Error)
        conn.rollback()
        cursor.close()
        return 1
    cursor.close()

# Define a function to insert the Pandas dataframe to Deaths_total table in
# PostGreSQL
def main():
    # Connection params
    param_dic = {
        "host"     : "XXX.X.X.X",         # Supply the host to PostGreSQL
        "database" : "<Database>",        # Specify the database that contains the table
        "user"     : "postgre_username",  # postGre Username
        "password" : "password",          # password to login to PostGreSQL
        "port"     : "port"               # specify port for faster connection
    } 
    
    conn = connect(param_dic)
    
    # Insert the dataframe one row at the time
    # For each country, upload the Death data
    for i in death.index:
        province = death['Province'][i]
        country  = death['Country'][i]
        lat      = death['Lat'][i]
        long     = death['Long'][i]
        Date     = death['Date'][i]
        Death_total = death['Death_Count'][i]
        
        query = """ 
        INSERT into deaths_test(province,country,lat,long,Date,Death_total) values('%s','%s','%s','%s','%s','%s');
        """ % (province,country,lat,long,Date,Death_total)
        # Insert into Database
        single_insert(conn, query)
    
    print("All rows were sucessfully inserted in the Death Total table")
    # Close the database connection
    conn.close()

# call the function to insert table entries
if __name__ == "__main__":
    main()

# calculate the daily change in deaths for each country
# the below command will add a new column in the death dataset which contains 
# daily change by Country
death['Daily_Change'] = death.groupby(['Province','Country'])['Death_Count'].diff()
# replace all Na' on the first position of the Country as it does not count 
# any difference
death.replace(np.nan, 0, regex=True,inplace = True)
# define a function to add this new data to table deaths_change_python in 
# PostGRE
def main1():
    # Connection params
    param_dic = {
        "host"     : "127.0.0.1",
        "database" : "Learn_DS",
        "user"     : "postgres",
        "password" : "anshul92",
        "port"     : "5432"
    }
    
    conn = connect(param_dic)
    
    # Insert the dataframe one row at the time
    # For each country, upload the Death data
    for i in death.index:
        province = death['Province'][i]
        country  = death['Country'][i]
        lat      = death['Lat'][i]
        long     = death['Long'][i]
        Date     = death['Date'][i]
        Death_total = death['Death_Count'][i]
        Daily_change = death['Daily_Change'][i]
        
        query = """ 
        INSERT into deaths_change_python(province,country,lat,long,Date,Death_total,Daily_Change) values('%s','%s','%s','%s','%s','%s','%s');
        """ % (province,country,lat,long,Date,Death_total,Daily_change)
        # Insert into Database
        single_insert(conn, query)
    
    print("All rows were sucessfully inserted in the Death Total table")
    # Close the database connection
    conn.close()
# Call function to insert entry in the new table   
if __name__ == "__main__":
    main1()
