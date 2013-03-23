import MySQLdb
import sys
from getpass import *

def createTable(trainID,cursor):
	try:
		x = cursor.execute ("Create TABLE IF NOT EXISTS `%s` (SensorID CHAR(40),accX     CHAR(40),  accY CHAR(40),accZ CHAR(40))",trainID);
		print x;
	except:
		print "Error in Creating";
	#~ cursor.commit();
		
def insertINTable(data,cursor):
	accX ,accY,accZ,sensorID,trainID = data[1],data[3],data[5],data[6],data[7];
	Query1 = "INSERT INTO `'" + trainID+"'` (`accX`, `accY`, `accZ`,`SensorID`) VALUES (%s,%s,%s,%s)"  # 4 fields in table
	print Query1
	try:
		x = cursor.execute(Query1,(accX,accY,accZ,sensorID))
	except:
		print "Erpor in insertion ",accX,accY,accZ,sensorID
		print "Query of Error",Query1

def DBHelper(a,b,c):                       # Establish Connection
	try: return MySQLdb.connect (host = a,user = b,passwd = c,db = "CS634")
	except :
		print "#############################################"
		print "#######Error in Establishing Connection###### "
		print "#############################################" 
		sys.exit(0)


def insertInDB(data,conn):
	cursor = conn.cursor ()
	try:
		data = (data.split('W01#')[1]).split('#');
		#~ data = ['ACCX', '22', 'ACCY', '55', 'ACCZ', '1061', '1', '0013A2004086A4B7', '100', '80\x19\n']
		trainID = data[7];
		createTable(trainID,cursor);
		insertINTable(data,cursor);
		#~ try:
			#~ x = cursor.execute("INSERT INTO `'0013A2004086A4B7'` (`accX`, `accY`, `accZ`,`SensorID`) VALUES (%s,%s,%s,%s)" ,('22','22','22','1'));
		#~ except:
			#~ print "bhak "
		# 4 fields in table
		#~ print data;
	except:
		pass;
	return;

