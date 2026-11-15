import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../models/settings.dart';
import '../../UI/outlined_text.dart';
import 'scryfall_search.dart';

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
  late String _partnerImageUrl;
  bool _isEditingPartnerArt = false;

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
    _partnerImageUrl = Settings.playerPartnerImageUrls[widget.playerIndex];
    _bgHsv = HSVColor.fromColor(Settings.playerColors[widget.playerIndex]);
    _textHsv = HSVColor.fromColor(
      Settings.playerTextColors[widget.playerIndex],
    );
    _outlineHsv = HSVColor.fromColor(
      Settings.playerOutlineColors[widget.playerIndex],
    );
    _useOutline = Settings.playerUseOutline[widget.playerIndex];
  }

  ImageProvider _getImageProvider(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImageProvider(path);
    } else {
      return FileImage(File(path));
    }
  }

  Future<void> _pickLocalImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      String finalImagePath = image.path;

      bool shouldCrop = true;
      if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
        shouldCrop = false;
      }

      if (shouldCrop) {
        try {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: image.path,
            aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 10),
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Crop Art',
                toolbarColor: Colors.deepPurple,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: true,
              ),
            ],
          );
          if (croppedFile != null) {
            finalImagePath = croppedFile.path;
          }
        } catch (e) {
          debugPrint("ImageCropper failed, falling back to original image: $e");
        }
      }

      setState(() {
        if (_isEditingPartnerArt) {
          _partnerImageUrl = finalImagePath;
        } else {
          _imageUrl = finalImagePath;
        }
      });
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
    bool hasPartnerActive = Settings.hasPartner[widget.playerIndex];
    bool currentHasImage = _isEditingPartnerArt ? _partnerImageUrl.isNotEmpty : _imageUrl.isNotEmpty;

    return AlertDialog(
      title: Text('Player ${widget.playerIndex + 1} Style'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: _bgHsv.toColor(),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_imageUrl.isNotEmpty)
                            Expanded(
                              child: Image(
                                image: _getImageProvider(_imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (hasPartnerActive && _partnerImageUrl.isNotEmpty)
                            Expanded(
                              child: Image(
                                image: _getImageProvider(_partnerImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      Center(
                        child: OutlinedText(
                          '40',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: _textHsv.toColor(),
                          ),
                          useOutline: _useOutline,
                          outlineColor: _outlineHsv.toColor(),
                          strokeWidth: 3.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
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
                ],
              ),
              const SizedBox(height: 16),
              
              if (_editingMode == 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _presetBgColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _bgHsv = HSVColor.fromColor(color);
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _bgHsv.toColor().toARGB32() == color.toARGB32()
                                ? Colors.black
                                : Colors.black26,
                            width: _bgHsv.toColor().toARGB32() == color.toARGB32()
                                ? 2.5
                                : 1.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildSlider('H', _bgHsv.hue, 0, 360, (val) => setState(() => _bgHsv = _bgHsv.withHue(val))),
                _buildSlider('S', _bgHsv.saturation, 0, 1, (val) => setState(() => _bgHsv = _bgHsv.withSaturation(val))),
                _buildSlider('V', _bgHsv.value, 0, 1, (val) => setState(() => _bgHsv = _bgHsv.withValue(val))),
                
                const Divider(height: 32),

                if (hasPartnerActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ChoiceChip(
                          label: const Text('Main Art'),
                          selected: !_isEditingPartnerArt,
                          onSelected: (val) =>
                              setState(() => _isEditingPartnerArt = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('Partner Art'),
                          selected: _isEditingPartnerArt,
                          onSelected: (val) =>
                              setState(() => _isEditingPartnerArt = true),
                        ),
                      ],
                    ),
                  ),
                
                if (currentHasImage) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextButton.icon(
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear Image'),
                      onPressed: () {
                        setState(() {
                          if (_isEditingPartnerArt) {
                            _partnerImageUrl = '';
                          } else {
                            _imageUrl = '';
                          }
                        });
                      },
                    ),
                  ),
                ] else ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Upload Local Image'),
                          onPressed: _pickLocalImage,
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.search),
                          label: const Text('Search on Scryfall'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ScryfallSearch(
                                onSelect: (url) {
                                  setState(() {
                                    if (_isEditingPartnerArt) {
                                      _partnerImageUrl = url;
                                    } else {
                                      _imageUrl = url;
                                    }
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],

              if (_editingMode == 1) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _presetTextColors.map((color) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _textHsv = HSVColor.fromColor(color);
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _textHsv.toColor().toARGB32() == color.toARGB32()
                                ? Colors.blue
                                : Colors.black26,
                            width: _textHsv.toColor().toARGB32() == color.toARGB32()
                                ? 2.5
                                : 1.0,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                _buildSlider('H', _textHsv.hue, 0, 360, (val) => setState(() => _textHsv = _textHsv.withHue(val))),
                _buildSlider('S', _textHsv.saturation, 0, 1, (val) => setState(() => _textHsv = _textHsv.withSaturation(val))),
                _buildSlider('V', _textHsv.value, 0, 1, (val) => setState(() => _textHsv = _textHsv.withValue(val))),
                
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Enable Outline'),
                  value: _useOutline,
                  onChanged: (val) {
                    setState(() {
                      _useOutline = val;
                    });
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                
                if (_useOutline) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _presetTextColors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _outlineHsv = HSVColor.fromColor(color);
                          });
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _outlineHsv.toColor().toARGB32() == color.toARGB32()
                                  ? Colors.blue
                                  : Colors.black26,
                              width: _outlineHsv.toColor().toARGB32() == color.toARGB32()
                                  ? 2.5
                                  : 1.0,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  _buildSlider('H', _outlineHsv.hue, 0, 360, (val) => setState(() => _outlineHsv = _outlineHsv.withHue(val))),
                  _buildSlider('S', _outlineHsv.saturation, 0, 1, (val) => setState(() => _outlineHsv = _outlineHsv.withSaturation(val))),
                  _buildSlider('V', _outlineHsv.value, 0, 1, (val) => setState(() => _outlineHsv = _outlineHsv.withValue(val))),
                ],
              ],
            ],
          ),
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
            Settings.playerPartnerImageUrls[widget.playerIndex] = _partnerImageUrl;
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
