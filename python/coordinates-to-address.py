import pymssql
import requests
import json
import re

# Here, we connect to the server (hosted locally, in our case) with the
# assumption that the user executing this script has privileges to the
# SQL Server and database; if not, utilize the "user" and "password" parameters

# Some configurations of SQL Server aren't friendly with multiple active
# cursors on a single connection, so for our small task, we'll create a
# dedicated connection for both cursors
connection = pymssql.connect("localhost")
connection2 = pymssql.connect("localhost", autocommit=True)

cursor = connection.cursor(as_dict=True)
cursor.execute("USE CDPH; SELECT DISTINCT Latitude, Longitude FROM DataOpenRefine WHERE [Address] IS NULL OR City IS NULL OR Zip IS NULL;")

cursor_update = connection2.cursor()

record = cursor.fetchone()
while record:
    # Format the address as a single line
    print("{}, {}".format(record["Latitude"], record["Longitude"]))
    
    # Request the geographical coordinates of the address from the API
    response = requests.get("https://api.geoapify.com/v1/geocode/search?lat={}&lon={}&apiKey=a8eb2f5faa89443b985352068849ad49".format(record["Latitude"], record["Longitude"]))
    address_properties = json.loads(response.text)["features"][0]["properties"]
    print("({} {}, {}, {} {})".format(address_properties["housenumber"], address_properties["street"], address_properties["city"], address_properties["state_code"], address_properties["postcode"]))

    # Update the records
    #cursor_update.execute("USE CDPH; UPDATE DataOpenRefine Set [Address] = %s, City = %s, Zip = %s WHERE Latitude = %s AND Longitude = %s;",
    #    ("{} {}".format(address_properties["housenumber"], address_properties["street"]),
    #    address_properties["city"],
    #    address_properties["postcode"],
    #    record["Latitude"],
    #    record["Longitude"],
    #    ))

    #record = cursor.fetchone()