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
        initialPlayers.add(Player(i));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _game.players.map((player) {
            return Expanded(
              child: GestureDetector(
                onTap: () => _handleTimerToggle(player),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: player.timer.active ? Colors.green.shade300 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Player ${player.order}',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Life: ${player.curLife}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text(
                          'Time: ${player.timer.curTime}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
