import pymongo
import urllib.request
import urllib.parse
import urllib.error
import csv
import json
import os
import os.path
from datetime import datetime

#url = 'https://nycopendata.socrata.com/api/views/xx67-kt59/rows.csv?accessType=DOWNLOAD'
url = 'https://s3.amazonaws.com/egcustom_cloudstorage_for_temp_filesharing/DOHMH_New_York_City_Restaurant_Inspection_Results.csv'
srcfile_name = 'doh_nyc_restaurants'
srcfile_dir = os.getcwd()
csv_filepath = os.path.normpath(srcfile_dir + '/' + srcfile_name + '.csv')
json_filepath = os.path.normpath(srcfile_dir + '/' + srcfile_name + '.json')
csvfieldnames =  ( "restaurant_id",
                   "restaurant_name",
                   "boro",
                   "building",
                   "street",
                   "zipcode",
                   "phone",
                   "cuisine",
                   "inspection_date",
                   "action",
                   "violation_code",
                   "violation_description",
                   "critical_flag",
                   "score",
                   "grade",
                   "grade_date",
                   "record_date",
                   "inspection_type" )

class Etl:
    """
    Performs ETL for NYC Restaurant data
    """
    def __init__(self):
        """
        Intialize the class
        """
        self.connection = pymongo.MongoClient()
        self.db = self.connection.orchard 
        self.collection = self.db.doh_nyc_restaurants

    def extract(self, url, filename):
        """
        Extracts the data of NYC Restaurants in a CSV format using a URL
        
        @param url: URL where the datafile is present
        """
        response = urllib.request.urlopen(url)
        with open( '%s.csv' % filename, 'wb') as srcfile:
            file_size_dl = 0
            block_sz = 8192
            meta = dict(response.info())
            file_size = int(meta['Content-Length'])
            print(file_size)
            i = 0
            while True:
                buffer = response.read(block_sz)
                if not buffer:
                    break
                file_size_dl += len(buffer)
                srcfile.write(buffer)
                pctdone = (file_size_dl * 100. / file_size)
                if pctdone >= float(5 * i):
                    print("[%3.1f%%] downloaded" % pctdone)
                    i += 1
            print("Finished EXTRACT step.  Now continuing to next step of ETL...")

    def transform(self, filepath, filename, fieldnames ):
        """
        Tranforms the csv file into a json file for loading into MongoDB
        
        @param csvfile: The CSV file of NYC Restaurant tasks
        """
        rownum = 0
        with open(filepath, 'r') as csvfile:
            with open('%s.json' % filename, 'w') as jsonfile:
                print("Beginning TRANSFORM step of ETL....")
                reader = csv.DictReader(csvfile, fieldnames)
                for row in reader:
                    if rownum != 0:
                        for colname in fieldnames:
                            if colname not in row.keys():
                                row[colname] = ''
                        json.dump(row, jsonfile, ensure_ascii=True)
                        jsonfile.write('\n')
                    rownum += 1
                print("Finished TRANSFORM step.  Now continuing to next step of ETL...")

    def load(self, filepath):
        """
        Upserts the json file to MongoDB
        
        @param jsonfile: The JSON file of NYC Restaurant transformed from CSV
        """
        with open(filepath, 'r') as jsonfile:
            print("Beginning LOAD step of ETL...")
            for line in jsonfile:
                doc = json.loads(str(line))
                if doc['grade_date'] != '' and doc['grade'] != '' and doc['score'] != '':
                    grade_doc =  {"grade_date": doc['grade_date'].strip(),
                              "grade": doc['grade'].strip(),
                              "score": int(doc['score'].strip())
                             }

                restaurant_doc = {"address": {"street": doc['street'],
                                              "zipcode": doc['zipcode'],
                                              "building": doc['building'],
                                              "phone" : doc['phone']
                                             },
                                  "boro": doc['boro'],
                                  "cuisine": doc['cuisine'],
                                  "grades": [grade_doc],
                                  "restaurant_name": doc['restaurant_name'],
                                  "restaurant_id": doc['restaurant_id'],
                                  "_id" : doc['restaurant_id']
                                 }
                find_doc = self.collection.find_one({"_id" : doc['restaurant_id']})
                if find_doc is None:
                    self.collection.insert_one(restaurant_doc)
                else:
                    find_dupe_grade_doc = self.collection.find({"_id" : doc['restaurant_id'], 
                                                                                                 "grades.grade_date": doc['grade_date'],
                                                                                                 "grades.grade": doc['grade'],
                                                                                                 "grades.score": doc['score']
                    })
                    
                    if find_dupe_grade_doc == None and doc['grade_date'] != None and doc['grade'] != None and doc['score'] != None:
                        find_doc["grades"].append(grade_doc)
                        self.collection.replace_one({"_id" : doc['restaurant_id']}, find_doc)
            print("Finished LOAD step.  ETL process complete.")

#------------------------------------------------------------------------------
# Script Entry Point
#------------------------------------------------------------------------------
if __name__ == '__main__':

     etl = Etl()
     etl.extract(url, srcfile_name)
     etl.transform(csv_filepath, srcfile_name, csvfieldnames)
     etl.load(json_filepath)