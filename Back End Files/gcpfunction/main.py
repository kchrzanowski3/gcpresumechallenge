from google.cloud import datastore
import json

#test comment for cicd pipeline 2
# Instantiates a client
datastore_client = datastore.Client()

def hello_get(request):
    # The kind for the new entity
    kind = "pagevisitsdb"
    # The name/ID for the new entity
    name = "kylechrzanowskicom"
    # Instantiates a client
    datastore_client = datastore.Client()
    # The Cloud Datastore key for the new entity
    table_key = datastore_client.key(kind, name)

    newpageview = fetch_pageview()+1
    store_pageview(newpageview)

    value = {
        "visitorcount": newpageview
    }

    # Dictionary to JSON Object using dumps() method
    # Return JSON Object
    return json.dumps(value)

def store_pageview(dt):
    # Instantiates a client
    datastore_client = datastore.Client()

    # The kind for the new entity
    kind = "pagevisitsdb"
    # The name/ID for the new entity
    name = "kylechrzanowskicom"
    # The Cloud Datastore key for the new entity
    task_key = datastore_client.key(kind, name)

    # Prepares the new entity
    task = datastore.Entity(key=task_key)
    task["visitcount"] = dt

    # Saves the entity
    datastore_client.put(task)


def fetch_pageview():
    client = datastore.Client()
    query = client.query(kind='pagevisitsdb')
    query = query.add_filter('visitcount', '>', 0)
    l = query.fetch()
    l1 = list(l)
    currentcount = l1[0]['visitcount']
    
    return currentcount
