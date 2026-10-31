import 'package:flutter/material.dart';

import '../../models/settings.dart';

class PlayerColorPickerDialog extends StatefulWidget {
  final int playerIndex;
  final VoidCallback onUpdate;

  const PlayerColorPickerDialog({
    super.key,
    required this.playerIndex,
    required this.onUpdate,
  });

  @override
  State<PlayerColorPickerDialog> createState() =>
      _PlayerColorPickerDialogState();
}

class _PlayerColorPickerDialogState extends State<PlayerColorPickerDialog> {
  late HSVColor _bgHsv;
  late HSVColor _textHsv;
  bool _isEditingText = false;

  static final List<Color> _presetBgColors = [
    Colors.grey.shade300,
    Colors.blue.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.amber.shade200,
    Colors.purple.shade200,
  ];

  static final List<Color> _presetTextColors = [
    Colors.black87,
    Colors.white,
    Colors.red.shade900,
    Colors.blue.shade900,
    Colors.green.shade900,
    Colors.purple.shade900,
  ];

  @override
  void initState() {
    super.initState();
    _bgHsv = HSVColor.fromColor(Settings.playerColors[widget.playerIndex]);
    _textHsv = HSVColor.fromColor(
      Settings.playerTextColors[widget.playerIndex],
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(width: 24, child: Text(label)),
        Expanded(
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentColor = _isEditingText ? _textHsv.toColor() : _bgHsv.toColor();
    final presets = _isEditingText ? _presetTextColors : _presetBgColors;

    return AlertDialog(
      title: Text('Player ${widget.playerIndex + 1} Color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 72,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _bgHsv.toColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black26),
              ),
              child: Center(
                child: Text(
                  '40',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _textHsv.toColor(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Background'),
                  selected: !_isEditingText,
                  onSelected: (val) => setState(() => _isEditingText = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Text'),
                  selected: _isEditingText,
                  onSelected: (val) => setState(() => _isEditingText = true),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: presets.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isEditingText) {
                        _textHsv = HSVColor.fromColor(color);
                      } else {
                        _bgHsv = HSVColor.fromColor(color);
                      }
                    });
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: currentColor.toARGB32() == color.toARGB32()
                            ? Colors.black
                            : Colors.black26,
                        width: currentColor.toARGB32() == color.toARGB32()
                            ? 2.5
                            : 1.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            _buildSlider(
              'H',
              _isEditingText ? _textHsv.hue : _bgHsv.hue,
              0,
              360,
              (val) {
                setState(() {
                  if (_isEditingText) {
                    _textHsv = _textHsv.withHue(val);
                  } else {
                    _bgHsv = _bgHsv.withHue(val);
                  }
                });
              },
            ),
            _buildSlider(
              'S',
              _isEditingText ? _textHsv.saturation : _bgHsv.saturation,
              0,
              1,
              (val) {
                setState(() {
                  if (_isEditingText) {
                    _textHsv = _textHsv.withSaturation(val);
                  } else {
                    _bgHsv = _bgHsv.withSaturation(val);
                  }
                });
              },
            ),
            _buildSlider(
              'V',
              _isEditingText ? _textHsv.value : _bgHsv.value,
              0,
              1,
              (val) {
                setState(() {
                  if (_isEditingText) {
                    _textHsv = _textHsv.withValue(val);
                  } else {
                    _bgHsv = _bgHsv.withValue(val);
                  }
                });
              },
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
            Settings.playerColors[widget.playerIndex] = _bgHsv.toColor();
            Settings.playerTextColors[widget.playerIndex] = _textHsv.toColor();
            Settings.save();
            widget.onUpdate();
            Navigator.of(context).pop();
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}
