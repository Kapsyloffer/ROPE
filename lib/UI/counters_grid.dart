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
  String? _editingCounter;

  @override
  void didUpdateWidget(covariant CountersGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.isVisible && !widget.isVisible) ||
        oldWidget.player != widget.player) {
      _editingCounter = null;
    }
  }

  Widget _buildCounterAdjustButton(
    String counterType,
    IconData icon,
    int amount,
  ) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onCounterAdjust(counterType, amount),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Icon(
                icon,
                size: 32,
                color: widget.player.alive ? Colors.black : Colors.red,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCounterData(String counterType, String label, int value) {
    bool isEditing = _editingCounter == counterType;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isEditing) {
            setState(() {
              _editingCounter = null;
            });
          } else {
            widget.onCounterAdjust(counterType, 1);
          }
        },
        onLongPress: () {
          setState(() {
            _editingCounter = counterType;
          });
        },
        child: Container(
          color: Colors.transparent,
          child: isEditing
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCounterAdjustButton(counterType, Icons.remove, -1),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              label.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: widget.player.alive
                                    ? Colors.black54
                                    : Colors.red.shade900,
                              ),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '$value',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: widget.player.alive
                                    ? Colors.black
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCounterAdjustButton(counterType, Icons.add, 1),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: widget.player.alive
                              ? Colors.black54
                              : Colors.red.shade900,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: widget.player.alive
                              ? Colors.black
                              : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildToggleDisplay(String counterType, String label, bool isEnabled) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onCounterAdjust(counterType, 1);
        },
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: widget.player.alive
                        ? Colors.black54
                        : Colors.red.shade900,
                  ),
                ),
              ),
              Icon(
                isEnabled ? Icons.military_tech : Icons.military_tech_outlined,
                size: 32,
                color: isEnabled
                    ? (widget.player.alive ? Colors.white : Colors.red.shade200)
                    : (widget.player.alive
                          ? Colors.black54
                          : Colors.red.shade900),
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
          color: Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.black12),
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
                    'poison',
                    'Poison',
                    widget.player.counters.activeCounters['poison']?.amount ??
                        0,
                  ),
                ]),
                _buildCounterCell([
                  _buildCounterData(
                    'energy',
                    'Energy',
                    widget.player.counters.activeCounters['energy']?.amount ??
                        0,
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
                    'taxMain',
                    'Tax',
                    widget.player.counters.activeCounters['taxMain']?.amount ??
                        0,
                  ),
                  if (hasPartner)
                    _buildCounterData(
                      'taxPartner',
                      'P. Tax',
                      widget
                              .player
                              .counters
                              .activeCounters['taxPartner']
                              ?.amount ??
                          0,
                    ),
                ]),
                _buildCounterCell([
                  _buildToggleDisplay(
                    'monarch',
                    'Monarch',
                    (widget.player.counters.activeCounters['monarch']
                                as ToggleCounter?)
                            ?.enabled ??
                        false,
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
