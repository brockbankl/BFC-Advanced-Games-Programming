# Assessment 2: Networked Rock-Paper-Scissors

> [!CAUTION]
> **Assessment 2 has not been released. Do not start this work yet.** This is draft teaching material and may be replaced or substantially changed before it is introduced in class.

This folder contains an early login-free version of the Python Rock-Paper-Scissors project that will eventually support the online multiplayer part of Advanced Games Programming.

When released, the exercise will separate the application into:

- `client.py`: Pygame interface and player input.
- `network.py`: client socket/network layer.
- `server.py`: authoritative server, matchmaking, and connection handling.
- `game.py`: shared Rock-Paper-Scissors game state.

Authentication and registration are intentionally **not** part of this student starter. A rudimentary login system will be introduced separately as a lecturer-led extension after the basic client/network/server flow is understood.

## Draft technical notes

- The current draft uses TCP on port `4040`.
- The server listens on local network interfaces.
- Clients default to `127.0.0.1` for same-machine testing.
- Two client instances connect to one server instance.
- `pickle` is retained from the original classroom project for local trusted-machine demonstrations. Deserialising pickle data from an untrusted peer is unsafe; this code is not suitable for deployment on the public internet.

Dependencies, commands, IP-address configuration, and the released assessment brief will be confirmed in class. Do not treat this README as the final Assessment 2 specification.
