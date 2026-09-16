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
  final void Function(int) onLifeAdjust;
  final void Function(double) onTimeAdjust;
  final void Function(int, int) onCommanderDamageAdjust;
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
  async.Timer? delayTimer;
  async.Timer? timeIncrementTimer;
  Alignment timeIncAlignment = const Alignment(0.0, -0.8);
  double timeIncOpacity = 0.0;
  double lastTime = 0.0;

  bool isEditingTimer = false;
  bool showCommanderDamage = false;
  int? editingCommanderId;
  double _dragDistance = 0.0;

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
    
    delayTimer?.cancel();
    delayTimer = async.Timer(const Duration(milliseconds: 50), () {
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

  Widget _buildAdjustButton(IconData icon, int amount, Color buttonColor) {
    return Expanded(
      child: Material(
        color: buttonColor,
        child: InkWell(
          onTap: () {
            if (!isHolding) handleLifeAdjust(amount);
          },
          onTapDown: (_) => handleTapDown(amount),
          onTapUp: (_) => handleTapUp(),
          onTapCancel: handleTapCancel,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, size: 48, color: widget.player.alive ? Colors.black : Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommanderAdjustButton(int targetPlayerId, IconData icon, int amount) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCommanderDamageAdjust(targetPlayerId, amount),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, size: 32, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimerAdjustButton(IconData icon, double amount) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onTimeAdjust(amount),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, size: 48, color: widget.player.alive ? Colors.black : Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommanderCell(int targetPlayerId) {
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
                    _buildCommanderAdjustButton(targetPlayerId, Icons.remove, -1),
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
                    _buildCommanderAdjustButton(targetPlayerId, Icons.add, 1),
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

  Widget _buildCommanderRow(int id1, int id2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _buildCommanderCell(id1)),
        Expanded(child: _buildCommanderCell(id2)),
      ],
    );
  }

  Widget _buildCommanderGrid() {
    if (Settings.players == 2) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(child: _buildCommanderCell(0)),
           Expanded(child: _buildCommanderCell(1)),
         ],
       );
    } else if (Settings.players == 3) {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(child: _buildCommanderRow(0, 1)),
           Expanded(child: _buildCommanderCell(2)),
         ],
       );
    } else {
       return Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
           Expanded(child: _buildCommanderRow(0, 1)),
           Expanded(child: _buildCommanderRow(3, 2)),
         ],
       );
    }
  }

  @override
  void dispose() {
    lifeDeltaTimer?.cancel();
    timeIncrementTimer?.cancel();
    delayTimer?.cancel();
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
        onVerticalDragStart: (_) => _dragDistance = 0.0,
        onVerticalDragUpdate: (details) => _dragDistance += details.primaryDelta ?? 0.0,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0.0;
          if (velocity < -100 || _dragDistance < -40) {
            setState(() {
              showCommanderDamage = true;
            });
          } else if (velocity > 100 || _dragDistance > 40) {
            setState(() {
              showCommanderDamage = false;
              editingCommanderId = null;
            });
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
                                _buildAdjustButton(Icons.remove, -1, buttonColor),
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
                                _buildAdjustButton(Icons.add, 1, buttonColor),
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
                                child: _buildCommanderGrid(),
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
                            _buildTimerAdjustButton(Icons.remove, -15.0),
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
                            _buildTimerAdjustButton(Icons.add, 15.0),
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
  final bool showMenu;

  const MenuRow({
    super.key,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: showMenu ? 48.0 : 0.0,
      child: ClipRect(
        child: Material(
          color: Colors.black87,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: InkWell(
                  onTap: onReset,
                  child: const Icon(Icons.refresh, color: Colors.white, size: 32),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onPause,
                  child: const Icon(Icons.stop, color: Colors.white, size: 32),
                ),
              ),
              const Expanded(
                child: SizedBox(),
              ),
              Expanded(
                child: InkWell(
                  onTap: onSettings,
                  child: const Icon(Icons.settings, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameLayout extends StatelessWidget {
  final List<Player> players;
  final void Function(Player) onTimerTap;
  final void Function(Player, int) onLifeAdjust;
  final void Function(Player, double) onTimeAdjust;
  final void Function(Player, int, int) onCommanderDamageAdjust;
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

  Widget _buildPlayerWidget(int index, int rotations) {
    final player = players[index];

    return Expanded(
      child: PlayerWidget(
        key: ObjectKey(player),
        player: player,
        onTimerTap: () => onTimerTap(player),
        onLifeAdjust: (amt) => onLifeAdjust(player, amt),
        onTimeAdjust: (amt) => onTimeAdjust(player, amt),
        onCommanderDamageAdjust: (targetId, amt) => onCommanderDamageAdjust(player, targetId, amt),
        onTimerLongPress: onTimerLongPress,
        rotations: rotations,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layoutColumn;
    
    if (players.length == 2) {
      layoutColumn = Column(
        children: [
          _buildPlayerWidget(0, 2),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
            showMenu: showMenu,
          ),
          _buildPlayerWidget(1, 0),
        ],
      );
    } else if (players.length == 3) {
      layoutColumn = Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildPlayerWidget(0, 1),
                _buildPlayerWidget(1, 3),
              ],
            ),
          ),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
            showMenu: showMenu,
          ),
          _buildPlayerWidget(2, 0),
        ],
      );
    } else if (players.length == 4) {
      layoutColumn = Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildPlayerWidget(0, 1),
                _buildPlayerWidget(1, 3),
              ],
            ),
          ),
          MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
            showMenu: showMenu,
          ),
          Expanded(
            child: Row(
              children: [
                _buildPlayerWidget(3, 1),
                _buildPlayerWidget(2, 3),
              ],
            ),
          ),
        ],
      );
    } else {
      layoutColumn = Column(
        children: List.generate(players.length, (index) => _buildPlayerWidget(index, 0)),
      );
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        layoutColumn,
        GestureDetector(
          onTap: onToggleMenu,
          child: AnimatedRotation(
            turns: showMenu ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.hourglass_empty, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
