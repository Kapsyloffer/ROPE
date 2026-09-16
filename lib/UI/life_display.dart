import 'dart:async' as async;

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../models/counters.dart';

class LifeDisplay extends StatefulWidget {
  final Player player;
  final void Function(int) onLifeAdjust;

  const LifeDisplay({
    super.key,
    required this.player,
    required this.onLifeAdjust,
  });

  @override
  State<LifeDisplay> createState() => _LifeDisplayState();
}

class _LifeDisplayState extends State<LifeDisplay> {
  int _lifeDelta = 0;
  bool _showLifeDelta = false;
  async.Timer? _lifeDeltaTimer;
  double _lifeDeltaOpacity = 0.0;

  async.Timer? _initialHoldTimer;
  async.Timer? _periodicHoldTimer;
  bool _isHolding = false;

  bool _wasMonarch = false;
  bool _showLostMonarch = false;
  async.Timer? _lostMonarchTimer;

  @override
  void initState() {
    super.initState();
    _wasMonarch =
        (widget.player.counters.activeCounters['monarch'] as ToggleCounter?)
            ?.enabled ??
        false;
  }

  @override
  void didUpdateWidget(covariant LifeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    bool currentlyMonarch =
        (widget.player.counters.activeCounters['monarch'] as ToggleCounter?)
            ?.enabled ??
        false;

    if (oldWidget.player != widget.player) {
      _lifeDeltaTimer?.cancel();
      _initialHoldTimer?.cancel();
      _periodicHoldTimer?.cancel();
      _lostMonarchTimer?.cancel();

      _lifeDelta = 0;
      _lifeDeltaOpacity = 0.0;
      _showLifeDelta = false;
      _isHolding = false;
      _showLostMonarch = false;
      _wasMonarch = currentlyMonarch;
    } else {
      if (_wasMonarch && !currentlyMonarch) {
        _showLostMonarch = true;
        _lostMonarchTimer?.cancel();
        _lostMonarchTimer = async.Timer(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() {
              _showLostMonarch = false;
            });
          }
        });
      }
      _wasMonarch = currentlyMonarch;
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
    _lostMonarchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = widget.player.alive
        ? Settings.playerColors[widget.player.order]
        : Colors.grey.shade800;

    bool isMonarch =
        (widget.player.counters.activeCounters['monarch'] as ToggleCounter?)
            ?.enabled ??
        false;

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
                      '${widget.player.curLife}',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: widget.player.alive ? Colors.black : Colors.red,
                      ),
                    ),
                  ),
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
              Positioned(
                bottom: 16,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: isMonarch
                      ? const Icon(
                          Icons.military_tech,
                          color: Colors.black,
                          size: 28,
                          key: ValueKey('monarch'),
                        )
                      : _showLostMonarch
                      ? const Icon(
                          Icons.military_tech_outlined,
                          color: Colors.black54,
                          size: 28,
                          key: ValueKey('lost'),
                        )
                      : const SizedBox(key: ValueKey('none')),
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
