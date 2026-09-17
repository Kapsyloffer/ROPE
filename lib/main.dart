import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/game.dart';
import 'models/player.dart';
import 'models/settings.dart';
import 'models/counters.dart';
import 'UI/game_layout.dart';
import 'screens/settings_screen.dart';

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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Game _game;
  bool _showMenu = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    List<Player> initialPlayers = [];
    for (int i = 0; i < Settings.players; i++) {
      Player newPlayer = Player(i);
      newPlayer.timer.onTick = () {
        if (mounted) {
          setState(() {
            bool wasAlive = newPlayer.alive;
            newPlayer.alive = newPlayer.checkAlive();
            _game.checkState(newPlayer, wasAlive);
          });
        }
      };
      newPlayer.timer.onBurn = () {
        if (mounted) {
          setState(() {
            bool wasAlive = newPlayer.alive;
            newPlayer.decreaseLife(Settings.burnAmount);
            newPlayer.isBurnFlashing = true;
            _game.checkState(newPlayer, wasAlive);
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                newPlayer.isBurnFlashing = false;
              });
            }
          });
        }
      };
      initialPlayers.add(newPlayer);
    }
    _game = Game(initialPlayers, Settings.players, 0);
  }

  void _handleTimerToggle(Player player) {
    if (!player.alive) return;
    setState(() {
      bool isPaused = !_game.players.any((p) => p.timer.active);

      if (isPaused) {
        _game.resume(player);
      } else if (player.timer.active) {
        bool isInterrupt = _game.turnStack.isNotEmpty;
        player.timer.toggleTimer(isInterrupt: isInterrupt);
        if (!player.timer.active) {
          _game.nextPlayer();
        }
      } else {
        _game.interruptTurn(player);
      }
    });
  }

  void _handlePause() {
    setState(() {
      _game.pause();
    });
  }

  void _handleReset() {
    setState(() {
      _initGame();
      _showMenu = false;
    });
  }

  void _openSettings() async {
    _game.pause();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );

    setState(() {
      _showMenu = false;
      if (_game.players.length != Settings.players) {
        _initGame();
      }
    });
  }

  void _adjustLife(Player player, int amount) {
    setState(() {
      bool wasAlive = player.alive;
      if (amount > 0) {
        player.addLife(amount);
      } else {
        player.decreaseLife(amount.abs());
      }
      _game.checkState(player, wasAlive);
    });
  }

  void _adjustCommanderDamage(
    Player player,
    int fromPlayerId,
    int commanderIndex,
    int amount,
  ) {
    setState(() {
      int currentDamage = player
          .commanderDamage
          .commanders[fromPlayerId]
          .damageDealt[commanderIndex];

      if (currentDamage + amount < 0) {
        amount = -currentDamage;
      }

      if (amount == 0) return;

      bool wasAlive = player.alive;
      player
              .commanderDamage
              .commanders[fromPlayerId]
              .damageDealt[commanderIndex] +=
          amount;
      player.decreaseLife(amount);
      _game.checkState(player, wasAlive);
    });
  }

  void _adjustCounter(Player player, String counterType, int amount) {
    setState(() {
      bool wasAlive = player.alive;

      if (counterType == 'monarch') {
        if (player.counters.activeCounters['monarch'] is ToggleCounter) {
          ToggleCounter monarchCounter =
              player.counters.activeCounters['monarch'] as ToggleCounter;
          bool newState = !monarchCounter.enabled;

          if (newState) {
            for (var p in _game.players) {
              if (p.counters.activeCounters['monarch'] is ToggleCounter) {
                (p.counters.activeCounters['monarch'] as ToggleCounter)
                        .enabled =
                    false;
              }
            }
          }
          monarchCounter.enabled = newState;
        }
      } else if (player.counters.activeCounters.containsKey(counterType)) {
        player.counters.activeCounters[counterType]!.amount += amount;
        if (player.counters.activeCounters[counterType]!.amount < 0) {
          player.counters.activeCounters[counterType]!.amount = 0;
        }
      }

      player.alive = player.checkAlive();
      _game.checkState(player, wasAlive);
    });
  }

  void _adjustTime(Player player, double amount) {
    setState(() {
      double step = amount.abs();
      if (amount > 0) {
        player.timer.curTime =
            ((player.timer.curTime / step).floor() * step) + step;
      } else if (amount < 0) {
        player.timer.curTime =
            ((player.timer.curTime / step).ceil() * step) - step;
      }

      if (player.timer.curTime < 0) player.timer.curTime = 0;

      bool wasAlive = player.alive;
      player.alive = player.checkAlive();
      _game.checkState(player, wasAlive);
    });
  }

  void _toggleMenu() {
    setState(() {
      _showMenu = !_showMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameLayout(
        players: _game.players,
        onTimerTap: _handleTimerToggle,
        onLifeAdjust: _adjustLife,
        onTimeAdjust: _adjustTime,
        onCommanderDamageAdjust: _adjustCommanderDamage,
        onCounterAdjust: _adjustCounter,
        onTimerLongPress: _handlePause,
        onPause: _handlePause,
        onReset: _handleReset,
        onSettings: _openSettings,
        onToggleMenu: _toggleMenu,
        showMenu: _showMenu,
      ),
    );
  }
}
