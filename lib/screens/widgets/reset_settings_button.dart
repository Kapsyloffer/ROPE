import 'package:flutter/material.dart';

import '../../models/settings.dart';

class ResetSettingsButton extends StatelessWidget {
  final VoidCallback onUpdate;

  const ResetSettingsButton({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () async {
        await Settings.prefs.clear();
        Settings.load();
        onUpdate();
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Factory reset baby')));
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade100,
        foregroundColor: Colors.red.shade900,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: const Icon(Icons.delete_forever),
      label: const Text('Clear SharedPreferences'),
    );
  }
}
