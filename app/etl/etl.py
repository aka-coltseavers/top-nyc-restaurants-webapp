import pymongo
import urllib
import urllib2
import csv
import json
import os
import os.path
from datetime import datetime
from threading import Thread
from time import sleep

#ETL_SRCFILE_DIRECTORY = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
ETL_SRCFILE_DIRECTORY = os.getcwd()  # aka ETL_SRCFILE_DIRECTORY
url = 'https://nycopendata.socrata.com/api/views/xx67-kt59/rows.csv?accessType=DOWNLOAD'
#backup_static_url = 'https://s3.amazonaws.com/egcustom_cloudstorage_for_temp_filesharing/DOHMH_New_York_City_Restaurant_Inspection_Results.csv'

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

srcfile_prefix = 'doh_nyc_restaurants'
extract_status_log_prefix = 'etl-extract-status-%s-' % srcfile_prefix
#output_etlextract_status_file = tempfile.NamedTemporaryFile(suffix='.log', prefix=extract_status_log_prefix)
#output_file = tempfile.NamedTemporaryFile(suffix='.log', prefix=srcfile_prefix)

#srcfile_dir = os.getcwd()  # aka ETL_SRCFILE_DIRECTORY
temp_etl_output_dir = ETL_SRCFILE_DIRECTORY + '/temp_etl_output_dir'
if os.path.exists(temp_etl_output_dir) == False:
    os.mkdir(temp_etl_output_dir)

csv_filepath = os.path.normpath(ETL_SRCFILE_DIRECTORY + '/temp_etl_output_dir/' + srcfile_prefix + '.csv')
json_filepath = os.path.normpath(ETL_SRCFILE_DIRECTORY + '/temp_etl_output_dir/' + srcfile_prefix + '.json')


class Etl:
    """
    Performs ETL for NYC Restaurant data
    """
    def __init__(self):
        """
        Intialize the class
        """
        self.connection = pymongo.MongoClient()
        self.db = self.connection.orchard_passed_test1 
        self.collection = self.db.doh_nyc_restaurants

    def extract(self, url, filename):
        """
        Extracts the data of NYC Restaurants in a CSV format using a URL
        
        @param url: URL where the datafile is present
        """
        req = urllib2.Request(url)
        try:
            response = urllib2.urlopen(req, timeout=180)
        except URLError as e:
            if hasattr(e, 'reason'):
                print 'We failed to reach a server.'
                print 'Reason: ', e.reason
            elif hasattr(e, 'code'):
                print 'The server couldn\'t fulfill the request.'
                print 'Error code: ', e.code
        else:
            with open( 'temp_etl_output_dir/%s.csv' % filename, 'wb') as srcfile:
                file_size_dl = 0
                block_sz = 8192
                print response.info()
                meta = dict(response.info())
                #print(meta)
                file_size = int(meta['content-length'])
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
            with open('temp_etl_output_dir/%s.json' % filename, 'w') as jsonfile:
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
            line_counter = 0
            valid_gradedoc_line_counter = 0
            for line in jsonfile:
                grade_doc = {}
                restaurant_doc = {}
                doc = json.loads(str(line))
                find_doc = self.collection.find_one({"restaurant_id": doc['restaurant_id']})
                if find_doc is None:
                    find_doc = {"address": {"street": doc['street'].strip(),
                                                  "zipcode": doc['zipcode'],
                                                  "building": doc['building'].strip(),
                                                  "phone" : doc['phone']
                                                 },
                                      "boro": doc['boro'],
                                      "cuisine": doc['cuisine'],
                                      "grades": [],
                                      "restaurant_name": doc['restaurant_name'],
                                      "restaurant_id": doc['restaurant_id'],
                                      "_id": doc['restaurant_id']
                                     }
                    self.collection.insert_one(find_doc)
                    
                if doc['grade_date'] != '' and doc['grade'] != '' and doc['score'] != '':
                    grade_doc['grade_date'] =  doc['grade_date'].strip()
                    grade_doc['grade'] = doc['grade'].strip()
                    grade_doc['score'] = doc['score']
                    
                    find_dupe_grade_doc = self.collection.find_one({"restaurant_id": doc['restaurant_id'], 
                                                                  "grades": { "$elemMatch":  { "grade_date": grade_doc['grade_date'], "grade": grade_doc['grade'], "score": grade_doc['score'] }}
                    })
                    
                    if find_dupe_grade_doc == None: #and grade_doc['grade_date'] != None and grade_doc['grade'] != None and grade_doc['score'] != None:
                        find_doc["grades"].append(grade_doc)
                        self.collection.replace_one({"_id": doc['restaurant_id']}, find_doc)
                        valid_gradedoc_line_counter += 1
                line_counter += 1
            print("Finished LOAD step.  ETL process complete.")
            print("------------------------")
            print("Total Processed Lines: %d" % line_counter)
            print("Total Processed Valid Graded Lines: %d" % valid_gradedoc_line_counter)
            print("------------------------")
            #shutil.rmtree(temp_etl_output_dir)

#------------------------------------------------------------------------------
# Script Entry Point
#------------------------------------------------------------------------------
if __name__ == '__main__':

     etl = Etl()
     etl.extract(url, srcfile_prefix)
     etl.transform(csv_filepath, srcfile_prefix, csvfieldnames)
     etl.load(json_filepath)