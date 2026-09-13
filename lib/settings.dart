import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
    static bool isDirty = false;

    // player settings 
    static int players = 4;
    static int startLife = 20;
    
    // player customization
    static List<String> playerNames = ["Player 1", "Player 2", "Player 3", "Player 4"];
    static List<Color> playerColors = [
        Colors.grey.shade300,
        Colors.grey.shade300,
        Colors.grey.shade300,
        Colors.grey.shade300,
    ];

    // timer settings
    static bool useTimer = true;
    static double startTime = 1.0;
    static int increment = 5;

    static List<String> presetNames = ["Default"];

    // layout settings 
    // ...

    static late SharedPreferences _prefs;

    static Future<void> init() async {
        _prefs = await SharedPreferences.getInstance();
        load();
    }

    static void save() {
        _prefs.setInt('players', players);
        _prefs.setInt('startLife', startLife);
        _prefs.setBool('useTimer', useTimer);
        _prefs.setDouble('startTime', startTime);
        _prefs.setInt('increment', increment);
        _prefs.setStringList('playerNames', playerNames);
        List<String> colorStrings = playerColors.map((c) => c.value.toString()).toList();
        _prefs.setStringList('playerColors', colorStrings);
        _prefs.setStringList('presetNames', presetNames);
    }

    static void load() {
        players = _prefs.getInt('players') ?? 4;
        startLife = _prefs.getInt('startLife') ?? 20;
        useTimer = _prefs.getBool('useTimer') ?? true;
        startTime = _prefs.getDouble('startTime') ?? 1.0;
        increment = _prefs.getInt('increment') ?? 5;
        
        presetNames = _prefs.getStringList('presetNames') ?? ["Default"];

        List<String>? names = _prefs.getStringList('playerNames');
        if (names != null && names.length >= players) {
            playerNames = names;
        } else {
            playerNames = List.generate(players, (i) => "Player ${i + 1}");
        }

        List<String>? colors = _prefs.getStringList('playerColors');
        if (colors != null && colors.length >= players) {
            playerColors = colors.map((c) => Color(int.parse(c))).toList();
        } else {
            playerColors = List.generate(players, (i) => Colors.grey.shade300);
        }
    }
    
    static void savePreset(String presetName) {
        if (!presetNames.contains(presetName)) {
            presetNames.add(presetName);
        }
        _prefs.setInt('${presetName}_players', players);
        _prefs.setInt('${presetName}_startLife', startLife);
        _prefs.setBool('${presetName}_useTimer', useTimer);
        _prefs.setDouble('${presetName}_startTime', startTime);
        _prefs.setInt('${presetName}_increment', increment);
        save();
    }

    static void loadPreset(String presetName) {
        if (_prefs.containsKey('${presetName}_players')) {
            players = _prefs.getInt('${presetName}_players') ?? 4;
            startLife = _prefs.getInt('${presetName}_startLife') ?? 20;
            useTimer = _prefs.getBool('${presetName}_useTimer') ?? true;
            startTime = _prefs.getDouble('${presetName}_startTime') ?? 1.0;
            increment = _prefs.getInt('${presetName}_increment') ?? 5;
            
            if (playerNames.length < players) {
                playerNames.addAll(List.generate(players - playerNames.length, (i) => "Player ${playerNames.length + i + 1}"));
            }
            if (playerColors.length < players) {
                playerColors.addAll(List.generate(players - playerColors.length, (i) => Colors.grey.shade300));
            }
            
            isDirty = true;
            save();
        }
    }
}
