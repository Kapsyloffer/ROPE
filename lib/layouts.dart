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
  final Function(double) onTimeAdjust;
  final Function(int, int) onCommanderDamageAdjust;
  final VoidCallback onTimerLongPress;
  final int rotations;

  const PlayerWidget({
    super.key,
    required this.player,
    required this.onTimerTap,
    required this.onLifeAdjust,
    required this.onTimeAdjust,
    required this.onCommanderDamageAdjust,
    required this.onTimerLongPress,
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

  bool isEditingTimer = false;
  bool showCommanderDamage = false;
  int? editingCommanderId;

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

  Widget buildCommanderCell(int targetPlayerId) {
    if (targetPlayerId == widget.player.order) {
      return const SizedBox.shrink();
    }
    
    bool isEditing = editingCommanderId == targetPlayerId;

    return GestureDetector(
      onTap: () {
        if (isEditing) {
          setState(() {
            editingCommanderId = null;
          });
        } else {
          widget.onCommanderDamageAdjust(targetPlayerId, 1);
        }
      },
      onLongPress: () {
        setState(() {
          editingCommanderId = targetPlayerId;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Settings.playerColors[targetPlayerId].withOpacity(0.8),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black12),
        ),
        child: RotatedBox(
          quarterTurns: widget.rotations,
          child: isEditing
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onCommanderDamageAdjust(targetPlayerId, -1),
                          child: const Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(Icons.remove, size: 32, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${widget.player.commanderDamage.commanders[targetPlayerId].damage_dealt}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onCommanderDamageAdjust(targetPlayerId, 1),
                          child: const Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Icon(Icons.add, size: 32, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${widget.player.commanderDamage.commanders[targetPlayerId].damage_dealt}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget buildCommanderGrid() {
    if (Settings.players == 2) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(child: buildCommanderCell(0)),
           Expanded(child: buildCommanderCell(1)),
         ]
       );
    } else if (Settings.players == 3) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Expanded(child: buildCommanderCell(0)),
                 Expanded(child: buildCommanderCell(1)),
               ]
             )
           ),
           Expanded(child: buildCommanderCell(2)),
         ]
       );
    } else {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Expanded(child: buildCommanderCell(0)),
                 Expanded(child: buildCommanderCell(1)),
               ]
             )
           ),
           Expanded(
             child: Row(
               crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                 Expanded(child: buildCommanderCell(3)),
                 Expanded(child: buildCommanderCell(2)),
               ]
             )
           ),
         ]
       );
    }
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
    Color buttonColor = widget.player.alive ? Settings.playerColors[widget.player.order] : Colors.grey.shade800;

    Widget content = Container(
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: widget.player.alive 
            ? Settings.playerColors[widget.player.order]
            : Colors.grey.shade800,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! < 0) {
              setState(() {
                showCommanderDamage = true;
              });
            } else if (details.primaryVelocity! > 0) {
              setState(() {
                showCommanderDamage = false;
                editingCommanderId = null;
              });
            }
          }
        },
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedSlide(
                        offset: showCommanderDamage ? const Offset(0.0, -1.0) : Offset.zero,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: showCommanderDamage ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: showCommanderDamage,
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
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedSlide(
                        offset: showCommanderDamage ? Offset.zero : const Offset(0.0, 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: showCommanderDamage ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !showCommanderDamage,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: RotatedBox(
                                quarterTurns: widget.rotations == 0 ? 0 : 4 - widget.rotations,
                                child: buildCommanderGrid(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (Settings.useTimer)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    if (isEditingTimer) {
                      setState(() {
                        isEditingTimer = false;
                      });
                    } else {
                      widget.onTimerTap();
                    }
                  },
                  onLongPress: () {
                    setState(() {
                      isEditingTimer = true;
                    });
                    widget.onTimerLongPress();
                  },
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
                        if (isEditingTimer)
                          Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => widget.onTimeAdjust(-15.0),
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
                              child: Center(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    formatTime(widget.player.timer.curTime),
                                    style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: widget.player.alive ? Colors.black : Colors.red),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => widget.onTimeAdjust(15.0),
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
                        )
                        else
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
                        if (showTimeIncrement && !isEditingTimer)
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
  final Function(Player, double) onTimeAdjust;
  final Function(Player, int, int) onCommanderDamageAdjust;
  final VoidCallback onTimerLongPress;
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
    required this.onTimeAdjust,
    required this.onCommanderDamageAdjust,
    required this.onTimerLongPress,
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
              onTimeAdjust: (amt) => onTimeAdjust(players[0], amt),
              onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[0], targetId, amt),
              onTimerLongPress: onTimerLongPress,
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
              onTimeAdjust: (amt) => onTimeAdjust(players[1], amt),
              onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[1], targetId, amt),
              onTimerLongPress: onTimerLongPress,
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
                    onTimeAdjust: (amt) => onTimeAdjust(players[0], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[0], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[1], 
                    onTimerTap: () => onTimerTap(players[1]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[1], amt), 
                    onTimeAdjust: (amt) => onTimeAdjust(players[1], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[1], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
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
              onTimeAdjust: (amt) => onTimeAdjust(players[2], amt),
              onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[2], targetId, amt),
              onTimerLongPress: onTimerLongPress,
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
                    onTimeAdjust: (amt) => onTimeAdjust(players[0], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[0], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[1], 
                    onTimerTap: () => onTimerTap(players[1]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[1], amt), 
                    onTimeAdjust: (amt) => onTimeAdjust(players[1], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[1], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
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
                    onTimeAdjust: (amt) => onTimeAdjust(players[3], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[3], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
                    rotations: 1,
                  ),
                ),
                Expanded(
                  child: PlayerWidget(
                    player: players[2], 
                    onTimerTap: () => onTimerTap(players[2]), 
                    onLifeAdjust: (amt) => onLifeAdjust(players[2], amt), 
                    onTimeAdjust: (amt) => onTimeAdjust(players[2], amt),
                    onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(players[2], targetId, amt),
                    onTimerLongPress: onTimerLongPress,
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
            onTimeAdjust: (amt) => onTimeAdjust(p, amt),
            onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(p, targetId, amt),
            onTimerLongPress: onTimerLongPress,
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
