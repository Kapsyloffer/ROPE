import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';

import 'life_display.dart';
import 'commander_damage_grid.dart';
import 'counters_grid.dart';
import 'timer_display.dart';

enum OverlayMode { none, commander, counters }

class PlayerWidget extends StatefulWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final void Function(int) onLifeAdjust;
  final void Function(double) onTimeAdjust;
  final void Function(int, int, int) onCommanderDamageAdjust;
  final void Function(String, int) onCounterAdjust;
  final VoidCallback onTimerLongPress;
  final int rotations;

  const PlayerWidget({
    super.key,
    required this.player,
    required this.onTimerTap,
    required this.onLifeAdjust,
    required this.onTimeAdjust,
    required this.onCommanderDamageAdjust,
    required this.onCounterAdjust,
    required this.onTimerLongPress,
    this.rotations = 0,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  OverlayMode _overlayMode = OverlayMode.none;
  double _dragDistance = 0.0;

  Offset _getSlideOffset(OverlayMode targetMode) {
    if (_overlayMode == targetMode) return Offset.zero;
    if (_overlayMode == OverlayMode.commander && targetMode == OverlayMode.none)
      return const Offset(0.0, -1.0);
    if (_overlayMode == OverlayMode.counters && targetMode == OverlayMode.none)
      return const Offset(0.0, 1.0);
    if (_overlayMode == OverlayMode.none && targetMode == OverlayMode.commander)
      return const Offset(0.0, 1.0);
    if (_overlayMode == OverlayMode.none && targetMode == OverlayMode.counters)
      return const Offset(0.0, -1.0);
    return Offset.zero;
  }

  @override
  Widget build(BuildContext context) {
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragStart: (_) => _dragDistance = 0.0,
              onVerticalDragUpdate: (details) =>
                  _dragDistance += details.primaryDelta ?? 0.0,
              onVerticalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0.0;
                if (velocity < -100 || _dragDistance < -40) {
                  setState(() {
                    if (_overlayMode == OverlayMode.counters) {
                      _overlayMode = OverlayMode.none;
                    } else {
                      _overlayMode = OverlayMode.commander;
                    }
                  });
                } else if (velocity > 100 || _dragDistance > 40) {
                  setState(() {
                    if (_overlayMode == OverlayMode.commander) {
                      _overlayMode = OverlayMode.none;
                    } else {
                      _overlayMode = OverlayMode.counters;
                    }
                  });
                }
              },
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: AnimatedSlide(
                        offset: _getSlideOffset(OverlayMode.none),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _overlayMode == OverlayMode.none ? 1.0 : 0.0,
                          child: IgnorePointer(
                            ignoring: _overlayMode != OverlayMode.none,
                            child: LifeDisplay(
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
                        offset: _getSlideOffset(OverlayMode.commander),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _overlayMode == OverlayMode.commander
                              ? 1.0
                              : 0.0,
                          child: IgnorePointer(
                            ignoring: _overlayMode != OverlayMode.commander,
                            child: CommanderDamageGrid(
                              key: ValueKey(widget.player.order),
                              player: widget.player,
                              onCommanderDamageAdjust:
                                  widget.onCommanderDamageAdjust,
                              rotations: widget.rotations,
                              isVisible: _overlayMode == OverlayMode.commander,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: AnimatedSlide(
                        offset: _getSlideOffset(OverlayMode.counters),
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _overlayMode == OverlayMode.counters
                              ? 1.0
                              : 0.0,
                          child: IgnorePointer(
                            ignoring: _overlayMode != OverlayMode.counters,
                            child: CountersGrid(
                              key: ValueKey(widget.player.order),
                              player: widget.player,
                              onCounterAdjust: widget.onCounterAdjust,
                              isVisible: _overlayMode == OverlayMode.counters,
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
          if (Settings.useTimer)
            Expanded(
              flex: 1,
              child: TimerDisplay(
                key: ValueKey(widget.player.order),
                player: widget.player,
                onTimerTap: widget.onTimerTap,
                onTimerLongPress: widget.onTimerLongPress,
                onTimeAdjust: widget.onTimeAdjust,
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
