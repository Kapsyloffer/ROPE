import 'package:flutter/material.dart';

import '../../models/settings.dart';

class PlayerColorOption {
  final Color color;
  final String name;

  const PlayerColorOption(this.color, this.name);
}

class PlayerCustomizationCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const PlayerCustomizationCard({super.key, required this.onUpdate});

  static final List<PlayerColorOption> _colorOptions = [
    PlayerColorOption(Colors.grey.shade300, 'Grey'),
    PlayerColorOption(Colors.blue.shade200, 'Blue'),
    PlayerColorOption(Colors.red.shade200, 'Red'),
    PlayerColorOption(Colors.green.shade200, 'Green'),
    PlayerColorOption(Colors.amber.shade200, 'Yellow'),
    PlayerColorOption(Colors.purple.shade200, 'Purple'),
  ];

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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Player Customization',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ...List.generate(Settings.players, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          child: DropdownButton<Color>(
                            value: Settings.playerColors[index],
                            underline: const SizedBox(),
                            items: _colorOptions.map((option) {
                              return DropdownMenuItem<Color>(
                                value: option.color,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: option.color,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(option.name),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (Color? newColor) {
                              if (newColor != null) {
                                Settings.playerColors[index] = newColor;
                                Settings.save();
                                onUpdate();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: Settings.playerNames[index],
                            decoration: InputDecoration(
                              labelText: 'Player ${index + 1} Name',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              Settings.playerNames[index] = value;
                              Settings.save();
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Partner'),
                            Switch(
                              value: Settings.hasPartner[index],
                              onChanged: (value) {
                                Settings.hasPartner[index] = value;
                                Settings.save();
                                onUpdate();
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
