import 'package:flutter/material.dart';

import '../../models/settings.dart';

class GeneralSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const GeneralSettingsCard({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Players'),
              trailing: DropdownButton<int>(
                value: Settings.players,
                underline: const SizedBox(),
                items: [2, 3, 4].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    Settings.players = value;
                    while (Settings.playerNames.length < Settings.players) {
                      Settings.playerNames.add(
                        "Player ${Settings.playerNames.length + 1}",
                      );
                    }
                    while (Settings.playerColors.length < Settings.players) {
                      Settings.playerColors.add(Colors.grey.shade300);
                    }
                    while (Settings.hasPartner.length < Settings.players) {
                      Settings.hasPartner.add(false);
                    }
                    Settings.save();
                    onUpdate();
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
                initialValue: Settings.startLife.toString(),
                decoration: const InputDecoration(
                  labelText: 'Starting Life',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.favorite_border),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))
                      ?.toInt();
                  if (parsedValue != null) {
                    Settings.startLife = parsedValue;
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
