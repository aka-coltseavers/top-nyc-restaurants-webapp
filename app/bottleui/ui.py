import bottle
import pymongo

connection_string = "mongodb://localhost"
connection = pymongo.MongoClient(connection_string)
db = connection.orchard

# This route is the main page of the UI
@bottle.route('/')
def index():
    num_recs_loaded = get_num_recs_loaded()
    num_distinct_cuisines = get_num_distinct_cuisines()
    top_thai_restaurants = get_top_thai_restaurants()
    return bottle.template('ui_template', dict(num_recs_loaded=num_recs_loaded,
                                               num_distinct_cuisines=num_distinct_cuisines,
                                               top_thai_restaurants=top_thai_restaurants
                                              )
                                              )

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
                {"$project" : {"_id" : 0, "name": 1, "address": 1, "boro": 1}},
                {"$limit" : 10}
               ]
    return list(db.doh_nyc_restaurants.aggregate(pipeline))

# Start the webserver running and wait for requests
bottle.run(host='localhost', port=8082)         

