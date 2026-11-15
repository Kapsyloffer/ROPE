import 'package:cached_network_image/cached_network_image.dart';
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
  late HSVColor _outlineHsv;
  int _editingMode = 0;
  bool _useOutline = false;
  late String _imageUrl;

  static final List<Color> _presetBgColors = [
    Colors.grey.shade300,
    Colors.blue.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.amber.shade200,
    Colors.purple.shade200,
  ];

  static final List<Color> _presetTextColors = [Colors.black87, Colors.white];

  @override
  void initState() {
    super.initState();
    _imageUrl = Settings.playerImageUrls[widget.playerIndex];
    _bgHsv = HSVColor.fromColor(Settings.playerColors[widget.playerIndex]);
    _textHsv = HSVColor.fromColor(
      Settings.playerTextColors[widget.playerIndex],
    );
    _outlineHsv = HSVColor.fromColor(
      Settings.playerOutlineColors[widget.playerIndex],
    );
    _useOutline = Settings.playerUseOutline[widget.playerIndex];
    
    if (_imageUrl.isNotEmpty) {
      _editingMode = 1;
    }
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
    final currentColor = _editingMode == 1
        ? _textHsv.toColor()
        : (_editingMode == 2 ? _outlineHsv.toColor() : _bgHsv.toColor());
    final presets = _editingMode == 1 ? _presetTextColors : _presetBgColors;

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
                image: _imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(_imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: Center(
                child: Text(
                  '40',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: _textHsv.toColor(),
                    shadows: _useOutline
                        ? Settings.getOutlineShadows(_outlineHsv.toColor())
                        : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                if (_imageUrl.isNotEmpty)
                  ActionChip(
                    avatar: const Icon(Icons.clear, size: 16),
                    label: const Text('Clear image'),
                    onPressed: () {
                      setState(() {
                        _imageUrl = '';
                        _editingMode = 0;
                      });
                    },
                  )
                else
                  ChoiceChip(
                    label: const Text('Background'),
                    selected: _editingMode == 0,
                    onSelected: (val) => setState(() => _editingMode = 0),
                  ),
                ChoiceChip(
                  label: const Text('Text'),
                  selected: _editingMode == 1,
                  onSelected: (val) => setState(() => _editingMode = 1),
                ),
                ChoiceChip(
                  label: const Text('Outline'),
                  selected: _editingMode == 2,
                  onSelected: (val) => setState(() => _editingMode = 2),
                ),
              ],
            ),
            if (_editingMode == 2)
              SwitchListTile(
                title: const Text('Enable Outline'),
                value: _useOutline,
                onChanged: (val) {
                  setState(() {
                    _useOutline = val;
                  });
                },
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: presets.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_editingMode == 1) {
                        _textHsv = HSVColor.fromColor(color);
                      } else if (_editingMode == 2) {
                        _outlineHsv = HSVColor.fromColor(color);
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
            if (_editingMode != 2 || _useOutline) ...[
              _buildSlider(
                'H',
                _editingMode == 1
                    ? _textHsv.hue
                    : (_editingMode == 2 ? _outlineHsv.hue : _bgHsv.hue),
                0,
                360,
                (val) {
                  setState(() {
                    if (_editingMode == 1) {
                      _textHsv = _textHsv.withHue(val);
                    } else if (_editingMode == 2) {
                      _outlineHsv = _outlineHsv.withHue(val);
                    } else {
                      _bgHsv = _bgHsv.withHue(val);
                    }
                  });
                },
              ),
              _buildSlider(
                'S',
                _editingMode == 1
                    ? _textHsv.saturation
                    : (_editingMode == 2
                        ? _outlineHsv.saturation
                        : _bgHsv.saturation),
                0,
                1,
                (val) {
                  setState(() {
                    if (_editingMode == 1) {
                      _textHsv = _textHsv.withSaturation(val);
                    } else if (_editingMode == 2) {
                      _outlineHsv = _outlineHsv.withSaturation(val);
                    } else {
                      _bgHsv = _bgHsv.withSaturation(val);
                    }
                  });
                },
              ),
              _buildSlider(
                'V',
                _editingMode == 1
                    ? _textHsv.value
                    : (_editingMode == 2 ? _outlineHsv.value : _bgHsv.value),
                0,
                1,
                (val) {
                  setState(() {
                    if (_editingMode == 1) {
                      _textHsv = _textHsv.withValue(val);
                    } else if (_editingMode == 2) {
                      _outlineHsv = _outlineHsv.withValue(val);
                    } else {
                      _bgHsv = _bgHsv.withValue(val);
                    }
                  });
                },
              ),
            ],
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
            Settings.playerOutlineColors[widget.playerIndex] = _outlineHsv.toColor();
            Settings.playerUseOutline[widget.playerIndex] = _useOutline;
            Settings.playerImageUrls[widget.playerIndex] = _imageUrl;
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
