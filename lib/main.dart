import 'package:flutter/material.dart';
import 'game.dart';
import 'player.dart';
import 'timer.dart';
import 'settings.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rope',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Rope'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Game game;

  @override
  void initState() {
    super.initState();

    List<Player> initialPlayers = [];
    for(int i = 0; i < Settings.players; i++){
        Player newPlayer = Player(i);
        newPlayer.timer.onTick = () {
          if (mounted) {
            setState(() {
              bool wasAlive = newPlayer.alive;
              newPlayer.alive = newPlayer.checkAlive();
              if (wasAlive && !newPlayer.alive && newPlayer.timer.active) {
                game.nextPlayer();
              }
            });
          }
        };
        initialPlayers.add(newPlayer);
    }
    game = Game(initialPlayers, Settings.players, 0);
  }

  void handleTimerToggle(Player player) {
    if (!player.alive) return;
    setState(() {
      if(player.timer.active){
      player.timer.toggleTimer();
      if (!player.timer.active) {
        game.nextPlayer();
      }
      }
    });
  }

  void adjustLife(Player player, int amount) {
    setState(() {
      bool wasAlive = player.alive;
      if (amount > 0) {
        player.addLife();
      } else {
        player.decreaseLife();
      }
      if (wasAlive && !player.alive && player.timer.active) {
        game.nextPlayer();
      }
    });
  }

  String formatTime(double seconds) {
    int min = seconds ~/ 60;
    int sec = (seconds % 60).toInt();
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: game.players.map((player) {
            Widget playerContent = Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: player.alive 
                      ? (player.timer.active ? Colors.green.shade300 : Colors.grey.shade300)
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
                                onPressed: () => adjustLife(player, -1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: player.alive ? Colors.grey.shade400 : Colors.grey.shade900,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                child: Text('-', style: TextStyle(fontSize: 48, color: player.alive ? Colors.black : Colors.red)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                '${player.curLife}',
                                style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: player.alive ? Colors.black : Colors.red),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => adjustLife(player, 1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: player.alive ? Colors.grey.shade400 : Colors.grey.shade900,
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
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () => handleTimerToggle(player),
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
              ),
            );
            return playerContent;
          }).toList(),
        ),
      ),
    );
  }
}
