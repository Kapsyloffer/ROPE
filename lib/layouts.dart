import 'package:flutter/material.dart';
import 'player.dart';
import 'settings.dart';

String formatTime(double seconds) {
  int min = seconds ~/ 60;
  int sec = (seconds % 60).toInt();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

class PlayerWidget extends StatelessWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final Function(int) onLifeAdjust;
  final int rotations;

  const PlayerWidget({
    super.key,
    required this.player,
    required this.onTimerTap,
    required this.onLifeAdjust,
    this.rotations = 0,
  });

  @override
  Widget build(BuildContext context) {
    Color activeButtonColor = Settings.useTimer && player.timer.active 
        ? Colors.green.shade400 
        : Settings.playerColors[player.order];
        
    Color buttonColor = player.alive ? activeButtonColor : Colors.grey.shade900;

    Widget content = Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: player.alive 
            ? (Settings.useTimer && player.timer.active ? Colors.green.shade300 : Settings.playerColors[player.order])
            : Colors.grey.shade800,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          // Life 
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => onLifeAdjust(-1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                      ),
                      child: Text('-', style: TextStyle(fontSize: 48, color: player.alive ? Colors.black : Colors.red)),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        Settings.playerNames[player.order],
                        style: TextStyle(
                            fontSize: 16, 
                            fontWeight: FontWeight.bold, 
                            color: player.alive ? Colors.black54 : Colors.red.shade900
                        ),
                      ),
                      Text(
                        '${player.curLife}',
                        style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: player.alive ? Colors.black : Colors.red),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => onLifeAdjust(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                      ),
                      child: Text('+', style: TextStyle(fontSize: 48, color: player.alive ? Colors.black : Colors.red)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Timer 
          if (Settings.useTimer)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onTimerTap,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: player.alive
                        ? (player.timer.active ? Colors.green.shade500 : Colors.grey.shade400)
                        : Colors.grey.shade900,
                    border: Border.all(
                        color: player.alive 
                            ? (player.timer.active ? Colors.greenAccent : Colors.grey)
                            : Colors.red.shade900, 
                        width: 4),
                  ),
                  child: Center(
                    child: Text(
                      formatTime(player.timer.curTime),
                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: player.alive ? Colors.black : Colors.red),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (rotations > 0) {
      return RotatedBox(quarterTurns: rotations, child: content);
    }
    return content;
  }
}

class MenuRow extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;

  const MenuRow({
    super.key,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.0,
      color: Colors.black87,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.stop, color: Colors.white, size: 32),
            onPressed: onPause,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 32),
            onPressed: onReset,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white, size: 32),
            onPressed: onSettings,
          ),
        ],
      ),
    );
  }
}

class GameLayout extends StatelessWidget {
  final List<Player> players;
  final Function(Player) onTimerTap;
  final Function(Player, int) onLifeAdjust;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;

  const GameLayout({
    super.key,
    required this.players,
    required this.onTimerTap,
    required this.onLifeAdjust,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (players.length == 2) {
      return Column(
        children: [
          Expanded(
            child: PlayerWidget(
              player: players[0], 
              onTimerTap: () => onTimerTap(players[0]), 
              onLifeAdjust: (amt) => onLifeAdjust(players[0], amt), 
              rotations: 2,
            ),
          ),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
          ),
          Expanded(
            child: PlayerWidget(
              player: players[1], 
              onTimerTap: () => onTimerTap(players[1]), 
              onLifeAdjust: (amt) => onLifeAdjust(players[1], amt), 
              rotations: 0,
            ),
          ),
        ],
      );
    } else if (players.length == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PlayerWidget(
                    player: players[0], 
                    onTimerTap: () => onTimerTap(players[0]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[0], amt), 
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[1], 
                    onTimerTap: () => onTimerTap(players[1]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[1], amt), 
                    rotations: 3,
                  ),
                ),
              ],
            ),
          ),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
          ),
          Expanded(
            child: PlayerWidget(
              player: players[2], 
              onTimerTap: () => onTimerTap(players[2]), 
              onLifeAdjust: (amt) => onLifeAdjust(players[2], amt), 
              rotations: 0,
            ),
          ),
        ],
      );
    } else if (players.length == 4) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PlayerWidget(
                    player: players[0], 
                    onTimerTap: () => onTimerTap(players[0]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[0], amt), 
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[1], 
                    onTimerTap: () => onTimerTap(players[1]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[1], amt), 
                    rotations: 3,
                  ),
                ),
              ],
            ),
          ),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PlayerWidget(
                    player: players[3], 
                    onTimerTap: () => onTimerTap(players[3]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[3], amt), 
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[2], 
                    onTimerTap: () => onTimerTap(players[2]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[2], amt), 
                    rotations: 3,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    return Column(
      children: players.map((p) => Expanded(
        child: PlayerWidget(
          player: p, 
          onTimerTap: () => onTimerTap(p), 
          onLifeAdjust: (amt) => onLifeAdjust(p, amt),
        ),
      )).toList(),
    );
  }
}
