import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
    // player settings 
    static int players = 4;
    static int startLife = 40;
    
    // player customization
    static List<String> playerNames = ["Timmy", "Johnny", "Spike", "Vorthos"];
    static List<Color> playerColors = [
        Colors.blue.shade200,
        Colors.amber.shade200,
        Colors.purple.shade200,
        Colors.red.shade200,
    ];

    // timer settings
    static bool useTimer = true;
    static double startTime = 1.0;
    static int increment = 5;

    // slow burn
    static bool useSlowBurn = false;
    static int burnInterval = 30;
    static int burnAmount = 5;

    // "autosave"
    static late SharedPreferences prefs;

    static Future<void> init() async {
        prefs = await SharedPreferences.getInstance();
        load();
    }

    static void save() {
        prefs.setInt('players', players);
        prefs.setInt('startLife', startLife);
        prefs.setBool('useTimer', useTimer);
        prefs.setDouble('startTime', startTime);
        prefs.setInt('increment', increment);
        prefs.setBool('useSlowBurn', useSlowBurn);
        prefs.setInt('burnInterval', burnInterval);
        prefs.setInt('burnAmount', burnAmount);
        prefs.setStringList('playerNames', playerNames);
        List<String> colorStrings = playerColors.map((c) => c.value.toString()).toList();
        prefs.setStringList('playerColors', colorStrings);
    }

    static void load() {
        players = prefs.getInt('players') ?? 4;
        startLife = prefs.getInt('startLife') ?? 40;
        useTimer = prefs.getBool('useTimer') ?? true;
        startTime = prefs.getDouble('startTime') ?? 10.0;
        increment = prefs.getInt('increment') ?? 15;
        useSlowBurn = prefs.getBool('useSlowBurn') ?? false;
        burnInterval = prefs.getInt('burnInterval') ?? 30;
        burnAmount = prefs.getInt('burnAmount') ?? 5;
        
        List<String>? names = prefs.getStringList('playerNames');
        if (names != null && names.length >= players) {
            playerNames = names;
        } else {
            List<String> defaultNames = ["Timmy", "Johnny", "Spike", "Vorthos"];
            playerNames = List.generate(players, (i) => i < defaultNames.length ? defaultNames[i] : "Player ${i + 1}");
        }

        List<String>? colors = prefs.getStringList('playerColors');
        if (colors != null && colors.length >= players) {
            playerColors = colors.map((c) => Color(int.parse(c))).toList();
        } else {
            List<Color> defaultColors = [
                Colors.blue.shade200,
                Colors.amber.shade200,
                Colors.purple.shade200,
                Colors.red.shade200,
            ];
            playerColors = List.generate(players, (i) => i < defaultColors.length ? defaultColors[i] : Colors.grey.shade300);
        }
    }
}
