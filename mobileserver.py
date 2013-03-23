import socket,time,thread,random
from mobiledb import *

def handler(clientsock,addr):
	count = 0
	a,b,c = "localhost","root","sun326";
	conn = DBHelper(a,b,c);
	while 1:
		data=clientsock.recv(1024)
		if data == "Exit":
			clientsock.close();
			sys.exit(0)
		insertInDB(data,conn);
		clientsock.send('ok');


if __name__ == '__main__':
	HOST = 'localhost'
	#~ PORT = 5005
	PORT = input("Port No: ");
	ADDR = (HOST, PORT)
	serversock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	serversock.bind(ADDR)
	serversock.listen(5)
	while 1:
		print 'waiting for connection'
		clientsock, addr = serversock.accept()
		print 'connected from:', addr
		thread.start_new_thread(handler, (clientsock, addr))
