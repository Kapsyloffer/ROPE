import 'dart:async' as async;
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/player.dart';
import 'player_widget.dart';
import 'player_layout.dart';

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
  final VoidCallback onPriorityCheck;
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
    required this.onPriorityCheck,
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
  final ValueNotifier<int> _highlightedNotifier = ValueNotifier<int>(-1);
  async.Timer? _rollTimer;

  // This link bridges the position of the MenuRow to the floating button
  final LayerLink _menuLink = LayerLink();

  @override
  void dispose() {
    _rollTimer?.cancel();
    _highlightedNotifier.dispose();
    super.dispose();
  }

  void _handleReset() {
    _rollTimer?.cancel();
    setState(() {
      _resetTrigger++;
    });
    _highlightedNotifier.value = -1;
    widget.onReset();
  }

  void _handleRoll() {
    if (_rollTimer?.isActive ?? false) return;

    if (widget.showMenu) {
      widget.onToggleMenu();
    }

    int totalPlayers = widget.players.length;
    if (totalPlayers == 0) return;

    int currentStep = 0;
    int maxSteps = 10 + math.Random().nextInt(totalPlayers * 3);
    int delay = 5;

    void nextStep() {
      if (!mounted) return;
      _highlightedNotifier.value = currentStep % totalPlayers;

      currentStep++;

      if (currentStep >= maxSteps) {
        _rollTimer = async.Timer(const Duration(seconds: 2), () {
          if (mounted) {
            _highlightedNotifier.value = -1;
          }
        });
      } else {
        delay = delay + (currentStep * 2).toInt();
        _rollTimer = async.Timer(Duration(milliseconds: delay), nextStep);
      }
    }

    nextStep();
  }

  Widget _buildPlayerWidget(int index, int maxQueue) {
    final player = widget.players[index];
    final bool isNextInQueue =
        player.queuePosition > 0 && player.queuePosition == maxQueue;
    final int rotations = PlayerLayout.getRotation(
      widget.players.length,
      index,
    );

    return PlayerWidget(
      key: ValueKey(player.order),
      player: player,
      onTimerTap: () => widget.onTimerTap(player),
      onLifeAdjust: (amt) => widget.onLifeAdjust(player, amt),
      onTimeAdjust: (amt) => widget.onTimeAdjust(player, amt),
      onCommanderDamageAdjust: (targetId, commanderIndex, amt) =>
          widget.onCommanderDamageAdjust(player, targetId, commanderIndex, amt),
      onCounterAdjust: (counterType, amt) =>
          widget.onCounterAdjust(player, counterType, amt),
      onTimerLongPress: widget.onTimerLongPress,
      onPriorityCheck: widget.onPriorityCheck,
      rotations: rotations,
      resetTrigger: _resetTrigger,
      highlightedNotifier: _highlightedNotifier,
      isNextInQueue: isNextInQueue,
    );
  }

  @override
  Widget build(BuildContext context) {
    int maxQueue = widget.players.fold(
      0,
      (max, p) => p.queuePosition > max ? p.queuePosition : max,
    );

    // Target marks exactly where the MenuRow is dynamically placed in the flex layout
    Widget centerMenuWidget = CompositedTransformTarget(
      link: _menuLink,
      child: MenuRow(
        onPause: widget.onPause,
        onReset: _handleReset,
        onRoll: _handleRoll,
        onSettings: widget.onSettings,
        showMenu: widget.showMenu,
      ),
    );

    Widget layoutColumn = PlayerLayout.build(
      playerCount: widget.players.length,
      builder: (index) => _buildPlayerWidget(index, maxQueue),
      centerMenu: centerMenuWidget,
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        layoutColumn,
        // The follower completely floats over everything but dynamically anchors to the Target
        Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _menuLink,
            showWhenUnlinked: false,
            targetAnchor: Alignment.center,
            followerAnchor: Alignment.center,
            child: SizedBox(
              width: 64,
              height: 64,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
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
                    child: const Icon(
                      Icons.hourglass_empty,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
