import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'game.dart';
import 'player.dart';
import 'settings.dart';
import 'layouts.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Settings.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ROPE',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'ROPE'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  late Game game;
  bool showMenu = false;

  @override
  void initState() {
    super.initState();
    initGame();
  }

  void initGame() {
    List<Player> initialPlayers = [];
    for (int i = 0; i < Settings.players; i++) {
        Player newPlayer = Player(i);
        newPlayer.timer.onTick = () {
          if (mounted) {
            setState(() {
              bool wasAlive = newPlayer.alive;
              newPlayer.alive = newPlayer.checkAlive();
              game.checkState(newPlayer, wasAlive);
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
      } else if (player.timer.active) {
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

  void handleReset() {
    setState(() {
      initGame();
    });
  }

  void openSettings() async {
    game.pause();
    
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
    
    setState(() {});
  }

  void adjustLife(Player player, int amount) {
    setState(() {
      bool wasAlive = player.alive;
      if (amount > 0) {
        player.addLife(amount);
      } else {
        player.decreaseLife(amount.abs());
      }
      game.checkState(player, wasAlive);
    });
  }

  void adjustCommanderDamage(Player player, int fromPlayerId, int amount) {
    setState(() {
      int currentDamage = player.commanderDamage.commanders[fromPlayerId].damage_dealt;
      if (currentDamage + amount < 0) {
        amount = -currentDamage;
      }
      
      if (amount == 0) return;

      bool wasAlive = player.alive;
      player.commanderDamage.commanders[fromPlayerId].damage_dealt += amount;
      player.decreaseLife(amount);
      game.checkState(player, wasAlive);
    });
  }

  void adjustTime(Player player, double amount) {
    setState(() {
      double step = amount.abs();
      if (amount > 0) {
        player.timer.curTime = ((player.timer.curTime / step).floor() * step) + step;
      } else if (amount < 0) {
        player.timer.curTime = ((player.timer.curTime / step).ceil() * step) - step;
      }
      
      if (player.timer.curTime < 0) player.timer.curTime = 0;
      
      bool wasAlive = player.alive;
      player.alive = player.checkAlive();
      game.checkState(player, wasAlive);
    });
  }

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameLayout(
        players: game.players,
        onTimerTap: handleTimerToggle,
        onLifeAdjust: adjustLife,
        onTimeAdjust: adjustTime,
        onCommanderDamageAdjust: adjustCommanderDamage,
        onTimerLongPress: handlePause,
        onPause: handlePause,
        onReset: handleReset,
        onSettings: openSettings,
        onToggleMenu: toggleMenu,
        showMenu: showMenu,
      ),
    );
  }
}
