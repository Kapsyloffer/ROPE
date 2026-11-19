import 'dart:async' as async;

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../helpers/outlined_text.dart';
import '../helpers/outlined_icon.dart';

import '../helpers/time_format_helper.dart';
import '../helpers/marching_ants.dart';

class TimerDisplay extends StatefulWidget {
  final Player player;
  final bool isNextInQueue;
  final VoidCallback onTimerTap;
  final VoidCallback onTimerLongPress;
  final void Function(double) onTimeAdjust;
  final VoidCallback? onPriorityCheck;

  const TimerDisplay({
    super.key,
    required this.player,
    required this.isNextInQueue,
    required this.onTimerTap,
    required this.onTimerLongPress,
    required this.onTimeAdjust,
    this.onPriorityCheck,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
    with TickerProviderStateMixin {
  bool _showTimeIncrement = false;
  async.Timer? _delayTimer;
  async.Timer? _timeIncrementTimer;
  Alignment _timeIncAlignment = const Alignment(0.0, -0.8);
  double _timeIncOpacity = 0.0;
  double _lastTime = 0.0;
  double _lastAddedAmount = 0.0;
  bool _isEditingTimer = false;

  async.Timer? _initialHoldTimer;
  async.Timer? _periodicHoldTimer;
  bool _isHolding = false;

  late AnimationController _ropeController;
  late AnimationController _antsController;

  @override
  void initState() {
    super.initState();
    _lastTime = widget.player.timer.curTime;

    int durationSec = Settings.burnInterval > 0
        ? (Settings.burnInterval * 60.0).round()
        : 1;
    _ropeController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSec),
    );

    _antsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.isNextInQueue) {
      _antsController.repeat();
    }

    if (!Settings.useSlowBurn) {
      return;
    }
    if (!widget.player.timer.active) {
      return;
    }
    if (!widget.player.alive) {
      return;
    }
    double startFraction = Settings.burnInterval > 0
        ? widget.player.timer.elapsedTurnTime / (Settings.burnInterval * 60.0)
        : 0.0;
    if (startFraction < 0.0) startFraction = 0.0;
    if (startFraction > 1.0) startFraction = 1.0;
    _ropeController.value = startFraction;
    _ropeController.repeat();
  }

  @override
  void didUpdateWidget(covariant TimerDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.player != widget.player) {
      _delayTimer?.cancel();
      _timeIncrementTimer?.cancel();

      _initialHoldTimer?.cancel();
      _periodicHoldTimer?.cancel();
      _isHolding = false;

      _isEditingTimer = false;
      _showTimeIncrement = false;
      _timeIncOpacity = 0.0;
      _timeIncAlignment = const Alignment(0.0, -0.8);
    }

    if (widget.isNextInQueue && !_antsController.isAnimating) {
      _antsController.repeat();
    } else if (!widget.isNextInQueue && _antsController.isAnimating) {
      _antsController.stop();
    }

    double timeDiff = widget.player.timer.curTime - _lastTime;
    if (timeDiff > 0.5 &&
        Settings.useTimer &&
        !_isEditingTimer &&
        !widget.player.isInterrupted) {
      _triggerTimeIncrement(timeDiff);
    }

