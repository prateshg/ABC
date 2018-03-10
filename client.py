import socket
import sys
import time
import os
from socket import error as socket_error

host = os.environ['MAHIMAHI_BASE'] 
port = 12345
credit = 0                   # The same port as used by the server
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
MESSAGE=""
t =[]
for i in range(1462):
	MESSAGE=MESSAGE+"a"
MESSAGE=MESSAGE+ "0123456888"

for i in range(30):
	s.sendto(MESSAGE, (host, port))
	time.sleep(0.001)

start = time.time()

for i in range(1000000):
	now=time.time()
	if now>start+140:
			break
	s.settimeout(0.1)
	data = ''
	try:
		data = s.recv(1500)
	except socket_error:
		s.sendto(MESSAGE, (host, port))
		s.settimeout(None)
		continue
	s.settimeout(None)
	if (data.endswith('888')):
		s.sendto(MESSAGE, (host, port))
		#time.sleep(0.001)
		s.sendto(MESSAGE, (host, port))		
s.close()
