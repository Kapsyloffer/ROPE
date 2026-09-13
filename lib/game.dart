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
    
    //TODO: Fix interrupt bug.
    void nextPlayer() {
        if (players.isEmpty) return;

        activePlayerIndex = (activePlayerIndex + 1) % playerCount;

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
