# top-nyc-restaurants-webapp

#Requirements:
--
- Requires Python3 be already installed on local machine
- Requires virtualenv package (version 11.0 or higher) installed and exists in PATH environment variable
- MacOS or Linux (tested with MacOS)
- Internet-connection

#Usage Instructions:
--
- clone this repo to your localmachine
- cd into subfolder "scripts/" (<reponame>/scripts/)
- run from terminal shell:
<code>./custom_venv_prep.sh</code>
- read and follow the instructions displayed at the end of script output
- run the command to start the virtual environment created by script 
-* (copy and paste that command it says to run at the end of script output from above)
- start mongod by running:
<code>mongod --dbpath <path_to_mongodb_installation_parent_dir>/mongo_data/db &</code>
- cd to the repo subfolder "app" and run:
<code>python setup.py develop</code>
- then, run the ETL using this command:
<code>cd <wc_of_git_repo>/app/etl; python etl.py</code>
- once ETL has been run to completion successfully, run the following command:
<code>cd <wc_of_git_repo>/app/bottleui; python landing_page.py</code>
- To see web interface, go to http://localhost:8082/ in your webbrowser, click on the link "Check Top Thai Restaurants" to see results.
-* or just enter "http://localhost:8082/results_ui" in your webbrowser to go directly to the results display page

#Schema Design:
--
<pre>
{ _id: restaurant_id (unique),
  restaurant_id: (maps to CAMIS of csv),
  restaurant_name: (maps to DBA of csv),
  cuisine: (maps to CUISINE_DESCRIPTION of csv),
  boro: (maps to BORO of csv),
  address: { 
             building: (maps to BUILDING of csv),
             street: (maps to STREET of csv),
             zipcode: (maps to ZIPCODE of csv),
             phone: (maps to PHONE of csv)
            },
  grades: [
            { 
              grade_date: (maps to GRADE_DATE of csv),
              grade: (maps to GRADE of csv),
              score: (maps to SCORE of csv)
            },
            { 
              grade_date: .... ,
              grade: .... ,
              score: .... 
            }, ...
  ]
}
</pre>

#Description of Selection of Included schema design:
--
- Top Level Fields such as Restaurant_Id, Restaurant_Name, and Cusine, were identified as
"top level" fields because the entity can only have 1(one) value applied in that field.
- Restaurant_Id was identified as the identifier for the row as a unique entity (i.e. combination
of Restaurant_Name/DBA and Address/Building+Street+Zipcode).
- Address was made into a sub-document or dictionary of 4 fields (Building, Street, Zipcode, and Phone).
This was chosen so that any enhancement of map or location integration could be accomodated.  (One could
adjust the scope of viewing from restaurants in zipcode or street).
- The choice to not have Boro included in the Address dict was mostly due to 
boro is subject to only one value for a given entity (like the top level fields).
- Grades is a list of dictionaries that are comprised of 3 fields, grade_date, grade, and score.
These are the 3 values that constitute a valid record providing a Graded Inspecition.
There can be a history of Grades therefore the list of grade records are able to be appended as
they enter the system (and are not duplicates of records already recorded in list).
