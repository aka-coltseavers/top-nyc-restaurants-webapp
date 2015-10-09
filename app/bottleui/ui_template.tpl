<!DOCTYPE html>
<html>
<head>
<title>NYC Restaurants Statistics</title>
</head>
<body>

<h1>NYC Restaurants Statistics</h1>
    <table border="1">
        <tr>
          <td class="label">
            Number of records loaded by the ETL
          </td>
          <td>
            {{num_recs_loaded}}
          </td>
        </tr>
        <tr>
          <td class="label">
            Number of Distinct Cusines
          </td>
          <td>
            {{num_distinct_cuisines}}
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
</body>
</html>