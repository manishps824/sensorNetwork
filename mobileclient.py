import socket,sys,time,thread,random


def readfile(x,client_socket):
	fp = open(x);
	i = fp.readline()
	while i:
		if i == "\n":
			i = fp.readline();
			continue;
		else:
			print "I is ", i
			i = str(i)
			client_socket.send(i)
			x = client_socket.recv(512)
			if not x:
				print "Error while sending"
				client_socket.close();
				sys.exit(0)
		i = fp.readline()
	data = "Exit";
	client_socket.send(data)
	client_socket.close()
	fp.close();
	return False;  # reached EOF

if __name__ == '__main__':
	client_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	PORT = input("Port No: ");
	client_socket.connect(("localhost", PORT))
	data = readfile('data.txt',client_socket);
	print "File Send:P"
	sys.exit(0);
