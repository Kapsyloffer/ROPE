import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/settings.dart';
import '../../UI/outlined_text.dart';

class _CardArtOption {
  final String name;
  final String setName;
  final String artist;
  final String imageUrl;

  _CardArtOption({
    required this.name,
    required this.setName,
    required this.artist,
    required this.imageUrl,
  });
}

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

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';
  List<_CardArtOption> _searchResults = [];

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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchCard() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _errorMessage = '';
    });

    try {
      final uri = Uri.parse(
        'https://api.scryfall.com/cards/search?q=${Uri.encodeQueryComponent(query)}&unique=art',
      );
      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'ROPE/1.0',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['data'] != null) {
        List<_CardArtOption> results = [];
        for (var card in data['data']) {
          String cardName = card['name'] ?? '';
          String setName = card['set_name'] ?? '';
          String artist = card['artist'] ?? '';

          if (card['image_uris'] != null &&
              card['image_uris']['art_crop'] != null) {
            results.add(
              _CardArtOption(
                name: cardName,
                setName: setName,
                artist: artist,
                imageUrl: card['image_uris']['art_crop'],
              ),
            );
          } else if (card['card_faces'] != null) {
            for (var face in card['card_faces']) {
              if (face['image_uris'] != null &&
                  face['image_uris']['art_crop'] != null) {
                results.add(
                  _CardArtOption(
                    name: face['name'] ?? cardName,
                    setName: setName,
                    artist: face['artist'] ?? artist,
                    imageUrl: face['image_uris']['art_crop'],
                  ),
                );
              }
            }
          }
        }

        setState(() {
          _searchResults = results;
          if (results.isEmpty) {
            _errorMessage = 'No art found for this card.';
          }
        });
      } else {
        setState(() {
          _searchResults = [];
          _errorMessage = data['details'] ?? 'Card not found.';
        });
      }
    } catch (e) {
      setState(() {
        _searchResults = [];
        _errorMessage = 'An error occurred while searching.';
      });
    }

    setState(() => _isSearching = false);
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

    return AlertDialog(
      title: Text('Player ${widget.playerIndex + 1} Style'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 110,
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
                              image: CachedNetworkImageProvider(_imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        if (hasPartnerActive && _partnerImageUrl.isNotEmpty)
                          Expanded(
                            child: Image(
                              image: CachedNetworkImageProvider(_partnerImageUrl),
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
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Scryfall Search',
                    hintText: 'e.g. Sol Ring',
                    suffixIcon: _isSearching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: _searchCard,
                          ),
                  ),
                  onSubmitted: (_) => _searchCard(),
                ),
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 260,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final option = _searchResults[index];
                        String currentSelectionUrl =
                            _isEditingPartnerArt ? _partnerImageUrl : _imageUrl;
                        final isSelected = currentSelectionUrl == option.imageUrl;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_isEditingPartnerArt) {
                                _partnerImageUrl = option.imageUrl;
                              } else {
                                _imageUrl = option.imageUrl;
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.black26,
                                width: isSelected ? 3.0 : 1.0,
                              ),
                              image: DecorationImage(
                                image: CachedNetworkImageProvider(option.imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                color: Colors.black.withValues(alpha: 0.65),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 4,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      option.setName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if ((_isEditingPartnerArt && _partnerImageUrl.isNotEmpty) ||
                    (!_isEditingPartnerArt && _imageUrl.isNotEmpty))
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
