import 'package:flutter/material.dart';
import 'package:fluttericon/rpg_awesome_icons.dart';

import '../models/player.dart';
import '../models/settings.dart';
import '../models/counters.dart';
import '../helpers/outlined_text.dart';
import '../helpers/outlined_icon.dart';

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
    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: OutlinedIcon(
                icon,
                size: 28,
                color: color,
                useOutline: useOutline,
                outlineColor: outlineColor,
                strokeWidth: 2.0,
              ),
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

    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

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
                          OutlinedText(
                            '$value',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            useOutline: useOutline,
                            outlineColor: outlineColor,
                            strokeWidth: 4.0,
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

    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

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
                    OutlinedIcon(
                      isEnabled ? Icons.check : Icons.close,
                      size: 40,
                      color: isEnabled ? activeColor : inactiveColor,
                      useOutline: useOutline,
                      outlineColor: outlineColor,
                      strokeWidth: 3.0,
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

    bool useOutline = Settings.playerUseOutline[widget.player.order];
    Color outlineColor = Settings.playerOutlineColors[widget.player.order];

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
                    prefixWidget: OutlinedText(
                      'Φ',
                      style: TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: contentColor,
                      ),
                      useOutline: useOutline,
                      outlineColor: outlineColor,
                      strokeWidth: 3.0,
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
                    prefixWidget: OutlinedIcon(
                      Icons.bolt,
                      size: 38,
                      color: contentColor,
                      useOutline: useOutline,
                      outlineColor: outlineColor,
                      strokeWidth: 3.0,
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
                    prefixWidget: OutlinedIcon(
                      Icons.shield_outlined,
                      size: 32,
                      color: contentColor,
                      useOutline: useOutline,
                      outlineColor: outlineColor,
                      strokeWidth: 2.5,
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
                      prefixWidget: OutlinedIcon(
                        Icons.shield_outlined,
                        size: 32,
                        color: contentColor,
                        useOutline: useOutline,
                        outlineColor: outlineColor,
                        strokeWidth: 2.5,
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
                    prefixWidget: OutlinedIcon(
                      RpgAwesome.crown,
                      size: 34,
                      color: contentColor,
                      useOutline: useOutline,
                      outlineColor: outlineColor,
                      strokeWidth: 2.5,
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
