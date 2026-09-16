import 'dart:async' as async;

import 'package:flutter/material.dart';

import 'player.dart';
import 'settings.dart';

String _formatTime(double seconds) {
  int min = seconds ~/ 60;
  int sec = (seconds % 60).toInt();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

class _LifeDisplay extends StatefulWidget {
  final Player player;
  final void Function(int) onLifeAdjust;

  const _LifeDisplay({
    super.key,
    required this.player,
    required this.onLifeAdjust,
  });

  @override
  State<_LifeDisplay> createState() => _LifeDisplayState();
}

class _LifeDisplayState extends State<_LifeDisplay> {
  int _lifeDelta = 0;
  bool _showLifeDelta = false;
  async.Timer? _lifeDeltaTimer;
  double _lifeDeltaOpacity = 0.0;

  async.Timer? _initialHoldTimer;
  async.Timer? _periodicHoldTimer;
  bool _isHolding = false;

  @override
  void didUpdateWidget(covariant _LifeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.player != widget.player) {
      _lifeDeltaTimer?.cancel();
      _initialHoldTimer?.cancel();
      _periodicHoldTimer?.cancel();

      _lifeDelta = 0;
      _lifeDeltaOpacity = 0.0;
      _showLifeDelta = false;
      _isHolding = false;
    }
  }

  void _handleLifeAdjust(int amount) {
    widget.onLifeAdjust(amount);
    setState(() {
      _showLifeDelta = true;
      _lifeDelta += amount;
      _lifeDeltaOpacity = 1.0;
    });

    _lifeDeltaTimer?.cancel();
    _lifeDeltaTimer = async.Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _lifeDeltaOpacity = 0.0;
        });

        async.Timer(const Duration(milliseconds: 300), () {
          if (mounted && _lifeDeltaOpacity == 0.0) {
            setState(() {
              _showLifeDelta = false;
              _lifeDelta = 0;
            });
          }
        });
      }
    });
  }

  void _handleTapDown(int amount) {
    _isHolding = false;
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();

    _initialHoldTimer = async.Timer(const Duration(milliseconds: 500), () {
      _isHolding = true;
      _handleLifeAdjust(amount * 10);
      _periodicHoldTimer = async.Timer.periodic(
        const Duration(milliseconds: 500),
        (t) {
          _handleLifeAdjust(amount * 10);
        },
      );
    });
  }

  void _handleTapUp() {
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();
  }

  void _handleTapCancel() {
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();
    _isHolding = false;
  }

  Widget _buildAdjustButton(IconData icon, int amount, Color buttonColor) {
    return Expanded(
      child: Material(
        color: buttonColor,
        child: InkWell(
          onTap: () {
            if (!_isHolding) _handleLifeAdjust(amount);
          },
          onTapDown: (_) => _handleTapDown(amount),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                size: 48,
                color: widget.player.alive ? Colors.black : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _lifeDeltaTimer?.cancel();
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.player.alive
        ? Settings.playerColors[widget.player.order]
        : Colors.grey.shade800;

    return Row(
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
                        color: widget.player.alive
                            ? Colors.black54
                            : Colors.red.shade900,
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${widget.player.curLife}',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: widget.player.alive ? Colors.black : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
              if (_showLifeDelta)
                Positioned(
                  top: 16,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _lifeDeltaOpacity,
                    child: Text(
                      _lifeDelta > 0 ? '+$_lifeDelta' : '$_lifeDelta',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: widget.player.alive
                            ? Colors.black54
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        _buildAdjustButton(Icons.add, 1, buttonColor),
      ],
    );
  }
}

class _CommanderDamageGrid extends StatefulWidget {
  final Player player;
  final void Function(int, int, int) onCommanderDamageAdjust;
  final int rotations;
  final bool isVisible;

  const _CommanderDamageGrid({
    super.key,
    required this.player,
    required this.onCommanderDamageAdjust,
    required this.rotations,
    required this.isVisible,
  });

  @override
  State<_CommanderDamageGrid> createState() => _CommanderDamageGridState();
}

class _CommanderDamageGridState extends State<_CommanderDamageGrid> {
  int? _editingCommanderId;
  int? _editingCommanderIndex;

  @override
  void didUpdateWidget(covariant _CommanderDamageGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isVisible && !widget.isVisible) ||
        oldWidget.player != widget.player) {
      _editingCommanderId = null;
      _editingCommanderIndex = null;
    }
  }

  Widget _buildCommanderAdjustButton(
    int targetPlayerId,
    int commanderIndex,
    IconData icon,
    int amount,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCommanderDamageAdjust(
            targetPlayerId,
            commanderIndex,
            amount,
          ),
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

  Widget _buildDamageDisplay(
    int targetPlayerId,
    int commanderIndex,
    int damage,
  ) {
    bool isEditing =
        _editingCommanderId == targetPlayerId &&
        _editingCommanderIndex == commanderIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isEditing) {
            setState(() {
              _editingCommanderId = null;
              _editingCommanderIndex = null;
            });
          } else {
            widget.onCommanderDamageAdjust(targetPlayerId, commanderIndex, 1);
          }
        },
        onLongPress: () {
          setState(() {
            _editingCommanderId = targetPlayerId;
            _editingCommanderIndex = commanderIndex;
          });
        },
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
          child: isEditing
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCommanderAdjustButton(
                      targetPlayerId,
                      commanderIndex,
                      Icons.remove,
                      -1,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$damage',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCommanderAdjustButton(
                      targetPlayerId,
                      commanderIndex,
                      Icons.add,
                      1,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$damage',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildCommanderCell(int targetPlayerId) {
    if (targetPlayerId == widget.player.order) {
      return const SizedBox.shrink();
    }

    bool hasPartner = Settings.hasPartner[targetPlayerId];

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Settings.playerColors[targetPlayerId].withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black12),
      ),
      child: RotatedBox(
        quarterTurns: widget.rotations,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDamageDisplay(
              targetPlayerId,
              0,
              widget
                  .player
                  .commanderDamage
                  .commanders[targetPlayerId]
                  .damageDealt[0],
            ),
            if (hasPartner)
              _buildDamageDisplay(
                targetPlayerId,
                1,
                widget
                    .player
                    .commanderDamage
                    .commanders[targetPlayerId]
                    .damageDealt[1],
              ),
          ],
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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: RotatedBox(
        quarterTurns: widget.rotations == 0 ? 0 : 4 - widget.rotations,
        child: _buildCommanderGrid(),
      ),
    );
  }
}

