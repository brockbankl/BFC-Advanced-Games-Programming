class Game:
    def __init__(self, game_id):
        self.p1Went = False
        self.p2Went = False
        self.ready = False
        self.id = game_id
        self.moves = [None, None]

    def get_player_move(self, player):
        return self.moves[player]

    def play(self, player, move):
        self.moves[player] = move
        if player == 0:
            self.p1Went = True
        else:
            self.p2Went = True

    def connected(self):
        return self.ready

    def bothWent(self):
        return self.p1Went and self.p2Went

    def winner(self):
        player_one = self.moves[0].upper()[0]
        player_two = self.moves[1].upper()[0]

        if player_one == player_two:
            return -1

        winning_pairs = {("R", "S"), ("P", "R"), ("S", "P")}
        return 0 if (player_one, player_two) in winning_pairs else 1

    def resetWent(self):
        self.p1Went = False
        self.p2Went = False
