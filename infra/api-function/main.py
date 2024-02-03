from google.cloud import datastore
import json

#test comment for cicd pipeline 2
# Instantiates a client
datastore_client = datastore.Client()

def hello_get(request):
    # Set CORS headers for the preflight request
    if request.method == 'OPTIONS':
        # Allows GET requests from any origin with the Content-Type
        # header and caches preflight response for an 3600s
        headers = {
            'Access-Control-Allow-Origin': 'https://kylenowski.com',
            'Access-Control-Allow-Methods': 'GET',
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Max-Age': '3600'
        }
        return ('', 204, headers)

    # db back end access variables
    kind = "siteVisitors"
    name = "siteVisitors_key"
    table_key = datastore_client.key(kind, name)
    sitename = '/'
    field = 'totalVisits'

    #see if you can pull the current page view, else create the db entry for this page
    try:
        currentpageview = fetch_pageview(key=table_key,field=field)
    except: 
        create_pageview(key=table_key, siteName=sitename)
        currentpageview = 0
    
    #incremenet the page view +1
    newvalue = store_pageview(key=table_key, field=field, storevalue=currentpageview + 1)

    headers = {
        'Access-Control-Allow-Origin': 'https://kylenowski.com'
    }

    value = {
        "headers": {
            "content-type": "application/json",
            "Access-Control-Allow-Headers": "application/json",
            "Access-Control-Allow-Origin": "https://kylenowski.com'",
            "Access-Control-Allow-Methods": "OPTIONS, POST, GET"
        },
        "statusCode": 200,
        "body":{
            "count": newvalue
        }
    }

    return (value, 200, headers)

def store_pageview(key,field,storevalue):
    # Prepares the entity
    entity = datastore.Entity(key=key)
    entity[field] = storevalue
    # Saves the entity (table)
    datastore_client.put(entity)
    return storevalue


def fetch_pageview(key,field):
    #get the table
    entity = datastore_client.get(key)
    if entity:  # Check if the entity exists
        value = entity[field]  # Access a specific property
    else:
        print("Entity not found")
        
    return value

def create_pageview(key,siteName):
    entity = datastore.Entity(key=key)  # Create an entity with the defined key
    #create entries in the table (i.e. entity)
    entity['siteName'] = siteName
    entity['totalVisits'] = 0
    
    #save the entity to datastore
    datastore_client.put(entity) 
    
    return 1   
    