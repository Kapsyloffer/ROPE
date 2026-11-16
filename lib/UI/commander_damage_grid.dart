import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../models/game.dart';
import 'player_layout.dart';
import '../helpers/outlined_text.dart';

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

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImageProvider(path);
    } else {
      return FileImage(File(path));
    }
  }

  Widget _buildCommanderAdjustButton(
    int targetPlayerId,
    int commanderIndex,
    IconData icon,
    int amount,
    Color iconColor,
    List<Shadow>? textShadows,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            widget.onCommanderDamageAdjust(
              targetPlayerId,
              commanderIndex,
              amount,
            );
          },
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                size: 32,
                color: iconColor,
                shadows: textShadows,
              ),
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
    bool me,
    Color textColor,
    List<Shadow>? textShadows,
  ) {
    bool isEditing =
        _editingCommanderId == targetPlayerId &&
        _editingCommanderIndex == commanderIndex;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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
                      textColor,
                      textShadows,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: OutlinedText(
                              '$damage',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              useOutline:
                                  Settings.playerUseOutline[targetPlayerId],
                              outlineColor:
                                  Settings.playerOutlineColors[targetPlayerId],
                              strokeWidth: 3.0,
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
                      textColor,
                      textShadows,
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: OutlinedText(
                        (me && damage == 0) ? '--' : '$damage',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        useOutline: Settings.playerUseOutline[targetPlayerId],
                        outlineColor:
                            Settings.playerOutlineColors[targetPlayerId],
                        strokeWidth: 3.0,
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
    Color contentColor = Settings.playerTextColors[targetPlayerId];
    List<Shadow>? textShadows = Settings.playerUseOutline[targetPlayerId]
        ? Settings.getOutlineShadows(
            Settings.playerOutlineColors[targetPlayerId],
          )
        : null;

    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Settings.playerColors[targetPlayerId],
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: contentColor.withOpacity(0.3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: RotatedBox(
        quarterTurns: widget.rotations,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (Settings.playerImageUrls[targetPlayerId].isNotEmpty)
                  Expanded(
                    child: Image(
                      image: _getImageProvider(
                        Settings.playerImageUrls[targetPlayerId],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                if (hasPartner &&
                    Settings.playerPartnerImageUrls[targetPlayerId].isNotEmpty)
                  Expanded(
                    child: Image(
                      image: _getImageProvider(
                        Settings.playerPartnerImageUrls[targetPlayerId],
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
              ],
            ),
            Row(
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
                  me,
                  contentColor,
                  textShadows,
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
                    me,
                    contentColor,
                    textShadows,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommanderGrid() {
    return PlayerLayout.build(
      playerCount: Settings.players,
      builder: (index) => _buildCommanderCell(index),
    );
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
