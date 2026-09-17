import 'player.dart';

class Game {
  List<Player> players;
  int playerCount;
  int activePlayerIndex;
  List<int> turnStack = [];

  Game(this.players, this.playerCount, this.activePlayerIndex) {
    if (players.isNotEmpty) {
      for (var i = 0; i < players.length; i++) {
        players[i].timer.active = false;
        players[i].timer.clock?.cancel();
      }
    }
  }

  void reset() {
    for (var player in players) {
      player.reset();
    }
    activePlayerIndex = 0;
    turnStack.clear();
  }

  void pause() {
    for (var i = 0; i < players.length; i++) {
      players[i].timer.active = false;
      players[i].timer.resetTurn();
      players[i].timer.clock?.cancel();
      players[i].isInterrupted = false;
    }
    turnStack.clear();
  }

  void resume(Player player) {
    int idx = players.indexOf(player);
    if (idx != -1) {
      activePlayerIndex = idx;
      turnStack.clear();
      for (var i = 0; i < players.length; i++) {
        players[i].isInterrupted = false;
        if (i == activePlayerIndex) {
          players[i].timer.active = true;
          players[i].timer.startClock();
        } else {
          players[i].timer.active = false;
          players[i].timer.resetTurn();
          players[i].timer.clock?.cancel();
        }
      }
    }
  }

  void checkState(Player player, bool wasAlive) {
    int aliveCount = players.where((p) => p.alive).length;
    if (aliveCount <= 1) {
      pause();
    } else if (wasAlive && !player.alive && player.timer.active) {
      nextPlayer();
    }
  }

  void nextPlayer() {
    if (players.isEmpty) return;

    int aliveCount = players.where((p) => p.alive).length;
    if (aliveCount <= 1) {
      pause();
      return;
    }

    while (turnStack.isNotEmpty) {
      int poppedIndex = turnStack.removeLast();
      players[poppedIndex].isInterrupted = false;
      if (players[poppedIndex].alive) {
        activePlayerIndex = poppedIndex;
        for (var i = 0; i < players.length; i++) {
          if (i == activePlayerIndex) {
            players[i].timer.active = true;
            players[i].timer.startClock();
          } else {
            players[i].timer.active = false;
            players[i].timer.clock?.cancel();
          }
        }
        return;
      }
    }

    do {
      activePlayerIndex = (activePlayerIndex + 1) % playerCount;
    } while (!players[activePlayerIndex].alive);

    for (var i = 0; i < players.length; i++) {
      if (i == activePlayerIndex) {
        players[i].timer.active = true;
        players[i].timer.resetTurn();
        players[i].timer.startClock();
      } else {
        players[i].timer.active = false;
        players[i].timer.resetTurn();
        players[i].timer.clock?.cancel();
      }
    }
  }

  void interruptTurn(Player interrupter) {
    int idx = players.indexOf(interrupter);
    if (idx == -1 || idx == activePlayerIndex || !interrupter.alive) return;

    players[activePlayerIndex].isInterrupted = true;
    turnStack.add(activePlayerIndex);
    activePlayerIndex = idx;

    for (var i = 0; i < players.length; i++) {
      if (i == activePlayerIndex) {
        players[i].timer.active = true;
        players[i].timer.resetTurn();
        players[i].timer.startClock();
      } else {
        if (players[i].timer.active) {
          players[i].timer.active = false;
          players[i].timer.clock?.cancel();
        }
      }
    }
  }
}
