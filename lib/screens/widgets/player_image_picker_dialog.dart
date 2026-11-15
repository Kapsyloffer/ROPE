import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/settings.dart';

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

class PlayerImagePickerDialog extends StatefulWidget {
  final int playerIndex;
  final VoidCallback onUpdate;

  const PlayerImagePickerDialog({
    super.key,
    required this.playerIndex,
    required this.onUpdate,
  });

  @override
  State<PlayerImagePickerDialog> createState() =>
      _PlayerImagePickerDialogState();
}

class _PlayerImagePickerDialogState extends State<PlayerImagePickerDialog> {
  late String _imageUrl;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _errorMessage = '';
  List<_CardArtOption> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _imageUrl = Settings.playerImageUrls[widget.playerIndex];
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Player ${widget.playerIndex + 1} Art'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 110,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Settings.playerColors[widget.playerIndex],
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
                    color: Settings.playerTextColors[widget.playerIndex],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
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
            if (_imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: TextButton.icon(
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Image'),
                  onPressed: () => setState(() => _imageUrl = ''),
                ),
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
                    final isSelected = _imageUrl == option.imageUrl;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _imageUrl = option.imageUrl;
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
