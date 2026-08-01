import pickle
import socket


class Network:
    def __init__(self, server_ip="127.0.0.1", port=4040):
        self.client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.server = server_ip
        self.port = port
        self.address = (self.server, self.port)
        self.connected = False
        self.player_number = None
        self.connect()

    def connect(self):
        try:
            self.client.connect(self.address)
            self.connected = True
        except OSError as error:
            print("Connection error:", error)
            self.connected = False

    def get_player_number(self):
        try:
            data = self.client.recv(2048).decode("utf-8").strip()
            self.player_number = int(data)
            return self.player_number
        except (OSError, TypeError, ValueError):
            return None

    def send(self, data):
        try:
            self.client.sendall(str(data).encode("utf-8"))
            return pickle.loads(self.client.recv(4096))
        except (OSError, pickle.PickleError, EOFError) as error:
            print("Network error:", error)
            return None

    def close(self):
        self.client.close()
