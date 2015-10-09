<!DOCTYPE html>
<html lang="en">
 
<head>
    <meta charset="utf-8" />
    <link rel="stylesheet" href="style.css">
    <link href="images/favicon.ico" rel="shortcut icon">
    <title>NYC Restaurants Statistics</title>
</head>
 
<body>
 <div style="clear:both;"><span>
    <div style="clear:both; text-align: center;"><h1>NYC Restaurants Statistics</h1></div>
    <div style="clear: both; text-align: center;"><h2>made for The Orchard in October of 2015 by Eric Galuskin</h2></div>
    <div style="float: left;"><h3>Number of records loaded by the ETL: {{num_recs_loaded}}</h3></div><div>&;nbsp</div>
</span> </div>
    <div class="container">
    <!--<p>{{# body #}}</p>-->
 
    <table border="1">
        <tr>
          <td class="label">
            <div>Number of records loaded by the ETL</div>
          </td>
          <td>
            <div>{{num_recs_loaded}}</div>
          </td>
        </tr>
        <tr>
          <td class="label">
            <div>Number of Distinct Cusines</div>
          </td>
          <td>
            <div>{{num_distinct_cuisines}}</div>
          </td>
        </tr>
      </table>
      
<table border="1">
%for thai_restaurant in top_thai_restaurants:
<tr>
<td class="label">
Restaurant
</td>
<td>
{{thai_restaurant}}
</td>
</tr>
</table>

</div>
 <div style="clear:both;"><span>&;nbsp</span></div>
 
</body>    
</html>