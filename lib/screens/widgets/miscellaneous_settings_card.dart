import 'package:flutter/material.dart';

import '../../models/settings.dart';

class MiscellaneousSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const MiscellaneousSettingsCard({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                'Miscellaneous',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            SwitchListTile(
              secondary: const Icon(Icons.shield_sharp),
              title: const Text('Use Commander Damage'),
              value: Settings.useCommanderDamage,
              onChanged: (value) {
                Settings.useCommanderDamage = value;
                Settings.save();
                onUpdate();
              },
            ),
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
            SwitchListTile(
              secondary: const Icon(Icons.hourglass_empty),
              title: const Text('Timer hitbox covers screen (Experimental)'),
              value: Settings.passOnCenter,
              onChanged: (value) {
                Settings.passOnCenter = value;
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