    _handleRopeAnimation();
    _lastTime = widget.player.timer.curTime;
  }

  void _handleRopeAnimation() {
    int durationSec = Settings.burnInterval > 0
        ? (Settings.burnInterval * 60.0).round()
        : 1;
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
          ? widget.player.timer.elapsedTurnTime / (Settings.burnInterval * 60.0)
          : 0.0;
      if (currentFraction < 0.0) currentFraction = 0.0;
      if (currentFraction > 1.0) currentFraction = 1.0;
      _ropeController.value = currentFraction;
      _ropeController.repeat();
    }
  }

  void _triggerTimeIncrement(double amount) {
    setState(() {
      _lastAddedAmount = amount;
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

  void _handleTapDown(double amount) {
    _isHolding = false;
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();

    _initialHoldTimer = async.Timer(const Duration(milliseconds: 500), () {
      _isHolding = true;
      widget.onTimeAdjust(amount * 4);
      _periodicHoldTimer = async.Timer.periodic(
        const Duration(milliseconds: 500),
        (t) {
          widget.onTimeAdjust(amount * 4);
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

  Widget _buildTimerAdjustButton(
    IconData icon,
    double amount,
    Color iconColor,
  ) {
    bool useOutline = widget.player.timer.active
        ? false
        : Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!_isHolding) widget.onTimeAdjust(amount);
          },
          onTapDown: (_) => _handleTapDown(amount),
          onTapUp: (_) => _handleTapUp(),
          onTapCancel: _handleTapCancel,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedIcon(
                icon,
                size: 56,
                color: iconColor,
                useOutline: useOutline,
                outlineColor: outlineColor,
                strokeWidth: 3.0,
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
    _antsController.dispose();
    _timeIncrementTimer?.cancel();
    _delayTimer?.cancel();
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color activeTimerColor = Colors.green.shade400;
    Color ropeColor = Colors.green.shade800;

    bool hasImage = Settings.playerImageUrls[widget.player.order].isNotEmpty;
    bool hasPartner = Settings.hasPartner[widget.player.order];
    bool hasPartnerImage =
        Settings.playerPartnerImageUrls[widget.player.order].isNotEmpty;
    bool hasAnyImage = hasImage || (hasPartner && hasPartnerImage);

    if (widget.player.timer.curTime <= 15) {
      activeTimerColor = Colors.redAccent.shade400;
      ropeColor = Colors.redAccent.shade700;
    } else if (widget.player.timer.curTime <= 30) {
      activeTimerColor = Colors.deepOrange.shade400;
      ropeColor = Colors.deepOrange.shade700;
    } else if (widget.player.timer.curTime <= 60) {
      activeTimerColor = Colors.amber.shade500;
      ropeColor = Colors.amber.shade800;
    }

    if (hasAnyImage) {
      activeTimerColor = activeTimerColor.withValues(alpha: 0.8);
    }

    Color playerBgColor = Settings.playerColors[widget.player.order];
    HSVColor hsv = HSVColor.fromColor(playerBgColor);
    Color inactiveSolidColor;

    if (hsv.saturation < 0.05) {
      inactiveSolidColor = hsv
          .withValue((hsv.value - 0.15).clamp(0.0, 1.0))
          .toColor();
    } else {
      inactiveSolidColor = hsv
          .withSaturation((hsv.saturation + 0.20).clamp(0.0, 1.0))
          .toColor();
    }

    Color antsColor = widget.player.timer.active
        ? Colors.black
        : Settings.playerTextColors[widget.player.order];

    Color textColor = widget.player.alive
        ? (widget.player.timer.active
              ? Colors.black
              : Settings.playerTextColors[widget.player.order])
        : Colors.red;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
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
                    ? activeTimerColor
                    : (hasAnyImage
                          ? Colors.black.withValues(alpha: 0.25)
                          : inactiveSolidColor))
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
                            decoration: BoxDecoration(color: ropeColor),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            if (widget.isNextInQueue)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _antsController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: MarchingAntsPainter(
                          progress: _antsController.value,
                          color: antsColor,
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (widget.player.queuePosition > 0 && widget.player.alive)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: activeTimerColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    (widget.player.timer.active
                        ? ''
                        : '${widget.player.queuePosition}'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            if (_isEditingTimer)
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTimerAdjustButton(Icons.remove, -15.0, textColor),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: OutlinedText(
                          formatTime(widget.player.timer.curTime),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                          useOutline: widget.player.timer.active
                              ? false
                              : Settings.playerUseOutline[widget.player.order],
                          outlineColor:
                              Settings.playerOutlineColors[widget.player.order],
                          strokeWidth: 4.0,
                        ),
                      ),
                    ),
                  ),
                  _buildTimerAdjustButton(Icons.add, 15.0, textColor),
                ],
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedText(
                      formatTime(widget.player.timer.curTime),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      useOutline: widget.player.timer.active
                          ? false
                          : Settings.playerUseOutline[widget.player.order],
                      outlineColor:
                          Settings.playerOutlineColors[widget.player.order],
                      strokeWidth: 4.0,
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
                  child: OutlinedText(
                    '+${formatTime(_lastAddedAmount)}',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: widget.player.alive
                          ? (widget.player.timer.active
                                ? Colors.black54
                                : Settings.playerTextColors[widget.player.order]
                                      .withValues(alpha: 0.6))
                          : Colors.red,
                    ),
                    useOutline: widget.player.timer.active
                        ? false
                        : Settings.playerUseOutline[widget.player.order],
                    outlineColor:
                        Settings.playerOutlineColors[widget.player.order],
                    strokeWidth: 3.0,
                  ),
                ),
              ),
            if (widget.player.timer.active && widget.player.alive) ...[
              if (widget.player.isPriority)
                Positioned(
                  left: 12,
                  child: Icon(
                    Icons.playlist_add_check,
                    size: 36,
                    color: ropeColor,
                  ),
                )
              else if (widget.player.isInterrupting)
                Positioned(
                  left: 12,
                  child: Icon(Icons.warning, size: 36, color: ropeColor),
                ),
              if (Settings.usePriority)
                Positioned(
                  right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: IconButton(
                      icon: const Icon(Icons.rotate_right, size: 36),
                      color: ropeColor,
                      onPressed: widget.onPriorityCheck,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
