import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
    // player settings 
    static int players = 4;
    static int startLife = 20;
    
    // player customization
    static List<String> playerNames = ["Timmy", "Johnny", "Spike", "Vorthos"];
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
        prefs.setStringList('playerNames', playerNames);
        List<String> colorStrings = playerColors.map((c) => c.value.toString()).toList();
        prefs.setStringList('playerColors', colorStrings);
    }

    static void load() {
        players = prefs.getInt('players') ?? 4;
        startLife = prefs.getInt('startLife') ?? 20;
        useTimer = prefs.getBool('useTimer') ?? true;
        startTime = prefs.getDouble('startTime') ?? 1.0;
        increment = prefs.getInt('increment') ?? 5;
        
        List<String>? names = prefs.getStringList('playerNames');
        if (names != null && names.length >= players) {
            playerNames = names;
        } else {
            playerNames = List.generate(players, (i) => "Player ${i + 1}");
        }

        List<String>? colors = prefs.getStringList('playerColors');
        if (colors != null && colors.length >= players) {
            playerColors = colors.map((c) => Color(int.parse(c))).toList();
        } else {
            playerColors = List.generate(players, (i) => Colors.grey.shade300);
        }
    }
}
