import 'player.dart';
import 'timer.dart';

class Game {
    List<Player> players;
    int playerCount;
    int activePlayerIndex;

    Game(this.players, this.playerCount, this.activePlayerIndex);

    void Reset(){
        for (var player in players) {
            player.Reset();
        }
        activePlayerIndex = 0;
        if(players.isNotEmpty) {
            players[activePlayerIndex].timer.active = true;
        }
    }
    
    //TODO: Fix interrupt bug.
    void nextPlayer() {
        if (players.isEmpty) return;

        activePlayerIndex = (activePlayerIndex + 1) % playerCount;

        for (var i = 0; i < players.length; i++) {
            players[i].timer.active = false;
            if (i == activePlayerIndex) {
                players[i].timer.active = true;
            }
        }
    }

    void interruptTurn() {
        //TODO
    }
}
