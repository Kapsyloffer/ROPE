import 'dart:async' as async;

import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../models/counters.dart';
import '../helpers/outlined_text.dart';
import '../helpers/outlined_icon.dart';

class LifeDisplay extends StatefulWidget {
  final Player player;
  final void Function(int) onLifeAdjust;
  final VoidCallback? onTimerTap;

  const LifeDisplay({
    super.key,
    required this.player,
    required this.onLifeAdjust,
    this.onTimerTap,
  });

  @override
  State<LifeDisplay> createState() => _LifeDisplayState();
}

class _LifeDisplayState extends State<LifeDisplay> {
  int _lifeDelta = 0;
  bool _showLifeDelta = false;
  async.Timer? _lifeDeltaTimer;
  async.Timer? _lifeDeltaHideTimer;
  double _lifeDeltaOpacity = 0.0;

  int _lastLife = 0;

  async.Timer? _initialHoldTimer;
  async.Timer? _periodicHoldTimer;
  bool _isHolding = false;

  @override
  void initState() {
    super.initState();
    _lastLife = widget.player.curLife;
  }

  @override
  void didUpdateWidget(covariant LifeDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.player != widget.player) {
      _lifeDeltaTimer?.cancel();
      _lifeDeltaHideTimer?.cancel();
      _initialHoldTimer?.cancel();
      _periodicHoldTimer?.cancel();

      _lifeDelta = 0;
      _lifeDeltaOpacity = 0.0;
      _showLifeDelta = false;
      _isHolding = false;
      _lastLife = widget.player.curLife;
      return;
    }

    int diff = widget.player.curLife - _lastLife;
    if (diff != 0) {
      _lifeDelta += diff;
      _showLifeDelta = true;
      _lifeDeltaOpacity = 1.0;

      _lifeDeltaTimer?.cancel();
      _lifeDeltaHideTimer?.cancel();

      _lifeDeltaTimer = async.Timer(const Duration(milliseconds: 1200), () {
        if (mounted) {
          setState(() {
            _lifeDeltaOpacity = 0.0;
          });

          _lifeDeltaHideTimer = async.Timer(
            const Duration(milliseconds: 300),
            () {
              if (mounted && _lifeDeltaOpacity == 0.0) {
                setState(() {
                  _showLifeDelta = false;
                  _lifeDelta = 0;
                });
              }
            },
          );
        }
      });
    }
    _lastLife = widget.player.curLife;
  }

  void _handleLifeAdjust(int amount) {
    widget.onLifeAdjust(amount);
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

  Widget _buildAdjustButton(IconData icon, int amount) {
    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

    return Expanded(
      child: Material(
        color: Colors.transparent,
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
              child: OutlinedIcon(
                icon,
                size: 48,
                color: widget.player.alive
                    ? Settings.playerTextColors[widget.player.order]
                    : Colors.red,
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

  Widget _buildActiveCountersRow() {
    final counters = widget.player.counters.activeCounters;
    final int poison = counters['poison']?.amount ?? 0;
    final int energy = counters['energy']?.amount ?? 0;
    final PairCounter? tax = counters['commanderTax'] as PairCounter?;
    final bool monarch =
        (counters['monarch'] as ToggleCounter?)?.enabled ?? false;
    final bool hasPartner = Settings.hasPartner[widget.player.order];

    List<Widget> activeIcons = [];
    Color textColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order]
        : Colors.red;

    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

    Widget buildItem(Widget iconWidget, [String? text]) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          if (text != null) ...[
            const SizedBox(width: 4),
            OutlinedText(
              text,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              useOutline: useOutline,
              outlineColor: outlineColor,
              strokeWidth: 2.0,
            ),
          ],
        ],
      );
    }

    if (poison > 0) {
      activeIcons.add(
        buildItem(
          OutlinedText(
            'Φ',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            useOutline: useOutline,
            outlineColor: outlineColor,
            strokeWidth: 2.0,
          ),
          '$poison',
        ),
      );
    }
    if (energy > 0) {
      activeIcons.add(
        buildItem(
          OutlinedIcon(
            Icons.bolt,
            color: textColor,
            size: 20,
            useOutline: useOutline,
            outlineColor: outlineColor,
            strokeWidth: 2.0,
          ),
          '$energy',
        ),
      );
    }
    if (tax != null) {
      if (tax.amounts[0] > 0) {
        activeIcons.add(
          buildItem(
            OutlinedIcon(
              Icons.shield_outlined,
              color: textColor,
              size: 20,
              useOutline: useOutline,
              outlineColor: outlineColor,
              strokeWidth: 2.0,
            ),
            '${tax.amounts[0]}',
          ),
        );
      }
      if (hasPartner && tax.amounts[1] > 0) {
        activeIcons.add(
          buildItem(
            OutlinedIcon(
              Icons.shield_outlined,
              color: textColor,
              size: 20,
              useOutline: useOutline,
              outlineColor: outlineColor,
              strokeWidth: 2.0,
            ),
            '${tax.amounts[1]}',
          ),
        );
      }
    }
    if (monarch) {
      activeIcons.add(
        buildItem(
          OutlinedIcon(
            RpgAwesome.crown,
            color: textColor,
            size: 20,
            useOutline: useOutline,
            outlineColor: outlineColor,
            strokeWidth: 2.0,
          ),
        ),
      );
    }

    if (activeIcons.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: activeIcons,
    );
  }

  @override
  void dispose() {
    _lifeDeltaTimer?.cancel();
    _lifeDeltaHideTimer?.cancel();
    _initialHoldTimer?.cancel();
    _periodicHoldTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAdjustButton(Icons.remove, -1),
          Expanded(
            flex: 2,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: (Settings.passOnCenter && Settings.useTimer)
                  ? widget.onTimerTap
                  : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: IgnorePointer(child: _buildActiveCountersRow()),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: OutlinedText(
                      '${widget.player.curLife}',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: widget.player.alive
                            ? Settings.playerTextColors[widget.player.order]
                            : Colors.red,
                      ),
                      useOutline:
                          Settings.playerUseOutline[widget.player.order],
                      outlineColor:
                          Settings.playerOutlineColors[widget.player.order],
                      strokeWidth: 4.0,
                    ),
                  ),
                  if (_showLifeDelta && _lifeDelta != 0)
                    Positioned(
                      top: 12,
                      left: _lifeDelta < 0 ? 8 : null,
                      right: _lifeDelta > 0 ? 8 : null,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _lifeDeltaOpacity,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: OutlinedText(
                            _lifeDelta > 0 ? '+$_lifeDelta' : '$_lifeDelta',
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: widget.player.alive
                                  ? Settings.playerTextColors[widget
                                        .player
                                        .order]
                                  : Colors.red,
                            ),
                            useOutline:
                                Settings.playerUseOutline[widget.player.order],
                            outlineColor: Settings
                                .playerOutlineColors[widget.player.order],
                            strokeWidth: 3.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildAdjustButton(Icons.add, 1),
        ],
      ),
    );
  }
}