class _TimerDisplay extends StatefulWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final VoidCallback onTimerLongPress;
  final void Function(double) onTimeAdjust;

  const _TimerDisplay({
    super.key,
    required this.player,
    required this.onTimerTap,
    required this.onTimerLongPress,
    required this.onTimeAdjust,
  });

  @override
  State<_TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<_TimerDisplay>
    with SingleTickerProviderStateMixin {
  bool _showTimeIncrement = false;
  async.Timer? _delayTimer;
  async.Timer? _timeIncrementTimer;
  Alignment _timeIncAlignment = const Alignment(0.0, -0.8);
  double _timeIncOpacity = 0.0;
  double _lastTime = 0.0;
  bool _isEditingTimer = false;
  late AnimationController _ropeController;

  @override
  void initState() {
    super.initState();
    _lastTime = widget.player.timer.curTime;

    int durationSec = Settings.burnInterval > 0 ? Settings.burnInterval : 1;
    _ropeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSec),
    );

    if (Settings.useSlowBurn &&
        widget.player.timer.active &&
        widget.player.alive) {
      double startFraction = Settings.burnInterval > 0
          ? widget.player.timer.elapsedTurnTime / Settings.burnInterval
          : 0.0;
      if (startFraction < 0.0) startFraction = 0.0;
      if (startFraction > 1.0) startFraction = 1.0;
      _ropeController.value = startFraction;
      _ropeController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.player != widget.player) {
      _delayTimer?.cancel();
      _timeIncrementTimer?.cancel();

      _isEditingTimer = false;
      _showTimeIncrement = false;
      _timeIncOpacity = 0.0;
      _timeIncAlignment = const Alignment(0.0, -0.8);
    }

    if (widget.player.timer.curTime > _lastTime &&
        !widget.player.timer.active &&
        Settings.useTimer &&
        Settings.increment > 0) {
      _triggerTimeIncrement();
    }

    _handleRopeAnimation();
    _lastTime = widget.player.timer.curTime;
  }

  void _handleRopeAnimation() {
    int durationSec = Settings.burnInterval > 0 ? Settings.burnInterval : 1;
    if (_ropeController.duration?.inSeconds != durationSec) {
      _ropeController.duration = Duration(seconds: durationSec);
    }

    if (!Settings.useSlowBurn ||
        !widget.player.alive ||
        !widget.player.timer.active) {
      if (_ropeController.isAnimating || _ropeController.value != 0.0) {
        _ropeController.stop();
        _ropeController.value = 0.0;
      }
      return;
    }

    if (!_ropeController.isAnimating) {
      double currentFraction = Settings.burnInterval > 0
          ? widget.player.timer.elapsedTurnTime / Settings.burnInterval
          : 0.0;
      if (currentFraction < 0.0) currentFraction = 0.0;
      if (currentFraction > 1.0) currentFraction = 1.0;
      _ropeController.value = currentFraction;
      _ropeController.repeat();
    }
  }

  void _triggerTimeIncrement() {
    setState(() {
      _showTimeIncrement = true;
      _timeIncAlignment = const Alignment(0.0, -0.8);
      _timeIncOpacity = 1.0;
    });

    _delayTimer?.cancel();
    _delayTimer = async.Timer(const Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _timeIncAlignment = const Alignment(0.0, -2.0);
          _timeIncOpacity = 0.0;
        });
      }
    });

    _timeIncrementTimer?.cancel();
    _timeIncrementTimer = async.Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showTimeIncrement = false;
        });
      }
    });
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
              child: Icon(
                icon,
                size: 48,
                color: widget.player.alive ? Colors.black : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ropeController.dispose();
    _timeIncrementTimer?.cancel();
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_isEditingTimer) {
          setState(() {
            _isEditingTimer = false;
          });
        } else {
          widget.onTimerTap();
        }
      },
      onLongPress: () {
        setState(() {
          _isEditingTimer = true;
        });
        widget.onTimerLongPress();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: widget.player.alive
              ? (widget.player.timer.active
                    ? Colors.green.shade500
                    : Colors.black.withValues(alpha: 0.15))
              : Colors.black.withValues(alpha: 0.3),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (Settings.useSlowBurn &&
                widget.player.alive &&
                widget.player.timer.active)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return AnimatedBuilder(
                      animation: _ropeController,
                      builder: (context, child) {
                        double remaining = 1.0 - _ropeController.value;
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: constraints.maxWidth * remaining,
                            height: 8.0,
                            decoration: BoxDecoration(
                              color: Colors.green.shade900,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.green.shade800,
                                  blurRadius: 8.0,
                                  spreadRadius: 2.0,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            if (_isEditingTimer)
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
                          _formatTime(widget.player.timer.curTime),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: widget.player.alive
                                ? Colors.black
                                : Colors.red,
                          ),
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
                      _formatTime(widget.player.timer.curTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.player.alive ? Colors.black : Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            if (_showTimeIncrement && !_isEditingTimer)
              AnimatedAlign(
                duration: const Duration(milliseconds: 1500),
                curve: Curves.easeOut,
                alignment: _timeIncAlignment,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.easeInQuint,
                  opacity: _timeIncOpacity,
                  child: Text(
                    '+${_formatTime(Settings.increment.toDouble())}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.player.alive ? Colors.black54 : Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PlayerWidget extends StatefulWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final void Function(int) onLifeAdjust;
  final void Function(double) onTimeAdjust;
  final void Function(int, int, int) onCommanderDamageAdjust;
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
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  bool _showCommanderDamage = false;
  double _dragDistance = 0.0;

  @override
  Widget build(BuildContext context) {
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
        onVerticalDragUpdate: (details) =>
            _dragDistance += details.primaryDelta ?? 0.0,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0.0;
          if (velocity < -100 || _dragDistance < -40) {
            setState(() {
              _showCommanderDamage = true;
            });
          } else if (velocity > 100 || _dragDistance > 40) {
            setState(() {
              _showCommanderDamage = false;
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
                        offset: _showCommanderDamage
                            ? const Offset(0.0, -1.0)
                            : Offset.zero,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showCommanderDamage ? 0.0 : 1.0,
                          child: IgnorePointer(
                            ignoring: _showCommanderDamage,
                            child: _LifeDisplay(
                              key: ValueKey(widget.player.order),
                              player: widget.player,
                              onLifeAdjust: widget.onLifeAdjust,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedSlide(
                        offset: _showCommanderDamage
                            ? Offset.zero
                            : const Offset(0.0, 1.0),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showCommanderDamage ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: !_showCommanderDamage,
                            child: _CommanderDamageGrid(
                              key: ValueKey(widget.player.order),
                              player: widget.player,
                              onCommanderDamageAdjust:
                                  widget.onCommanderDamageAdjust,
                              rotations: widget.rotations,
                              isVisible: _showCommanderDamage,
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
                child: _TimerDisplay(
                  key: ValueKey(widget.player.order),
                  player: widget.player,
                  onTimerTap: widget.onTimerTap,
                  onTimerLongPress: widget.onTimerLongPress,
                  onTimeAdjust: widget.onTimeAdjust,
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

class _MenuRow extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onSettings;
  final bool showMenu;

  const _MenuRow({
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
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: onPause,
                  child: const Icon(Icons.stop, color: Colors.white, size: 32),
                ),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
              Expanded(
                child: InkWell(
                  onTap: onSettings,
                  child: const Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 32,
                  ),
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
  final void Function(Player, int, int, int) onCommanderDamageAdjust;
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
        key: ValueKey(player.order),
        player: player,
        onTimerTap: () => onTimerTap(player),
        onLifeAdjust: (amt) => onLifeAdjust(player, amt),
        onTimeAdjust: (amt) => onTimeAdjust(player, amt),
        onCommanderDamageAdjust: (targetId, commanderIndex, amt) =>
            onCommanderDamageAdjust(player, targetId, commanderIndex, amt),
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
          _MenuRow(
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
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
            ),
          ),
          _MenuRow(
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
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
            ),
          ),
          _MenuRow(
            onPause: onPause,
            onReset: onReset,
            onSettings: onSettings,
            showMenu: showMenu,
          ),
          Expanded(
            child: Row(
              children: [_buildPlayerWidget(3, 1), _buildPlayerWidget(2, 3)],
            ),
          ),
        ],
      );
    } else {
      layoutColumn = Column(
        children: List.generate(
          players.length,
          (index) => _buildPlayerWidget(index, 0),
        ),
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
