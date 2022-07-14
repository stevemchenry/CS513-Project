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
cursor.execute("USE CDPH; SELECT Distinct [Address], City, State, Zip, [Location] FROM DataOpenRefine WHERE [Location] IS NULL;")

cursor_update = connection2.cursor()

record = cursor.fetchone()
while record:

    # Reduce street number ranges to the first number of the range
    street_address_cleaned = re.sub(r"([0-9]+)(\-[0-9]+)", r"\1", record["Address"])

    # Remove parenthesized inserts within the address
    street_address_cleaned = re.sub(r"\(.*\)", "", street_address_cleaned)

    # Remove additional "slash suffixes" from the address
    street_address_cleaned = re.sub(r"/.*$", "", street_address_cleaned)

    # Remove unnecessary API-confusing suffix terms such as "BLDG" and "BSMT"
    street_address_cleaned = re.sub(r"(\sBLDG|\sBSMT|\sPLZ)$", "", street_address_cleaned)

    # Collapse residual consecutive whitespace created by this process
    street_address_cleaned = re.sub(r"\s{2,}", " ", street_address_cleaned)

    # Format the address as a single line
    address = "{}, {}, {} {}".format(street_address_cleaned, record["City"], record["State"], record["Zip"])
    print(address)
    
    # Request the geographical coordinates of the address from the API
    response = requests.get("https://api.geoapify.com/v1/geocode/search?text={}&apiKey=a8eb2f5faa89443b985352068849ad49".format(requests.utils.quote(address)))
    address_properties = json.loads(response.text)["features"][0]["properties"]
    print("({}, {})".format(address_properties["lat"], address_properties["lon"]))

    # Update the records
    cursor_update.execute("USE CDPH; UPDATE DataOpenRefine Set Latitude = %s, Longitude = %s, Location = %s WHERE [Address] = %s AND City = %s AND [State] = %s AND Zip = %s;",
        (address_properties["lat"],
        address_properties["lon"],
        "({}, {})".format(address_properties["lat"], address_properties["lon"]),
        record["Address"],
        record["City"],
        record["State"],
        record["Zip"]))

    record = cursor.fetchone()