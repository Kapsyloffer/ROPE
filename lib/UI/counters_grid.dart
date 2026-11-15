import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../models/counters.dart';

class CountersGrid extends StatefulWidget {
  final Player player;
  final void Function(String, int) onCounterAdjust;
  final bool isVisible;

  const CountersGrid({
    super.key,
    required this.player,
    required this.onCounterAdjust,
    required this.isVisible,
  });

  @override
  State<CountersGrid> createState() => _CountersGridState();
}

class _CountersGridState extends State<CountersGrid> {
  @override
  void didUpdateWidget(covariant CountersGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isVisible && !widget.isVisible) ||
        oldWidget.player != widget.player) {}
  }

  Widget _buildCounterAdjustButton(
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(icon, size: 28, color: color),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterData({
    required Widget prefixWidget,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    Color textColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order]
        : Colors.red;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {});
          onIncrement();
        },
        child: Container(
          color: Colors.transparent,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCounterAdjustButton(Icons.remove, () {
                setState(() {});
                onDecrement();
              }, textColor),
              Expanded(
                flex: 2,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          prefixWidget,
                          const SizedBox(width: 8),
                          Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              _buildCounterAdjustButton(Icons.add, () {
                setState(() {});
                onIncrement();
              }, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleDisplay({
    required Widget prefixWidget,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    Color activeColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order]
        : Colors.red;
    Color inactiveColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order].withValues(alpha: 0.4)
        : Colors.red.shade900;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {});
          onToggle();
        },
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    prefixWidget,
                    const SizedBox(width: 8),
                    Icon(
                      isEnabled ? Icons.check : Icons.close,
                      size: 40,
                      color: isEnabled ? activeColor : inactiveColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCell(List<Widget> children) {
    Color borderColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order].withValues(alpha: 0.3)
        : Colors.red.shade900;

    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasPartner = Settings.hasPartner[widget.player.order];
    Color contentColor = widget.player.alive
        ? Settings.playerTextColors[widget.player.order]
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCounterCell([
                  _buildCounterData(
                    prefixWidget: Text(
                      'Φ',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                    ),
                    value:
                        widget
                            .player
                            .counters
                            .activeCounters['poison']
                            ?.amount ??
                        0,
                    onIncrement: () => widget.onCounterAdjust('poison', 1),
                    onDecrement: () => widget.onCounterAdjust('poison', -1),
                  ),
                ]),
                _buildCounterCell([
                  _buildCounterData(
                    prefixWidget: Icon(
                      Icons.bolt,
                      size: 38,
                      color: contentColor,
                    ),
                    value:
                        widget
                            .player
                            .counters
                            .activeCounters['energy']
                            ?.amount ??
                        0,
                    onIncrement: () => widget.onCounterAdjust('energy', 1),
                    onDecrement: () => widget.onCounterAdjust('energy', -1),
                  ),
                ]),
              ],
            ),
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildCounterCell([
                  _buildCounterData(
                    prefixWidget: Icon(
                      Icons.shield_outlined,
                      size: 32,
                      color: contentColor,
                    ),
                    value:
                        (widget.player.counters.activeCounters['commanderTax']
                                as PairCounter?)
                            ?.amounts[0] ??
                        0,
                    onIncrement: () {
                      final c =
                          widget.player.counters.activeCounters['commanderTax']
                              as PairCounter?;
                      if (c != null) {
                        c.amounts[0]++;
                        widget.onCounterAdjust('commanderTax', 0);
                      }
                    },
                    onDecrement: () {
                      final c =
                          widget.player.counters.activeCounters['commanderTax']
                              as PairCounter?;
                      if (c != null && c.amounts[0] > 0) {
                        c.amounts[0]--;
                        widget.onCounterAdjust('commanderTax', 0);
                      }
                    },
                  ),
                  if (hasPartner)
                    _buildCounterData(
                      prefixWidget: Icon(
                        Icons.shield_outlined,
                        size: 32,
                        color: contentColor,
                      ),
                      value:
                          (widget.player.counters.activeCounters['commanderTax']
                                  as PairCounter?)
                              ?.amounts[1] ??
                          0,
                      onIncrement: () {
                        final c =
                            widget
                                    .player
                                    .counters
                                    .activeCounters['commanderTax']
                                as PairCounter?;
                        if (c != null) {
                          c.amounts[1]++;
                          widget.onCounterAdjust('commanderTax', 0);
                        }
                      },
                      onDecrement: () {
                        final c =
                            widget
                                    .player
                                    .counters
                                    .activeCounters['commanderTax']
                                as PairCounter?;
                        if (c != null && c.amounts[1] > 0) {
                          c.amounts[1]--;
                          widget.onCounterAdjust('commanderTax', 0);
                        }
                      },
                    ),
                ]),
                _buildCounterCell([
                  _buildToggleDisplay(
                    prefixWidget: Icon(
                      RpgAwesome.crown,
                      size: 34,
                      color: contentColor,
                    ),
                    isEnabled:
                        (widget.player.counters.activeCounters['monarch']
                                as ToggleCounter?)
                            ?.enabled ??
                        false,
                    onToggle: () => widget.onCounterAdjust('monarch', 1),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
