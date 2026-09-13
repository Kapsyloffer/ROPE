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
  late Game _game;

  @override
  void initState() {
    super.initState();

    List<Player> initialPlayers = [];
    for(int i = 0; i < Settings.players; i++){
        Player newPlayer = Player(i);
        newPlayer.timer.onTick = () {
          if (mounted) {
            setState(() {});
          }
        };
        initialPlayers.add(newPlayer);
    }
    _game = Game(initialPlayers, Settings.players, 0);
  }

  void _handleTimerToggle(Player player) {
    setState(() {
      if(player.timer.active){
      player.timer.toggleTimer();
      if (!player.timer.active) {
        _game.nextPlayer();
      }
      }
    });
  }

  void adjustLife(Player player, int amount) {
    setState(() {
      if (amount > 0) {
        player.addLife();
      } else {
        player.decreaseLife();
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
          children: _game.players.map((player) {
            Widget playerContent = Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                decoration: BoxDecoration(
                  color: player.timer.active ? Colors.green.shade300 : Colors.grey.shade300,
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
                                  backgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                child: const Text('-', style: TextStyle(fontSize: 48, color: Colors.black)),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                '${player.curLife}',
                                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                onPressed: () => adjustLife(player, 1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade400,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                                ),
                                child: const Text('+', style: TextStyle(fontSize: 48, color: Colors.black)),
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
                        onTap: () => _handleTimerToggle(player),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: player.timer.active ? Colors.green.shade500 : Colors.grey.shade400,
                            border: Border.all(color: player.timer.active ? Colors.greenAccent : Colors.grey, width: 4),
                          ),
                          child: Center(
                            child: Text(
                              formatTime(player.timer.curTime),
                              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
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
