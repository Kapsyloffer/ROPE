import 'package:flutter/material.dart';

import '../models/player.dart';
import 'player_widget.dart';

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
        onCounterAdjust: (counterType, amt) =>
            onCounterAdjust(player, counterType, amt),
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
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
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
              children: [_buildPlayerWidget(0, 1), _buildPlayerWidget(1, 3)],
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
