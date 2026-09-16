import 'package:flutter/material.dart';
import 'settings.dart';

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
      appBar: AppBar(
        title: const Text('Game Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _GeneralSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 16),
          _TimerSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 16),
          _SlowBurnSettingsCard(onUpdate: _refreshSettings),
          const SizedBox(height: 16),
          _PlayerCustomizationCard(onUpdate: _refreshSettings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _GeneralSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const _GeneralSettingsCard({required this.onUpdate});

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
                    Settings.save();
                    onUpdate();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                initialValue: Settings.startLife.toString(),
                decoration: const InputDecoration(
                  labelText: 'Starting Life',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.favorite_border),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))?.toInt();
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

class _TimerSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const _TimerSettingsCard({required this.onUpdate});

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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: TextFormField(
                initialValue: Settings.startTime.toString(),
                decoration: const InputDecoration(
                  labelText: 'Start Time (minutes)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: Settings.useTimer,
                onChanged: (value) {
                  double? parsedValue = num.tryParse(value.replaceAll(',', '.'))?.toDouble();
                  if (parsedValue != null) {
                    Settings.startTime = parsedValue;
                    Settings.save();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))?.toInt();
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

class _SlowBurnSettingsCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const _SlowBurnSettingsCard({required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: Settings.useTimer ? 1.0 : 0.5,
      child: IgnorePointer(
        ignoring: !Settings.useTimer,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.whatshot),
                  title: const Text('Slow Burn'),
                  value: Settings.useSlowBurn,
                  onChanged: (value) {
                    Settings.useSlowBurn = value;
                    Settings.save();
                    onUpdate();
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextFormField(
                    initialValue: Settings.burnInterval.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Burn Interval (seconds)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timelapse),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      int? parsedValue = num.tryParse(value.replaceAll(',', '.'))?.toInt();
                      if (parsedValue != null) {
                        Settings.burnInterval = parsedValue;
                        Settings.save();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: TextFormField(
                    initialValue: Settings.burnAmount.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Burn Damage',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.heart_broken),
                    ),
                    keyboardType: TextInputType.number,
                    enabled: Settings.useSlowBurn,
                    onChanged: (value) {
                      int? parsedValue = num.tryParse(value.replaceAll(',', '.'))?.toInt();
                      if (parsedValue != null) {
                        Settings.burnAmount = parsedValue;
                        Settings.save();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerColorOption {
  final Color color;
  final String name;

  const _PlayerColorOption(this.color, this.name);
}

class _PlayerCustomizationCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const _PlayerCustomizationCard({required this.onUpdate});

  static final List<_PlayerColorOption> _colorOptions = [
    _PlayerColorOption(Colors.grey.shade300, 'Grey'),
    _PlayerColorOption(Colors.blue.shade200, 'Blue'),
    _PlayerColorOption(Colors.red.shade200, 'Red'),
    _PlayerColorOption(Colors.green.shade200, 'Green'),
    _PlayerColorOption(Colors.amber.shade200, 'Yellow'),
    _PlayerColorOption(Colors.purple.shade200, 'Purple'),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Icon(Icons.person, color: Settings.playerColors[index]),
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
                                Container(width: 16, height: 16, color: option.color),
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
