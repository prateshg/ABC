import socket

host = ''        # Symbolic name meaning all available interfaces
port = 12345     # Arbitrary non-privileged port
#s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
s.bind((host, port))
while True:
	data, addr = s.recvfrom(1500)
	s.sendto(data, addr)
