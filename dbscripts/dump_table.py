import MySQLdb
import sys
import codecs
from types import *
from optparse import OptionParser

def writeObject(obj,fileObj):
	t = type(obj)
	if t is int:
		fileObj.write(str(obj))
	elif t is long:
		fileObj.write(str(obj))
	elif t is float:
		fileObj.write(str(obj))
	elif t is str:
		#all strings should be of type 'unicode'
		print 'All strings should be unicode'
		assert False
	elif t is unicode:
		writeStr = obj.replace(u'\'',u'\'\'')
		writeStr = u'\'' + writeStr + u'\''

		fileObj.write( writeStr )
		
	elif t is NoneType:
		fileObj.write(u'NULL')
	else:
		sys.stderr.write('Unknown type encountered: ' + str(t) )
		assert False


def dumpTable(tableName,query,file):
	conn = MySQLdb.connect(
			host = "localhost", 
			user = "", 
			passwd = "", 
			db = "eve", 
			charset ="utf8",
			use_unicode = True)

	cursor = conn.cursor()

	cursor.execute('SET NAMES utf8;')
	cursor.execute('SET CHARACTER SET utf8;')
	cursor.execute('SET character_set_connection=utf8;')
	
	cursor.execute(query);
	
	fileObj = codecs.open(file,'a','utf-8');
	
	fileObj.write(u'BEGIN TRANSACTION;\n');
	
	sqlstart = u'INSERT INTO ' + tableName + u' VALUES('
	rowcount = int(cursor.rowcount)
	
	for i in range (0,rowcount) :
		row = cursor.fetchone()
		colcount = len(row) - 1
		fileObj.write(sqlstart)
		for j in range (0,colcount):
			writeObject(row[j],fileObj)
			fileObj.write(u',')
		writeObject(row[colcount],fileObj)
		fileObj.write(u');\n')
	
	fileObj.write(u'COMMIT TRANSACTION;\n')
	cursor.close()
	conn.close()
	fileObj.close()


if __name__ == "__main__":
	parser = OptionParser()
	parser.add_option("-q","--query",dest="query",help="Query to execute")
	parser.add_option("-t","--table",dest="table",help="Table the data will be going in to")
	parser.add_option("-f","--file",dest="file",help="output file name (append)");
	
	(options, args) = parser.parse_args()

	sys.stderr.write("dumping table " + options.table +"\n")

	uniTable = unicode(options.table)
	
	dumpTable(uniTable,options.query,options.file)

