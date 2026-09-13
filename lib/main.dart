import 'package:flutter/material.dart';
import 'game.dart';
import 'player.dart';
import 'settings.dart';
import 'layouts.dart';

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
      bool isPaused = !game.players.any((p) => p.timer.active);
      
      if (isPaused) {
        game.resume(player);
      } else if(player.timer.active){
        player.timer.toggleTimer();
        if (!player.timer.active) {
          game.nextPlayer();
        }
      }
    });
  }

  void handlePause() {
    setState(() {
      game.pause();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GameLayout(
          players: game.players,
          onTimerTap: handleTimerToggle,
          onLifeAdjust: adjustLife,
          onPause: handlePause,
        ),
      ),
    );
  }
}
