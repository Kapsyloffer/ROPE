import 'package:flutter/material.dart';

import '../../models/settings.dart';

class CommanderDamageSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const CommanderDamageSettingsCard({super.key, required this.onUpdate});

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
              secondary: const Icon(Icons.shield_sharp),
              title: const Text('Use Commander Damage'),
              value: Settings.useCommanderDamage,
              onChanged: (value) {
                Settings.useCommanderDamage = value;
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
