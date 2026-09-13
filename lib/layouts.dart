import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'player.dart';
import 'settings.dart';

String formatTime(double seconds) {
  int min = seconds ~/ 60;
  int sec = (seconds % 60).toInt();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

class PlayerWidget extends StatefulWidget {
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
  State<PlayerWidget> createState() => PlayerWidgetState();
}

class PlayerWidgetState extends State<PlayerWidget> {
  int lifeDelta = 0;
  bool showLifeDelta = false;
  async.Timer? lifeDeltaTimer;
  double lifeDeltaOpacity = 0.0;

  async.Timer? initialHoldTimer;
  async.Timer? periodicHoldTimer;
  bool isHolding = false;

  bool showTimeIncrement = false;
  async.Timer? timeIncrementTimer;
  Alignment timeIncAlignment = const Alignment(0.0, -0.8);
  double timeIncOpacity = 0.0;
  double lastTime = 0.0;

  @override
  void initState() {
    super.initState();
    lastTime = widget.player.timer.curTime;
  }

  @override
  void didUpdateWidget(covariant PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.player.timer.curTime > lastTime && !widget.player.timer.active && Settings.useTimer && Settings.increment > 0) {
      triggerTimeIncrement();
    }
    lastTime = widget.player.timer.curTime;
  }

  void triggerTimeIncrement() {
    setState(() {
      showTimeIncrement = true;
      timeIncAlignment = const Alignment(0.0, -0.8);
      timeIncOpacity = 1.0;
    });
    
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          timeIncAlignment = const Alignment(0.0, -2.0);
          timeIncOpacity = 0.0;
        });
      }
    });

    timeIncrementTimer?.cancel();
    timeIncrementTimer = async.Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          showTimeIncrement = false;
        });
      }
    });
  }

  void handleLifeAdjust(int amount) {
    widget.onLifeAdjust(amount);
    setState(() {
      showLifeDelta = true;
      lifeDelta += amount;
      lifeDeltaOpacity = 1.0;
    });
    
    lifeDeltaTimer?.cancel();
    lifeDeltaTimer = async.Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          lifeDeltaOpacity = 0.0;
        });
        
        async.Timer(const Duration(milliseconds: 300), () {
          if (mounted && lifeDeltaOpacity == 0.0) {
            setState(() {
              showLifeDelta = false;
              lifeDelta = 0;
            });
          }
        });
      }
    });
  }

  void handleTapDown(int amount) {
    isHolding = false;
    initialHoldTimer?.cancel();
    periodicHoldTimer?.cancel();
    
    initialHoldTimer = async.Timer(const Duration(milliseconds: 500), () {
      isHolding = true;
      handleLifeAdjust(amount * 10);
      periodicHoldTimer = async.Timer.periodic(const Duration(milliseconds: 500), (t) {
        handleLifeAdjust(amount * 10);
      });
    });
  }

  void handleTapUp() {
    initialHoldTimer?.cancel();
    periodicHoldTimer?.cancel();
  }

  void handleTapCancel() {
    initialHoldTimer?.cancel();
    periodicHoldTimer?.cancel();
    isHolding = false;
  }

  @override
  void dispose() {
    lifeDeltaTimer?.cancel();
    timeIncrementTimer?.cancel();
    initialHoldTimer?.cancel();
    periodicHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color buttonColor = widget.player.alive ? Settings.playerColors[widget.player.order] : Colors.grey.shade900;

    Widget content = Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: widget.player.alive 
            ? Settings.playerColors[widget.player.order]
            : Colors.grey.shade800,
      ),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Material(
                    color: buttonColor,
                    child: InkWell(
                      onTap: () {
                        if (!isHolding) handleLifeAdjust(-1);
                      },
                      onTapDown: (_) => handleTapDown(-1),
                      onTapUp: (_) => handleTapUp(),
                      onTapCancel: handleTapCancel,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(Icons.remove, size: 48, color: widget.player.alive ? Colors.black : Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              Settings.playerNames[widget.player.order],
                              style: TextStyle(
                                  fontSize: 16, 
                                  fontWeight: FontWeight.bold, 
                                  color: widget.player.alive ? Colors.black54 : Colors.red.shade900
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.player.curLife}',
                              style: TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: widget.player.alive ? Colors.black : Colors.red),
                            ),
                          ),
                        ],
                      ),
                      if (showLifeDelta)
                        Positioned(
                          top: 16,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: lifeDeltaOpacity,
                            child: Text(
                              lifeDelta > 0 ? '+$lifeDelta' : '$lifeDelta',
                              style: TextStyle(
                                fontSize: 32, 
                                fontWeight: FontWeight.bold, 
                                color: widget.player.alive ? Colors.black54 : Colors.red
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Material(
                    color: buttonColor,
                    child: InkWell(
                      onTap: () {
                        if (!isHolding) handleLifeAdjust(1);
                      },
                      onTapDown: (_) => handleTapDown(1),
                      onTapUp: (_) => handleTapUp(),
                      onTapCancel: handleTapCancel,
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Icon(Icons.add, size: 48, color: widget.player.alive ? Colors.black : Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (Settings.useTimer)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: widget.onTimerTap,
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: widget.player.alive
                        ? (widget.player.timer.active ? Colors.green.shade500 : Colors.black.withOpacity(0.15))
                        : Colors.black.withOpacity(0.3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              formatTime(widget.player.timer.curTime),
                              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: widget.player.alive ? Colors.black : Colors.red),
                            ),
                          ),
                        ),
                      ),
                      if (showTimeIncrement)
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 1500),
                          curve: Curves.easeOut,
                          alignment: timeIncAlignment,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 1500),
                            curve: Curves.easeInQuint,
                            opacity: timeIncOpacity,
                            child: Text(
                              '+${formatTime(Settings.increment.toDouble())}',
                              style: TextStyle(
                                fontSize: 28, 
                                fontWeight: FontWeight.bold, 
                                color: widget.player.alive ? Colors.black54 : Colors.red
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    if (widget.rotations > 0) {
      return RotatedBox(quarterTurns: widget.rotations, child: content);
    }
    return content;
  }
}

