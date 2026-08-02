import pickle
import socket
import threading

from game import Game


HOST = ""
PORT = 4040

server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

try:
    server_socket.bind((HOST, PORT))
except OSError as error:
    raise SystemExit(f"Could not bind the server to port {PORT}: {error}")

server_socket.listen(2)
print(f"Rock Paper Scissors server listening on port {PORT}")

games = {}
games_lock = threading.Lock()
waiting_game_id = None
next_game_id = 0


def assign_player():
    global waiting_game_id, next_game_id

    with games_lock:
        if waiting_game_id is None:
            game_id = next_game_id
            next_game_id += 1
            games[game_id] = Game(game_id)
            waiting_game_id = game_id
            return 0, game_id

        game_id = waiting_game_id
        games[game_id].ready = True
        waiting_game_id = None
        return 1, game_id


def remove_game(game_id):
    global waiting_game_id

    with games_lock:
        games.pop(game_id, None)
        if waiting_game_id == game_id:
            waiting_game_id = None


def handle_client(connection, player_number, game_id):
    print(f"Starting player {player_number} in game {game_id}")

    try:
        while True:
            data = connection.recv(4096)
            if not data:
                break

            command = data.decode("utf-8")
            game = games.get(game_id)
            if game is None:
                break

            if command == "reset":
                game.resetWent()
            elif command != "get":
                game.play(player_number, command)

            connection.sendall(pickle.dumps(game))
    except (ConnectionError, OSError):
        pass
    finally:
        print(f"Player {player_number} left game {game_id}")
        remove_game(game_id)
        connection.close()


while True:
    client_connection, client_address = server_socket.accept()
    player, assigned_game = assign_player()
    print(f"Connected to {client_address}; assigned player {player}")
    client_connection.sendall(str(player).encode("utf-8"))
    threading.Thread(
        target=handle_client,
        args=(client_connection, player, assigned_game),
        daemon=True,
    ).start()
