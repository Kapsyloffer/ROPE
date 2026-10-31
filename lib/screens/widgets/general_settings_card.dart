import 'package:flutter/material.dart';

import '../../models/settings.dart';
import 'player_color_picker_dialog.dart';

class GeneralSettingsCard extends StatefulWidget {
  final VoidCallback onUpdate;

  const GeneralSettingsCard({super.key, required this.onUpdate});

  @override
  State<GeneralSettingsCard> createState() => _GeneralSettingsCardState();
}

class _GeneralSettingsCardState extends State<GeneralSettingsCard> {
  static final List<Color> _presetColors = [
    Colors.amber.shade200,
    Colors.blue.shade200,
    Colors.purple.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.grey.shade300,
  ];

  late TextEditingController _lifeController;

  @override
  void initState() {
    super.initState();
    _lifeController = TextEditingController(
      text: Settings.startLife.toString(),
    );
  }

  @override
  void dispose() {
    _lifeController.dispose();
    super.dispose();
  }

  void _setLife(int life) {
    setState(() {
      Settings.startLife = life;
      _lifeController.text = life.toString();
    });
    Settings.save();
    widget.onUpdate();
  }

  void _showColorPicker(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PlayerColorPickerDialog(
          playerIndex: index,
          onUpdate: widget.onUpdate,
        );
      },
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  Widget _buildPlayerTile(BuildContext context, int index) {
    final Color bgColor = Settings.playerColors[index];
    final Color fgColor = Settings.playerTextColors[index];

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _showColorPicker(context, index),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'P${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: fgColor,
                        ),
                      ),
                      Icon(Icons.palette_outlined, color: fgColor, size: 20),
                    ],
                  ),
                  if (Settings.useCommanderDamage)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Partner',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: fgColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: Settings.hasPartner[index],
                          onChanged: (value) {
                            setState(() {
                              Settings.hasPartner[index] = value;
                            });
                            Settings.save();
                            widget.onUpdate();
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget layoutPreview;

    if (Settings.players == 2) {
      layoutPreview = Column(
        children: [_buildPlayerTile(context, 0), _buildPlayerTile(context, 1)],
      );
    } else if (Settings.players == 3) {
      layoutPreview = Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildPlayerTile(context, 0),
                _buildPlayerTile(context, 1),
              ],
            ),
          ),
          _buildPlayerTile(context, 2),
        ],
      );
    } else if (Settings.players == 4) {
      layoutPreview = Column(
        children: [
          Expanded(
            child: Row(
              children: [
                _buildPlayerTile(context, 0),
                _buildPlayerTile(context, 1),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildPlayerTile(context, 3),
                _buildPlayerTile(context, 2),
              ],
            ),
          ),
        ],
      );
    } else {
      layoutPreview = Column(
        children: List.generate(
          Settings.players,
          (index) => _buildPlayerTile(context, index),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      while (Settings.playerColors.length < Settings.players) {
                        Settings.playerColors.add(Colors.grey.shade300);
                      }
                      while (Settings.playerTextColors.length <
                          Settings.players) {
                        Settings.playerTextColors.add(Colors.black87);
                      }
                      while (Settings.hasPartner.length < Settings.players) {
                        Settings.hasPartner.add(false);
                      }
                    });
                    Settings.save();
                    widget.onUpdate();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: SizedBox(height: 280, child: layoutPreview),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _lifeController,
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
                    setState(() {
                      Settings.startLife = parsedValue;
                    });
                    Settings.save();
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 4.0,
              ),
              child: Row(
                children: [20, 30, 40].map((int life) {
                  final bool isSelected = Settings.startLife == life;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: life == 20 ? 0.0 : 4.0,
                        right: life == 40 ? 0.0 : 4.0,
                      ),
                      child: InkWell(
                        onTap: () => _setLife(life),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primaryContainer
                                : null,
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey.shade400,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            life.toString(),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
