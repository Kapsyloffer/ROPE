import 'dart:async' as async;

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';

String _formatTime(double seconds) {
  int min = seconds ~/ 60;
  int sec = (seconds % 60).toInt();
  return '$min:${sec.toString().padLeft(2, '0')}';
}

class TimerDisplay extends StatefulWidget {
  final Player player;
  final VoidCallback onTimerTap;
  final VoidCallback onTimerLongPress;
  final void Function(double) onTimeAdjust;

  const TimerDisplay({
    super.key,
    required this.player,
    required this.onTimerTap,
    required this.onTimerLongPress,
    required this.onTimeAdjust,
  });

  @override
  State<TimerDisplay> createState() => _TimerDisplayState();
}

class _TimerDisplayState extends State<TimerDisplay>
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
        ? widget.player.timer.elapsedTurnTime / Settings.burnInterval
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

      _isEditingTimer = false;
      _showTimeIncrement = false;
      _timeIncOpacity = 0.0;
      _timeIncAlignment = const Alignment(0.0, -0.8);
    }

    if (widget.player.timer.curTime > _lastTime &&
        !widget.player.timer.active &&
        Settings.useTimer &&
        Settings.increment > 0 &&
        !widget.player.isInterrupted) {
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
    Color activeTimerColor = Colors.green.shade400;
    Color ropeColor = Colors.green.shade800;

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
                    ? activeTimerColor
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
                            decoration: BoxDecoration(color: ropeColor),
                          ),
                        );
                      },
                    );
                  },
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
