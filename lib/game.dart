import 'player.dart';
import 'timer.dart';

class Game {
    List<Player> players;
    int playerCount;
    int activePlayerIndex;

    Game(this.players, this.playerCount, this.activePlayerIndex) {
        if (players.isNotEmpty) {
            for (var i = 0; i < players.length; i++) {
                if (i == activePlayerIndex) {
                    players[i].timer.active = true;
                    players[i].timer.startClock();
                } else {
                    players[i].timer.active = false;
                    players[i].timer.clock?.cancel();
                }
            }
        }
    }

    void Reset(){
        for (var player in players) {
            player.Reset();
        }
        activePlayerIndex = 0;
        if(players.isNotEmpty) {
            players[activePlayerIndex].timer.active = true;
            players[activePlayerIndex].timer.startClock();
        }
    }

    void pause() {
        for (var i = 0; i < players.length; i++) {
            players[i].timer.active = false;
            players[i].timer.clock?.cancel();
        }
    }

    void resume(Player player) {
        int idx = players.indexOf(player);
        if (idx != -1) {
            activePlayerIndex = idx;
            for (var i = 0; i < players.length; i++) {
                if (i == activePlayerIndex) {
                    players[i].timer.active = true;
                    players[i].timer.startClock();
                } else {
                    players[i].timer.active = false;
                    players[i].timer.clock?.cancel();
                }
            }
        }
    }
    
    //TODO: Fix interrupt bug.
    void nextPlayer() {
        if (players.isEmpty) return;

        bool anyAlive = players.any((p) => p.alive);
        if (!anyAlive) {
            for (var i = 0; i < players.length; i++) {
                players[i].timer.active = false;
                players[i].timer.clock?.cancel();
            }
            return;
        }

        do {
            activePlayerIndex = (activePlayerIndex + 1) % playerCount;
        } while (!players[activePlayerIndex].alive);

        for (var i = 0; i < players.length; i++) {
            if (i == activePlayerIndex) {
                players[i].timer.active = true;
                players[i].timer.startClock();
            } else {
                players[i].timer.active = false;
                players[i].timer.clock?.cancel();
            }
        }
    }

    void interruptTurn() {
        //TODO
    }
}
