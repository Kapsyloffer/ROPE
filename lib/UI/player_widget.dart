import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';

import 'life_display.dart';
import 'commander_damage_grid.dart';
import 'counters_grid.dart';
import 'timer_display.dart';

class PlayerWidget extends StatefulWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final void Function(int) onLifeAdjust;
  final void Function(double) onTimeAdjust;
  final void Function(int, int, int) onCommanderDamageAdjust;
  final void Function(String, int) onCounterAdjust;
  final VoidCallback onTimerLongPress;
  final int rotations;
  final int resetTrigger;
  final bool isHighlighted;

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
    this.resetTrigger = 0,
    this.isHighlighted = false,
  });

  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      value: 0.0,
      lowerBound: -1.0,
      upperBound: 1.0,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void didUpdateWidget(covariant PlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetTrigger != widget.resetTrigger) {
      _slideController.animateTo(0.0, curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final double height = context.size?.height ?? 300.0;
    _slideController.value -= details.primaryDelta! / height;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    double target = 0.0;
    final double velocity = details.primaryVelocity ?? 0.0;

    if (velocity < -100) {
      target = (_slideController.value + 0.5).ceilToDouble().clamp(-1.0, 1.0);
    } else if (velocity > 100) {
      target = (_slideController.value - 0.5).floorToDouble().clamp(-1.0, 1.0);
    } else {
      if (_slideController.value > 0.4) {
        target = 1.0;
      } else if (_slideController.value < -0.4) {
        target = -1.0;
      }
    }

    _slideController.animateTo(target, curve: Curves.easeOut);
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
            child: Stack(
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  child: ClipRect(
                    child: AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, child) {
                        double val = _slideController.value;
                        return Stack(
                          children: [
                            FractionalTranslation(
                              translation: Offset(0.0, -1.0 - val),
                              child: Opacity(
                                opacity: (1.0 - (val + 1.0).abs()).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: IgnorePointer(
                                  ignoring: val.round() != -1,
                                  child: CountersGrid(
                                    key: ValueKey(
                                      '${widget.player.order}_counters',
                                    ),
                                    player: widget.player,
                                    onCounterAdjust: widget.onCounterAdjust,
                                    isVisible: val.round() == -1,
                                  ),
                                ),
                              ),
                            ),
                            FractionalTranslation(
                              translation: Offset(0.0, -val),
                              child: Opacity(
                                opacity: (1.0 - val.abs()).clamp(0.0, 1.0),
                                child: IgnorePointer(
                                  ignoring: val.round() != 0,
                                  child: LifeDisplay(
                                    key: ValueKey(
                                      '${widget.player.order}_life',
                                    ),
                                    player: widget.player,
                                    onLifeAdjust: widget.onLifeAdjust,
                                  ),
                                ),
                              ),
                            ),
                            FractionalTranslation(
                              translation: Offset(0.0, 1.0 - val),
                              child: Opacity(
                                opacity: (1.0 - (val - 1.0).abs()).clamp(
                                  0.0,
                                  1.0,
                                ),
                                child: IgnorePointer(
                                  ignoring: val.round() != 1,
                                  child: CommanderDamageGrid(
                                    key: ValueKey(
                                      '${widget.player.order}_commander',
                                    ),
                                    player: widget.player,
                                    onCommanderDamageAdjust:
                                        widget.onCommanderDamageAdjust,
                                    rotations: widget.rotations,
                                    isVisible: val.round() == 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                if (Settings.useFlashing)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: widget.player.isBurnFlashing
                                ? Colors.red
                                : widget.isHighlighted
                                ? Colors.white
                                : Colors.transparent,
                            width: 8.0,
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
