import 'package:flutter/material.dart';

import '../../models/settings.dart';

class TimerSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const TimerSettingsCard({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SwitchListTile(
              secondary: const Icon(Icons.hourglass_bottom_rounded),
              title: const Text('Use Timer'),
              value: Settings.useTimer,
              onChanged: (value) {
                Settings.useTimer = value;
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
                initialValue: Settings.startTime.toString(),
                decoration: const InputDecoration(
                  labelText: 'Start Time (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                enabled: Settings.useTimer,
                onChanged: (value) {
                  double? parsedValue = num.tryParse(value.replaceAll(',', '.'))
                      ?.toDouble();
                  if (parsedValue != null) {
                    Settings.startTime = parsedValue;
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
                initialValue: Settings.increment.toString(),
                decoration: const InputDecoration(
                  labelText: 'Increment (seconds)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.arrow_drop_up),
                ),
                keyboardType: TextInputType.number,
                enabled: Settings.useTimer,
                onChanged: (value) {
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))
                      ?.toInt();
                  if (parsedValue != null) {
                    Settings.increment = parsedValue;
                    Settings.save();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
