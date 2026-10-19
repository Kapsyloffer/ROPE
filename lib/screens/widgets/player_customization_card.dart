import 'package:flutter/material.dart';

import '../../models/settings.dart';

class PlayerCustomizationCard extends StatelessWidget {
  final VoidCallback onUpdate;

  const PlayerCustomizationCard({super.key, required this.onUpdate});

  static final List<Color> _presetColors = [
    Colors.grey.shade300,
    Colors.blue.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.amber.shade200,
    Colors.purple.shade200,
  ];

  void _showColorPicker(BuildContext context, int index) {
    HSVColor currentHsv = HSVColor.fromColor(Settings.playerColors[index]);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Color currentColor = currentHsv.toColor();
            return AlertDialog(
              title: Text('Player ${index + 1} Color'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: currentColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              currentHsv = HSVColor.fromColor(color);
                            });
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    currentColor.toARGB32() == color.toARGB32()
                                    ? Colors.black
                                    : Colors.black26,
                                width:
                                    currentColor.toARGB32() == color.toARGB32()
                                    ? 2.5
                                    : 1.0,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 24, child: Text('H')),
                        Expanded(
                          child: Slider(
                            value: currentHsv.hue,
                            min: 0,
                            max: 360,
                            onChanged: (val) {
                              setDialogState(() {
                                currentHsv = currentHsv.withHue(val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 24, child: Text('S')),
                        Expanded(
                          child: Slider(
                            value: currentHsv.saturation,
                            min: 0,
                            max: 1,
                            onChanged: (val) {
                              setDialogState(() {
                                currentHsv = currentHsv.withSaturation(val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(width: 24, child: Text('V')),
                        Expanded(
                          child: Slider(
                            value: currentHsv.value,
                            min: 0,
                            max: 1,
                            onChanged: (val) {
                              setDialogState(() {
                                currentHsv = currentHsv.withValue(val);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Settings.playerColors[index] = currentHsv.toColor();
                    Settings.save();
                    onUpdate();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Select'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPlayerTile(BuildContext context, int index) {
    final Color bgColor = Settings.playerColors[index];
    final bool isDark =
        ThemeData.estimateBrightnessForColor(bgColor) == Brightness.dark;
    final Color fgColor = isDark ? Colors.white : Colors.black87;

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
                          Settings.hasPartner[index] = value;
                          Settings.save();
                          onUpdate();
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
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Player Customization',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: SizedBox(height: 280, child: layoutPreview),
            ),
          ],
        ),
      ),
    );
  }
}
