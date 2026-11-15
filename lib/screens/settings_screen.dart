import 'package:flutter/material.dart';

import '../models/settings.dart';
import 'widgets/general_settings_card.dart';
import 'widgets/timer_settings_card.dart';
import 'widgets/slowburn_settings_card.dart';
import 'widgets/commander_damage_settings_card.dart';
import 'widgets/counters_settings_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _refreshSettings() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Settings'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GeneralSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 16),
          TimerSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 16),
          SlowBurnSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 24),
          CommanderDamageSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 24),
          CountersSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              await Settings.prefs.clear();
              Settings.load();
              _refreshSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Factory reset baby')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade100,
              foregroundColor: Colors.red.shade900,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Clear SharedPreferences'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
