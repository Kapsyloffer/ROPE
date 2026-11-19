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

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(
      text: formatMMSS(Settings.burnInterval),
    );
    _timeFocusNode = FocusNode();
    _timeFocusNode.addListener(_onTimeFocusChanged);
  }

  @override
  void dispose() {
    _timeFocusNode.removeListener(_onTimeFocusChanged);
    _timeFocusNode.dispose();
    _timeController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
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
                    initialValue: Settings.burnAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Burn Damage',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.heart_broken),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      int? parsedValue = num.tryParse(
                        value.replaceAll(',', '.'),
                      )?.toInt();
                      if (parsedValue != null) {
                        Settings.burnAmount = parsedValue;
                        Settings.save();
                      }
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
