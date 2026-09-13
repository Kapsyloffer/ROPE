import 'package:flutter/material.dart';
import 'settings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController presetController;

  @override
  void initState() {
    super.initState();
    String initialPreset = Settings.presetNames.isNotEmpty ? Settings.presetNames.first : "Default";
    presetController = TextEditingController(text: initialPreset);
  }

  @override
  void dispose() {
    presetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            title: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: presetController,
                    decoration: const InputDecoration(labelText: 'Preset Name'),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.arrow_drop_down),
                  onSelected: (String value) {
                    setState(() {
                      presetController.text = value;
                    });
                  },
                  itemBuilder: (BuildContext context) {
                    return Settings.presetNames.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  if (presetController.text.isNotEmpty) {
                    Settings.loadPreset(presetController.text);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loaded ${presetController.text}')));
                  }
                },
                child: const Text('Load Preset'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (presetController.text.isNotEmpty) {
                    Settings.savePreset(presetController.text);
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved ${presetController.text}')));
                  }
                },
                child: const Text('Save Preset'),
              ),
            ],
          ),
          const Divider(),
          ListTile(
            title: const Text('Players'),
            trailing: DropdownButton<int>(
              value: Settings.players,
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
                    Settings.isDirty = true;
                    Settings.save();
                  });
                }
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              initialValue: Settings.startLife.toString(),
              decoration: const InputDecoration(labelText: 'Starting Life'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                if (parsedValue != null) {
                  Settings.startLife = parsedValue;
                  Settings.isDirty = true;
                  Settings.save();
                }
              },
            ),
          ),
          SwitchListTile(
            title: const Text('Use Timer'),
            value: Settings.useTimer,
            onChanged: (value) {
              setState(() {
                Settings.useTimer = value;
                Settings.isDirty = true;
                Settings.save();
              });
            },
          ),
          ListTile(
            title: TextFormField(
              initialValue: Settings.startTime.toString(),
              decoration: const InputDecoration(labelText: 'Start Time (minutes)'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: Settings.useTimer,
              onChanged: (value) {
                double? parsedValue = double.tryParse(value);
                if (parsedValue != null) {
                  Settings.startTime = parsedValue;
                  Settings.isDirty = true;
                  Settings.save();
                }
              },
            ),
          ),
          ListTile(
            title: TextFormField(
              initialValue: Settings.increment.toString(),
              decoration: const InputDecoration(labelText: 'Increment (seconds)'),
              keyboardType: TextInputType.number,
              enabled: Settings.useTimer,
              onChanged: (value) {
                int? parsedValue = int.tryParse(value);
                if (parsedValue != null) {
                  Settings.increment = parsedValue;
                  Settings.isDirty = true;
                  Settings.save();
                }
              },
            ),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Text(
              'Player Customization',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...List.generate(Settings.players, (index) {
            return ListTile(
              title: TextFormField(
                initialValue: Settings.playerNames[index],
                decoration: InputDecoration(labelText: 'Player ${index + 1} Name'),
                onChanged: (value) {
                  Settings.playerNames[index] = value;
                  Settings.isDirty = true;
                  Settings.save();
                },
              ),
              trailing: DropdownButton<Color>(
                value: Settings.playerColors[index],
                items: [
                  DropdownMenuItem(value: Colors.grey.shade300, child: const Text('Grey')),
                  DropdownMenuItem(value: Colors.blue.shade200, child: const Text('Blue')),
                  DropdownMenuItem(value: Colors.red.shade200, child: const Text('Red')),
                  DropdownMenuItem(value: Colors.green.shade200, child: const Text('Green')),
                  DropdownMenuItem(value: Colors.amber.shade200, child: const Text('Yellow')),
                  DropdownMenuItem(value: Colors.purple.shade200, child: const Text('Purple')),
                ],
                onChanged: (Color? newColor) {
                  if (newColor != null) {
                    setState(() {
                      Settings.playerColors[index] = newColor;
                      Settings.isDirty = true;
                      Settings.save();
                    });
                  }
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
