import 'package:flutter/material.dart';

import '../../models/settings.dart';

class SlowBurnSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const SlowBurnSettingsCard({super.key, required this.onUpdate});

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
                    Settings.useSlowBurn = value;
                    Settings.save();
                    onUpdate();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: TextFormField(
                    initialValue: Settings.burnInterval.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Burn Interval (seconds)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      int? parsedValue = num.tryParse(
                        value.replaceAll(',', '.'),
                      )?.toInt();
                      if (parsedValue != null) {
                        Settings.burnInterval = parsedValue;
                        Settings.save();
                      }
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
