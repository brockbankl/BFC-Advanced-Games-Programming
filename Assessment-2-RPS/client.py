import pygame

from network import Network


pygame.font.init()

WIDTH = 350
HEIGHT = 350
SERVER_IP = "127.0.0.1"


class Button:
    def __init__(self, text, x, y, color):
        self.text = text
        self.x = x
        self.y = y
        self.color = color
        self.width = 75
        self.height = 50

    def draw(self, window):
        pygame.draw.rect(
            window,
            self.color,
            (self.x, self.y, self.width, self.height),
        )
        font = pygame.font.SysFont("AvantGarde", 20)
        text = font.render(self.text, True, (255, 255, 255))
        window.blit(
            text,
            (
                self.x + self.width // 2 - text.get_width() // 2,
                self.y + self.height // 2 - text.get_height() // 2,
            ),
        )

    def click(self, position):
        x, y = position
        return (
            self.x <= x <= self.x + self.width
            and self.y <= y <= self.y + self.height
        )


BUTTONS = [
    Button("Rock", 25, 250, (0, 0, 0)),
    Button("Scissors", 125, 250, (255, 0, 0)),
    Button("Paper", 225, 250, (0, 255, 0)),
]


def redraw_window(window, game, player_number):
    window.fill((255, 255, 255))

    if not game.connected():
        font = pygame.font.SysFont("AvantGarde", 40)
        text = font.render("Waiting for Player...", True, (255, 125, 125))
        window.blit(
            text,
            (
                WIDTH // 2 - text.get_width() // 2,
                HEIGHT // 2 - text.get_height() // 2,
            ),
        )
    else:
        font = pygame.font.SysFont("AvantGarde", 30)
        window.blit(font.render("Your Move", True, (0, 255, 255)), (30, 100))
        window.blit(font.render("Opponent", True, (0, 255, 255)), (200, 100))

        move1 = game.get_player_move(0)
        move2 = game.get_player_move(1)

        if game.bothWent():
            text1 = font.render(move1, True, (0, 0, 0))
            text2 = font.render(move2, True, (0, 0, 0))
        else:
            if game.p1Went and player_number == 0:
                text1 = font.render(move1, True, (0, 0, 0))
            elif game.p1Went:
                text1 = font.render("Locked In", True, (0, 0, 0))
            else:
                text1 = font.render("Waiting...", True, (0, 0, 0))

            if game.p2Went and player_number == 1:
                text2 = font.render(move2, True, (0, 0, 0))
            elif game.p2Went:
                text2 = font.render("Locked In", True, (0, 0, 0))
            else:
                text2 = font.render("Waiting...", True, (0, 0, 0))

        if player_number == 1:
            window.blit(text2, (50, 175))
            window.blit(text1, (200, 175))
        else:
            window.blit(text1, (50, 175))
            window.blit(text2, (200, 175))

        for button in BUTTONS:
            button.draw(window)

    pygame.display.update()


def show_result(window, game, player_number):
    font = pygame.font.SysFont("AvantGarde", 40)
    winner = game.winner()

    if winner == player_number:
        text = font.render("You Won!", True, (0, 255, 0))
    elif winner == -1:
        text = font.render("Tie Game!", True, (125, 125, 125))
    else:
        text = font.render("You Lost...", True, (255, 0, 0))

    window.blit(
        text,
        (
            WIDTH // 2 - text.get_width() // 2,
            HEIGHT // 2 - text.get_height() // 2,
        ),
    )
    pygame.display.update()
    pygame.time.delay(2000)


def main(network, player_number):
    pygame.init()
    window = pygame.display.set_mode((WIDTH, HEIGHT))
    pygame.display.set_caption("Rock Paper Scissors Client")
    clock = pygame.time.Clock()
    running = True

    print("You are player", player_number)

    while running:
        clock.tick(60)
        game = network.send("get")
        if game is None:
            print("Could not get the game state.")
            break

        if game.bothWent():
            redraw_window(window, game, player_number)
            pygame.time.delay(500)
            show_result(window, game, player_number)
            game = network.send("reset")
            if game is None:
                break

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            elif event.type == pygame.MOUSEBUTTONDOWN and game.connected():
                for button in BUTTONS:
                    if not button.click(pygame.mouse.get_pos()):
                        continue
                    if player_number == 0 and not game.p1Went:
                        network.send(button.text)
                    elif player_number == 1 and not game.p2Went:
                        network.send(button.text)

        redraw_window(window, game, player_number)

    network.close()
    pygame.quit()


if __name__ == "__main__":
    connection = Network(SERVER_IP)
    if not connection.connected:
        print("Could not connect to the server.")
    else:
        player = connection.get_player_number()
        if player is not None:
            main(connection, player)
