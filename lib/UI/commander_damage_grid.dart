import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';

class CommanderDamageGrid extends StatefulWidget {
  final Player player;
  final void Function(int, int, int) onCommanderDamageAdjust;
  final int rotations;
  final bool isVisible;

  const CommanderDamageGrid({
    super.key,
    required this.player,
    required this.onCommanderDamageAdjust,
    required this.rotations,
    required this.isVisible,
  });

  @override
  State<CommanderDamageGrid> createState() => _CommanderDamageGridState();
}

class _CommanderDamageGridState extends State<CommanderDamageGrid> {
  int? _editingCommanderId;
  int? _editingCommanderIndex;

  @override
  void didUpdateWidget(covariant CommanderDamageGrid oldWidget) {
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
    bool me = targetPlayerId == widget.player.order;
    bool hasPartner = Settings.hasPartner[targetPlayerId];

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Settings.playerColors[targetPlayerId],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: me ? Colors.black : Colors.black12),
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
