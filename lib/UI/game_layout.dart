import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/player.dart';
import 'player_widget.dart';

class MenuRow extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onRoll;
  final VoidCallback onSettings;
  final bool showMenu;

  const MenuRow({
    super.key,
    required this.onPause,
    required this.onReset,
    required this.onRoll,
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
              const Expanded(child: SizedBox()), //Behind toggle menu button
              Expanded(
                child: InkWell(
                  onTap: onRoll,
                  child: const Icon(
                    Icons.casino_outlined,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
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

class GameLayout extends StatefulWidget {
  final List<Player> players;
  final void Function(Player) onTimerTap;
  final void Function(Player, int) onLifeAdjust;
  final void Function(Player, double) onTimeAdjust;
  final void Function(Player, int, int, int) onCommanderDamageAdjust;
  final void Function(Player, String, int) onCounterAdjust;
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
    required this.onCounterAdjust,
    required this.onTimerLongPress,
    required this.onPause,
    required this.onReset,
    required this.onSettings,
    required this.onToggleMenu,
    required this.showMenu,
  });

  @override
  State<GameLayout> createState() => _GameLayoutState();
}

class _GameLayoutState extends State<GameLayout> {
  int _resetTrigger = 0;
  int _highlightedIndex = -1;
  async.Timer? _rollTimer;

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  void _handleReset() {
    setState(() {
      _resetTrigger++;
    });
    widget.onReset();
  }

  void _handleRoll() {
    if (_rollTimer?.isActive ?? false) return;

    int totalPlayers = widget.players.length;
    if (totalPlayers == 0) return;

    int currentStep = 0;
    int maxSteps = 10 + math.Random().nextInt(totalPlayers * 3);
    int delay = 5;

    void nextStep() {
      if (!mounted) return;
      setState(() {
        _highlightedIndex = currentStep % totalPlayers;
      });

      currentStep++;

      if (currentStep >= maxSteps) {
        _rollTimer = async.Timer(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _highlightedIndex = -1;
            });
          }
        });
      } else {
        delay = delay + (currentStep * 2).toInt();
        _rollTimer = async.Timer(Duration(milliseconds: delay), nextStep);
      }
    }

    nextStep();
  }

  Widget _buildPlayerWidget(int index, int rotations) {
    final player = widget.players[index];

    return Expanded(
      child: PlayerWidget(
        key: ValueKey(player.order),
        player: player,
        onTimerTap: () => widget.onTimerTap(player),
        onLifeAdjust: (amt) => widget.onLifeAdjust(player, amt),
        onTimeAdjust: (amt) => widget.onTimeAdjust(player, amt),
        onCommanderDamageAdjust: (targetId, commanderIndex, amt) => widget
            .onCommanderDamageAdjust(player, targetId, commanderIndex, amt),
        onCounterAdjust: (counterType, amt) =>
            widget.onCounterAdjust(player, counterType, amt),
        onTimerLongPress: widget.onTimerLongPress,
        rotations: rotations,
        resetTrigger: _resetTrigger,
        isHighlighted: _highlightedIndex == index,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layoutColumn;

    if (widget.players.length == 2) {
      layoutColumn = Column(
        children: [
          _buildPlayerWidget(0, 2),
          MenuRow(
            onPause: widget.onPause,
            onReset: _handleReset,
            onRoll: _handleRoll,
            onSettings: widget.onSettings,
            showMenu: widget.showMenu,
          ),
          _buildPlayerWidget(1, 0),
        ],
      );
    } else if (widget.players.length == 3) {
      layoutColumn = Column(
        children: [
          Expanded(
            child: Row(
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
            ),
          ),
          MenuRow(
            onPause: widget.onPause,
            onReset: _handleReset,
            onRoll: _handleRoll,
            onSettings: widget.onSettings,
            showMenu: widget.showMenu,
          ),
          _buildPlayerWidget(2, 0),
        ],
      );
    } else if (widget.players.length == 4) {
      layoutColumn = Column(
        children: [
          Expanded(
            child: Row(
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
            ),
          ),
          MenuRow(
            onPause: widget.onPause,
            onReset: _handleReset,
            onRoll: _handleRoll,
            onSettings: widget.onSettings,
            showMenu: widget.showMenu,
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
          widget.players.length,
          (index) => _buildPlayerWidget(index, 0),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        layoutColumn,
        GestureDetector(
          onTap: widget.onToggleMenu,
          child: AnimatedRotation(
            turns: widget.showMenu ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Container(
              width: 64,
              height: 64,
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
