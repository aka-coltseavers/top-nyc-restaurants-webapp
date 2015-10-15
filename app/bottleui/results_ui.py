from bottle import route, run, template
from bottle import jinja2_template as template
import bottle
import pymongo

connection_string = "mongodb://localhost"
connection = pymongo.MongoClient(connection_string)
db = connection.orchard

@bottle.route('/')
def default():
    return bottle.template('layout.html')

#@route('/run_etl')
#def runETL():
    
# This route is the main page of the UI
@bottle.route('/results_ui')
def resultsUI():
    return bottle.template('results_ui.tpl', num_recs_loaded=get_num_recs_loaded(), num_distinct_cuisines=get_num_distinct_cuisines(), top_thai_restaurants=get_top_thai_restaurants())
    
def get_num_recs_loaded():
    return db.doh_nyc_restaurants.count()

def get_num_distinct_cuisines():
    return len(db.doh_nyc_restaurants.distinct("cuisine"))

def get_top_thai_restaurants():
    """
    Get the list of top 10 Thai with Grading not lower than B
    """
    pipeline = [{"$match" : {"cuisine": "Thai"}},
                {"$match" : {"grades.grade" : {"$in" : ["A","B"]}}},
                {"$project" : {"_id" : 0, "restaurant_name": 1, "address": 1, "boro": 1}},
                {"$limit" : 10}
               ]
    return list(db.doh_nyc_restaurants.aggregate(pipeline))

# Start the webserver running and wait for requests
bottle.run(host='0.0.0.0', port=8080) 
