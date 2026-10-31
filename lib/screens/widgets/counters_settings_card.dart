import 'package:flutter/material.dart';

import '../../models/settings.dart';

class CountersSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const CountersSettingsCard({super.key, required this.onUpdate});

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
              secondary: const Icon(Icons.casino),
              title: const Text('Use Counters'),
              value: Settings.useCounters,
              onChanged: (value) {
                Settings.useCounters = value;
                Settings.save();
                onUpdate();
              },
            ),
          ],
        ),
      ),
    );
  }
}
