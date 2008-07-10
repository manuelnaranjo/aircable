from socket import *

class rfcommClient:
	__socket  = None;
	__address  = None;
	__channel = None;
	__service = None;
	
	define __init__(self, socket):
		self.__socket = socket;

	define __init__(self, address, channel=-1, service='spp'):
		self.__address = address;
		self.__channel = channel;
		self.__service = service;

	def connect(self):
		if self.__channel < 1:
			System.err.println("Service resolving not implemented" +
					" yet....");
			return;

		if (self.__socket == None):
			self.__socket = socket( AF_BLUETOOTH, SOCK_STREAM, 
					BTPROTO_RFCOMM );
		
		self.connect(self.__address, self.__channel);

	def __checkConnected(self):
		if self.__socket == None:
			System.err.println("Not connected");
			return

	def send(self, text):
		self.__checkConnected();
		
		self.__socket.sendall(text);

	def read(self, bytes=10):
		self.__checkConnected();
		
		return self.__socket.recv(bytes);

	__pattern = compile(r'.*\n');

	def readLine(self):
		self.__checkConnected();
		
		out = buffer("");
		
		while ( 1 ):
			out += self.read(1);

			if self.__pattern.match(out):
				return replace(out, '\n', '');

