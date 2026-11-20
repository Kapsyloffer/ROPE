import 'package:flutter/material.dart';

import '../../models/settings.dart';
import '../../helpers/time_format_helper.dart';

class SlowBurnSettingsCard extends StatefulWidget {
  final VoidCallback onUpdate;

  const SlowBurnSettingsCard({super.key, required this.onUpdate});

  @override
  State<SlowBurnSettingsCard> createState() => _SlowBurnSettingsCardState();
}

class _SlowBurnSettingsCardState extends State<SlowBurnSettingsCard> {
  late TextEditingController _timeController;
  late FocusNode _timeFocusNode;
  late TextEditingController _amountController;
  late FocusNode _amountFocusNode;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(
      text: formatMMSS(Settings.burnInterval),
    );
    _timeFocusNode = FocusNode();
    _timeFocusNode.addListener(_onTimeFocusChanged);

    _amountController = TextEditingController(text: _getFormattedBurnAmount());
    _amountFocusNode = FocusNode();
    _amountFocusNode.addListener(_onAmountFocusChanged);
  }

  @override
  void dispose() {
    _timeFocusNode.removeListener(_onTimeFocusChanged);
    _timeFocusNode.dispose();
    _timeController.dispose();

    _amountFocusNode.removeListener(_onAmountFocusChanged);
    _amountFocusNode.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _getFormattedBurnAmount() {
    return switch (Settings.burnMode) {
      BurnMode.damage => Settings.burnDamage.toString(),
      BurnMode.poison => Settings.burnPoison.toString(),
      BurnMode.time => formatMMSS(Settings.burnTime),
    };
  }

  void _onTimeFocusChanged() {
    if (!_timeFocusNode.hasFocus) {
      double? parsedValue = parseMMSS(_timeController.text);
      if (parsedValue != null) {
        setState(() {
          _timeController.text = formatMMSS(parsedValue);
        });
      }
    }
  }

  void _onAmountFocusChanged() {
    if (!_amountFocusNode.hasFocus && Settings.burnMode == BurnMode.time) {
      double? parsedValue = parseMMSS(_amountController.text);
      if (parsedValue != null) {
        setState(() {
          _amountController.text = formatMMSS(parsedValue);
        });
      }
    }
  }

  Widget _buildPoisonSymbol(double fontSize) {
    return Builder(
      builder: (context) => Text(
        'Φ',
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          height: 1.0,
          color: IconTheme.of(context).color,
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required BurnMode mode,
    required String label,
    required Widget icon,
  }) {
    final bool enabled = Settings.useSlowBurn;
    final bool isSelected = Settings.burnMode == mode;
    final Color? disabledFg = enabled ? null : Theme.of(context).disabledColor;

    final Color? bgColor = isSelected
        ? (enabled
              ? Theme.of(context).colorScheme.primaryContainer
              : Colors.grey.shade200)
        : null;

    final Color borderColor = enabled
        ? (isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade400)
        : Colors.grey.shade300;

    return Expanded(
      child: InkWell(
        onTap: enabled
            ? () {
                _amountFocusNode.unfocus();
                setState(() {
                  Settings.burnMode = mode;
                  _amountController.text = _getFormattedBurnAmount();
                });
                Settings.save();
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: IconTheme.merge(
            data: IconThemeData(color: disabledFg),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: disabledFg,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (amountLabel, amountPrefixIcon) = switch (Settings.burnMode) {
      BurnMode.damage => ('Life Burn', const Icon(Icons.heart_broken)),
      BurnMode.poison => (
        'Poison Burn',
        SizedBox(
          width: 48,
          height: 48,
          child: Center(child: _buildPoisonSymbol(22)),
        ),
      ),
      BurnMode.time => ('Time Burn (mm:ss)', const Icon(Icons.hourglass_empty)),
    };

    return Opacity(
      opacity: Settings.useTimer ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !Settings.useTimer,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.whatshot),
                  title: const Text('Slow Burn'),
                  value: Settings.useSlowBurn,
                  onChanged: (value) {
                    setState(() {
                      Settings.useSlowBurn = value;
                    });
                    Settings.save();
                    widget.onUpdate();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      _buildModeButton(
                        mode: BurnMode.damage,
                        label: 'Life',
                        icon: const Icon(Icons.heart_broken, size: 18),
                      ),
                      const SizedBox(width: 8),
                      _buildModeButton(
                        mode: BurnMode.poison,
                        label: 'Poison',
                        icon: _buildPoisonSymbol(18),
                      ),
                      const SizedBox(width: 8),
                      _buildModeButton(
                        mode: BurnMode.time,
                        label: 'Time',
                        icon: const Icon(Icons.hourglass_empty, size: 18),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextFormField(
                    controller: _timeController,
                    focusNode: _timeFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Burn Interval (mm:ss)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    keyboardType: TextInputType.datetime,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      double? parsedValue = parseMMSS(value);
                      if (parsedValue != null) {
                        // Spara direkt som minuter!
                        Settings.burnInterval = parsedValue;
                        Settings.save();
                      }
                    },
                    onEditingComplete: () {
                      _timeFocusNode.unfocus();
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextFormField(
                    controller: _amountController,
                    focusNode: _amountFocusNode,
                    decoration: InputDecoration(
                      labelText: amountLabel,
                      border: const OutlineInputBorder(),
                      prefixIcon: amountPrefixIcon,
                    ),
                    keyboardType: Settings.burnMode == BurnMode.time
                        ? TextInputType.datetime
                        : TextInputType.number,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      if (Settings.burnMode == BurnMode.time) {
                        double? parsedValue = parseMMSS(value);
                        if (parsedValue != null) {
                          Settings.burnTime = parsedValue;
                          Settings.save();
                        }
                      } else {
                        int? parsedValue = num.tryParse(
                          value.replaceAll(',', '.'),
                        )?.toInt();
                        if (parsedValue != null) {
                          if (Settings.burnMode == BurnMode.damage) {
                            Settings.burnDamage = parsedValue;
                          } else {
                            Settings.burnPoison = parsedValue;
                          }
                          Settings.save();
                        }
                      }
                    },
                    onEditingComplete: () {
                      _amountFocusNode.unfocus();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