class MenuRow extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;
  final VoidCallback onToggleMenu;

  const MenuRow({
    super.key,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
    required this.onToggleMenu,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black87,
      child: SizedBox(
        height: 48.0,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: onPause,
                child: const Icon(Icons.stop, color: Colors.white, size: 32),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onReset,
                child: const Icon(Icons.refresh, color: Colors.white, size: 32),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onSettings,
                child: const Icon(Icons.settings, color: Colors.white, size: 32),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: onToggleMenu,
                child: const Icon(Icons.keyboard_arrow_up, color: Colors.white, size: 32),
              ),
            ),
          ],
        ),
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
  final VoidCallback onToggleMenu;
  final bool showMenu;

  const GameLayout({
    super.key,
    required this.players,
    required this.onTimerTap,
    required this.onLifeAdjust,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
    required this.onToggleMenu,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context) {
    Widget layoutColumn;
    
    if (players.length == 2) {
      layoutColumn = Column(
        children: [
          Expanded(
            child: PlayerWidget(
              player: players[0], 
              onTimerTap: () => onTimerTap(players[0]), 
              onLifeAdjust: (amt) => onLifeAdjust(players[0], amt), 
              rotations: 2,
            ),
          ),
          if (showMenu)
            MenuRow(
              onPause: onPause,
              onReset: onReset,
              onSettings: onSettings,
              onToggleMenu: onToggleMenu,
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
      layoutColumn = Column(
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
          if (showMenu)
            MenuRow(
              onPause: onPause,
              onReset: onReset,
              onSettings: onSettings,
              onToggleMenu: onToggleMenu,
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
      layoutColumn = Column(
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
          if (showMenu)
            MenuRow(
              onPause: onPause,
              onReset: onReset,
              onSettings: onSettings,
              onToggleMenu: onToggleMenu,
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
    } else {
      layoutColumn = Column(
        children: players.map((p) => Expanded(
          child: PlayerWidget(
            player: p, 
            onTimerTap: () => onTimerTap(p), 
            onLifeAdjust: (amt) => onLifeAdjust(p, amt),
          ),
        )).toList(),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        layoutColumn,
        if (!showMenu)
          FloatingActionButton(
            mini: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            onPressed: onToggleMenu,
            child: const Icon(Icons.menu, color: Colors.white),
          ),
      ],
    );
  }
}
