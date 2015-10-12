<!doctype html>
<html>
<head>
<title>
Eric Galuskin Welcomes you to his NYC Restaurants Stat Project
</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<style type="text/css"><!-- body { margin-left: 0px; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; }
	.style1 { font-family: Arial, Helvetica, sans-serif; font-weight: bold; }
	.style2 {font-family: Arial, Helvetica, sans-serif}
	.style3 { font-size: 22px; color: #FFFFFF; font-weight: bold; }
	.style4 {font-size: 16px}
	.style4b {font-family: Arial, Helvetica, sans-serif;font-size: 16px}
	.style5 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; }
	.style6 {font-family: Arial, Helvetica, sans-serif; font-size: 12px; margin-left: 10px;}
--></style>
</head>
<body>
<table width="640" border="0" align="center" cellpadding="0" cellspacing="0">
    <tr>
        <td bgcolor="#345d9b">
            <table width="100%" border="0" cellspacing="1" cellpadding="0">
                <tr>
                    <td bgcolor="#ffffff">
                        <table width="960" height="640" border="0" cellpadding="0" cellspacing="1">
                            <tr>
                                <td height="80" bgcolor="#36609d">
                                    <div class="style3" align="center">
                                    <FONT face="Tahoma"> Eric G's NYC Restaurants Stat Project</FONT>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td height="20" bgcolor="#36609d">&nbsp;</td>
                      </tr>
                      <tr>
                         <td height="80" bgcolor="#b9c8e1">
                                    <div class="style1 style4" align="center">
                                        <a href="/home">ETL with Fresh Data</a> ~
                                        <a href="/myapp/results_ui">Check for Top 10 Grades for a Cusine</a> 
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td valign="top" bgcolor="#b9c8e1">
                                    <table width="90%" border="0" align="center" cellpadding="0" cellspacing="6">
                                    <tr>
                                        <td>
                                             <div style="clear: both;">Number of records loaded by the ETL: {{num_recs_loaded}}</div>
                                             <div style="clear: both;">&nbsp;</div>
                                             <div style="clear: both;">Number of Distinct Cusines: {{num_distinct_cuisines}}</div>
                                             <div style="clear: both;">&nbsp;</div>
                                        </td>
                                    </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td>
                                    <table width="90%" border="0" align="center" cellpadding="0" cellspacing="6">
                                        %for thai_restaurant in top_thai_restaurants:
                                        <tr>
                                            <td class="label">Restaurant</td>
                                            <td>{{thai_restaurant}}</td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                        </table>
                    </td>
                </tr>
                <tr>
                    <td height="40" bgcolor="#36609d">
                        <div align="center">
                            <p align="center" class="style2 style3">
                                <FONT face="Tahoma">made for The Orchard in October of 2015 by Eric Galuskin </FONT>
                            </p>
                        </div>
                    </td>
                </tr>
            </table>
        </td>
    </tr>
</table>
</body>
</html>