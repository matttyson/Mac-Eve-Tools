import MySQLdb
import dump_table
from optparse import OptionParser

#calculate the ship attribute tables.

def dumpAttribute(conn,query,attrNum):
	cursor = conn.cursor()
	cursor.execute(query)

	rowcount = int(cursor.rowcount)
	
	conn.query("BEGIN;");

	for i in range (0,rowcount):
		row = cursor.fetchone()
		
		row1 = ""
		row2 = ""

		if row[1] == None:
			row1 = "NULL"
		else:
			row1 = row[1]

		if row[2] == None:
			row2 = "NULL"
		else:
			row2 = row[2]

		insertQuery = "INSERT INTO metAttributeTypes VALUES (" + str(row[0]) + "," + str(row1) + "," \
			+ str(row2) + ",'" + str(row[3]) + "','"+ str(row[4])+"'," + str(attrNum) + ");"
	
	#	print insertQuery

		conn.query(insertQuery)

	conn.query("COMMIT;")
	cursor.close()
	

if __name__ == "__main__":
	conn = MySQLdb.connect(host = "localhost", user = "", passwd = "", db = "eve")
	parser = OptionParser()
	parser.add_option("-f","--file",dest="file",help="output file name (append)");
	(options, args) = parser.parse_args()


#   SELECT attributeID, graphicID, unitID, displayName FROM dgmAttributeTypes
#
# Drones 1 (283,1271)
# Structure 2 (113,111,109,110)
# Armour 3 (265,267,268,269,270)
# Shield 4 (263,349,271,272,273,274)
# Capacitor 5 (482,55)
# Targeting 6 (75,192,208,209,210,211,552)
# Propulsion 7 (37)
# Misc 8
# Fitting 9 (12,13,14,101,102,1154)
#
	querybase = "SELECT attributeID, unitID, iconID, displayName, attributeName FROM dgmAttributeTypes WHERE attributeID IN "

	drones = "(283,1271)"
	structure = "(9,113,111,109,110)"
	armour = "(265,267,268,269,270)"
	shield = "(263,349,271,272,273,274,479)"
	capacitor = "(482,55)"
	targeting = "(76,192,208,209,210,211,552)"
	propulsion = "(37)";
	fitting = "(12,13,14,101,102,1154,1547,1132,11,48)"
	
	dropTable = "DROP TABLE IF EXISTS metAttributeTypes;";
	tableQuery = """CREATE TABLE metAttributeTypes(
			attributeID INTEGER ,
			unitID INTEGER ,
			iconID INTEGER ,
			displayName VARCHAR(100),
			attributeName VARCHAR(100),
			typeGroupID INTEGER);"""


	#create query table
	conn.query(dropTable)
	conn.query(tableQuery)


	runquery = querybase + drones + ";"
	dumpAttribute(conn,runquery,1)

	runquery = querybase + structure + ";"
	dumpAttribute(conn,runquery,2)

	runquery = querybase + armour + ";"
	dumpAttribute(conn,runquery,3)

	runquery = querybase + shield + ";"
	dumpAttribute(conn,runquery,4)
	
	runquery = querybase + capacitor + ";"
	dumpAttribute(conn,runquery,5)
	
	runquery = querybase + targeting + ";"
	dumpAttribute(conn,runquery,6)
	
	runquery = querybase + propulsion + ";"
	dumpAttribute(conn,runquery,7)

	runquery = querybase + fitting + ";"
	dumpAttribute(conn,runquery,9)

	otherQuery = """SELECT attributeID, unitID, iconID, displayName, attributeName
		FROM dgmAttributeTypes WHERE attributeID NOT IN
		(SELECT attributeID FROM metAttributeTypes);""";
	dumpAttribute(conn,otherQuery,8)
	
	dquery = "SELECT attributeID, unitID, iconID, displayName, attributeName, typeGroupID FROM metAttributeTypes;"
	dump_table.dumpTable("metAttributeTypes",dquery,options.file);

	#conn.query(dropTable)
	conn.close()

#rowcount = int(cursor.rowcount)

#print 'BEGIN TRANSACTION;'
#for i in range(0,rowcount)

