import 'package:flutter/material.dart';

import '../../models/settings.dart';

String _formatMMSS(double minutes) {
  int m = minutes.floor();
  int s = ((minutes - m) * 60).round();
  if (s == 60) {
    m += 1;
    s = 0;
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

double? _parseMMSS(String value) {
  if (value.contains(':')) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      double? m = double.tryParse(parts[0]);
      double? s = double.tryParse(parts[1]);
      if (m != null && s != null) {
        return m + (s / 60.0);
      }
    }
  }
  return num.tryParse(value.replaceAll(',', '.'))?.toDouble();
}

class TimerSettingsCard extends StatefulWidget {
  final VoidCallback onUpdate;

  const TimerSettingsCard({super.key, required this.onUpdate});

  @override
  State<TimerSettingsCard> createState() => _TimerSettingsCardState();
}

class _TimerSettingsCardState extends State<TimerSettingsCard> {
  late TextEditingController _timeController;
  late FocusNode _timeFocusNode;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController(
      text: _formatMMSS(Settings.startTime),
    );
    _timeFocusNode = FocusNode();
    _timeFocusNode.addListener(_onTimeFocusChanged);
  }

  @override
  void dispose() {
    _timeFocusNode.removeListener(_onTimeFocusChanged);
    _timeFocusNode.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _onTimeFocusChanged() {
    if (!_timeFocusNode.hasFocus) {
      double? parsedValue = _parseMMSS(_timeController.text);
      if (parsedValue != null) {
        setState(() {
          _timeController.text = _formatMMSS(parsedValue);
        });
      }
    }
  }

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
                setState(() {
                  Settings.useTimer = value;
                });
                Settings.save();
                widget.onUpdate();
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                controller: _timeController,
                focusNode: _timeFocusNode,
                decoration: const InputDecoration(
                  labelText: 'Start Time (MM:SS)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.timer_outlined),
                ),
                keyboardType: TextInputType.datetime,
                enabled: Settings.useTimer,
                onChanged: (value) {
                  double? parsedValue = _parseMMSS(value);
                  if (parsedValue != null) {
                    Settings.startTime = parsedValue;
                    Settings.save();
                  }
                },
                onEditingComplete: () {
                  _timeFocusNode.unfocus();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
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
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))
                      ?.toInt();
                  if (parsedValue != null) {
                    Settings.increment = parsedValue;
                    Settings.save();
                  }
                },
              ),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.playlist_add_check),
              title: const Text('Use Priority Passing'),
              value: Settings.usePriority,
              onChanged: Settings.useTimer
                  ? (value) {
                      setState(() {
                        Settings.usePriority = value;
                      });
                      Settings.save();
                      widget.onUpdate();
                    }
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: TextFormField(
                initialValue: Settings.prio.toString(),
                decoration: const InputDecoration(
                  labelText: 'Priority Increment (seconds)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.rotate_right),
                ),
                keyboardType: TextInputType.number,
                enabled: Settings.useTimer && Settings.usePriority,
                onChanged: (value) {
                  int? parsedValue = num.tryParse(value.replaceAll(',', '.'))
                      ?.toInt();
                  if (parsedValue != null) {
                    Settings.prio = parsedValue;
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
