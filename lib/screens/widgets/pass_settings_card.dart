import 'package:flutter/material.dart';

import '../../models/settings.dart';

class PassSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const PassSettingsCard({super.key, required this.onUpdate});

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

