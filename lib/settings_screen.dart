import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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
          Card(
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
                          setState(() {
                            Settings.players = value;
                            Settings.save();
                          });
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
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.timer),
                    title: const Text('Use Timer'),
                    value: Settings.useTimer,
                    onChanged: (value) {
                      setState(() {
                        Settings.useTimer = value;
                        Settings.save();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextFormField(
                      initialValue: Settings.startTime.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Start Time (minutes)',
                        border: OutlineInputBorder(),
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
          ),
          const SizedBox(height: 16),
          Card(
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
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade400),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: DropdownButton<Color>(
                              value: Settings.playerColors[index],
                              underline: const SizedBox(),
                              items: [
                                DropdownMenuItem(
                                  value: Colors.grey.shade300, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.grey.shade300), const SizedBox(width: 8), const Text('Grey')])
                                ),
                                DropdownMenuItem(
                                  value: Colors.blue.shade200, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.blue.shade200), const SizedBox(width: 8), const Text('Blue')])
                                ),
                                DropdownMenuItem(
                                  value: Colors.red.shade200, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.red.shade200), const SizedBox(width: 8), const Text('Red')])
                                ),
                                DropdownMenuItem(
                                  value: Colors.green.shade200, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.green.shade200), const SizedBox(width: 8), const Text('Green')])
                                ),
                                DropdownMenuItem(
                                  value: Colors.amber.shade200, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.amber.shade200), const SizedBox(width: 8), const Text('Yellow')])
                                ),
                                DropdownMenuItem(
                                  value: Colors.purple.shade200, 
                                  child: Row(children: [Container(width: 16, height: 16, color: Colors.purple.shade200), const SizedBox(width: 8), const Text('Purple')])
                                ),
                              ],
                              onChanged: (Color? newColor) {
                                if (newColor != null) {
                                  setState(() {
                                    Settings.playerColors[index] = newColor;
                                    Settings.save();
                                  });
                                }
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
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
