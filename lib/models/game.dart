import 'player.dart';
import 'settings.dart';

enum TurnType { normal, interrupt, priority }

class StackItem {
  final int playerId;
  final TurnType returnType;
  final bool isFresh; 

  StackItem(this.playerId, this.returnType, {this.isFresh = false});
}

class Game {
  List<Player> players;
  int playerCount;
  int activePlayerIndex;
  List<StackItem> turnStack = [];
  TurnType activeTurnType = TurnType.normal;

  Game(this.players, this.playerCount, this.activePlayerIndex) {
    if (players.isNotEmpty) {
      for (var i = 0; i < players.length; i++) {
        players[i].timer.active = false;
        players[i].timer.clock?.cancel();
      }
    }
  }

  void _syncPlayerStates() {
    for (var p in players) {
      p.queuePosition = 0;
      p.isInterrupted = false;
      p.isInterrupting = false;
      p.isPriority = false;
    }

    int pos = 1;
    for (int i = 0; i < turnStack.length; i++) {
      players[turnStack[i].playerId].queuePosition = pos++;
      players[turnStack[i].playerId].isInterrupted = true;
    }

    if (activeTurnType == TurnType.interrupt) {
      players[activePlayerIndex].isInterrupting = true;
    } else if (activeTurnType == TurnType.priority) {
      players[activePlayerIndex].isPriority = true;
    }
  }

  void reset() {
    for (var player in players) {
      player.reset();
    }
    activePlayerIndex = 0;
    turnStack.clear();
    activeTurnType = TurnType.normal;
    _syncPlayerStates();
  }

  void pause() {
    for (var i = 0; i < players.length; i++) {
      players[i].timer.active = false;
      players[i].timer.resetTurn();
      players[i].timer.clock?.cancel();
    }
    turnStack.clear();
    activeTurnType = TurnType.normal;
    _syncPlayerStates();
  }

  void resume(Player player) {
    int idx = players.indexOf(player);
    if (idx != -1) {
      activePlayerIndex = idx;
      turnStack.clear();
      activeTurnType = TurnType.normal;
      _syncPlayerStates();

      for (var i = 0; i < players.length; i++) {
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
      StackItem popped = turnStack.removeLast();

      if (players[popped.playerId].alive) {
        activePlayerIndex = popped.playerId;
        activeTurnType = popped.returnType;

        if (activeTurnType == TurnType.priority && popped.isFresh) {
          players[activePlayerIndex].timer.curTime += Settings.prio;
        }

        _syncPlayerStates();

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

    activeTurnType = TurnType.normal;
    do {
      activePlayerIndex = (activePlayerIndex + 1) % playerCount;
    } while (!players[activePlayerIndex].alive);

    _syncPlayerStates();

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

    turnStack.add(StackItem(activePlayerIndex, activeTurnType, isFresh: false));

    activePlayerIndex = idx;
    activeTurnType = TurnType.interrupt;

    _syncPlayerStates();

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

  void priorityCheck() {
    if (players.isEmpty) return;

    int a = activePlayerIndex;
    List<int> priorityOrder = [];

    for (int i = 1; i < playerCount; i++) {
      int p = (a + i) % playerCount;
      if (players[p].alive) {
        priorityOrder.add(p);
      }
    }

    if (priorityOrder.isEmpty) return;

    turnStack.add(StackItem(a, activeTurnType, isFresh: false));

    int nextActive = priorityOrder.first;

    for (int i = priorityOrder.length - 1; i >= 1; i--) {
      turnStack.add(
        StackItem(priorityOrder[i], TurnType.priority, isFresh: true),
      );
    }

    activePlayerIndex = nextActive;
    activeTurnType = TurnType.priority;

    players[activePlayerIndex].timer.curTime += Settings.prio;

    _syncPlayerStates();

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
