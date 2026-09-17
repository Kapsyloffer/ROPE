import 'package:flutter/material.dart';

import 'widgets/general_settings_card.dart';
import 'widgets/timer_settings_card.dart';
import 'widgets/slowburn_settings_card.dart';
import 'widgets/player_customization_card.dart';

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
          const SizedBox(height: 16),
          PlayerCustomizationCard(onUpdate: _refreshSettings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
