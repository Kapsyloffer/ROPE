import 'package:flutter/material.dart';

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

  Widget _buildCounterAdjustButton(IconData icon, VoidCallback onTap) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                size: 28,
                color: widget.player.alive ? Colors.black : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterData({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {});
          onIncrement();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildCounterAdjustButton(Icons.remove, () {
                    setState(() {});
                    onDecrement();
                  }),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$value',
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
                  _buildCounterAdjustButton(Icons.add, () {
                    setState(() {});
                    onIncrement();
                  }),
                ],
              ),
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.player.alive
                        ? Colors.black54
                        : Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleDisplay({
    required String label,
    required bool isEnabled,
    required VoidCallback onToggle,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {});
          onToggle();
        },
        child: Container(
          color: Colors.transparent,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Icon(
                    isEnabled ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 48,
                    color: isEnabled
                        ? (widget.player.alive
                              ? Colors.black
                              : Colors.red.shade200)
                        : (widget.player.alive
                              ? Colors.black54
                              : Colors.red.shade900),
                  ),
                ),
              ),
              Positioned(
                top: 4,
                left: 0,
                right: 0,
                child: Text(
                  label.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: widget.player.alive
                        ? Colors.black54
                        : Colors.red.shade900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterCell(List<Widget> children) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black),
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
                    label: 'Poison',
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
                    label: 'Energy',
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
                    label: 'Tax',
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
                      label: 'Tax',
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
                    label: 'Monarch',
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
