import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  static int players = 4;
  static int startLife = 40;

  static List<Color> playerColors = [
    Colors.amber.shade200,
    Colors.blue.shade200,
    Colors.purple.shade200,
    Colors.red.shade200,
    Colors.green.shade200,
    Colors.grey.shade300,
  ];
  static List<Color> playerTextColors = [
    Colors.black87,
    Colors.black87,
    Colors.black87,
    Colors.black87,
    Colors.black87,
    Colors.black87,
  ];
  static List<Color> playerOutlineColors = [
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
  ];
  static List<bool> playerUseOutline = [
    false,
    false,
    false,
    false,
    false,
    false,
  ];
  static List<bool> hasPartner = [false, false, false, false, false, false];
  static List<String> playerImageUrls = ['', '', '', '', '', ''];
  static List<String> playerPartnerImageUrls = ['', '', '', '', '', ''];

  static bool useTimer = true;
  static double startTime = 1.0;
  static int increment = 5;
  static bool usePriority = true;
  static int prio = 3;

  static bool useSlowBurn = false;
  static double burnInterval = 1.5;
  static int burnAmount = 5;
  static bool useFlashing = true;

  static bool useCommanderDamage = true;
  static bool useCounters = true;

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
    prefs.setBool('usePriority', usePriority);
    prefs.setInt('prio', prio);
    prefs.setBool('useSlowBurn', useSlowBurn);
    prefs.setDouble('burnInterval', burnInterval);
    prefs.setInt('burnAmount', burnAmount);
    prefs.setBool('useFlashing', useFlashing);

    List<String> colorStrings = playerColors
        .map((c) => c.toARGB32().toString())
        .toList();
    List<String> textColorStrings = playerTextColors
        .map((c) => c.toARGB32().toString())
        .toList();
    List<String> outlineColorStrings = playerOutlineColors
        .map((c) => c.toARGB32().toString())
        .toList();

    prefs.setBool('useCommanderDamage', useCommanderDamage);
    prefs.setBool('useCounters', useCounters);
    prefs.setStringList('playerColors', colorStrings);
    prefs.setStringList('playerTextColors', textColorStrings);
    prefs.setStringList('playerOutlineColors', outlineColorStrings);

    List<String> useOutlineStrings = playerUseOutline
        .map((p) => p.toString())
        .toList();
    prefs.setStringList('playerUseOutline', useOutlineStrings);

    List<String> partnerStrings = hasPartner.map((p) => p.toString()).toList();
    prefs.setStringList('hasPartner', partnerStrings);
    prefs.setStringList('playerImageUrls', playerImageUrls);
    prefs.setStringList('playerPartnerImageUrls', playerPartnerImageUrls);
  }

  static void load() {
    players = prefs.getInt('players') ?? 4;
    startLife = prefs.getInt('startLife') ?? 40;
    useTimer = prefs.getBool('useTimer') ?? true;

    // Fixed: Casts to num? first to safely parse ints saved as doubles
    startTime = (prefs.get('startTime') as num?)?.toDouble() ?? 10.0;
    burnInterval = (prefs.get('burnInterval') as num?)?.toDouble() ?? 1.5;

    increment = prefs.getInt('increment') ?? 15;
    usePriority = prefs.getBool('usePriority') ?? true;
    prio = prefs.getInt('prio') ?? 3;
    useSlowBurn = prefs.getBool('useSlowBurn') ?? false;
    burnAmount = prefs.getInt('burnAmount') ?? 5;
    useFlashing = prefs.getBool('useFlashing') ?? true;
    useCommanderDamage = prefs.getBool('useCommanderDamage') ?? true;
    useCounters = prefs.getBool('useCounters') ?? true;

    List<Color> defaultColors = [
      Colors.amber.shade200,
      Colors.blue.shade200,
      Colors.purple.shade200,
      Colors.red.shade200,
      Colors.green.shade200,
      Colors.grey.shade300,
    ];

    List<String>? colors = prefs.getStringList('playerColors');
    if (colors != null && colors.isNotEmpty) {
      playerColors = colors.map((c) => Color(int.parse(c))).toList();
    } else {
      playerColors = [];
    }
    while (playerColors.length < players) {
      int index = playerColors.length;
      playerColors.add(
        index < defaultColors.length
            ? defaultColors[index]
            : Colors.grey.shade300,
      );
    }

    List<String>? textColors = prefs.getStringList('playerTextColors');
    if (textColors != null && textColors.isNotEmpty) {
      playerTextColors = textColors.map((c) => Color(int.parse(c))).toList();
    } else {
      playerTextColors = [];
    }
    while (playerTextColors.length < players) {
      playerTextColors.add(Colors.black87);
    }

    List<String>? outColors = prefs.getStringList('playerOutlineColors');
    if (outColors != null && outColors.isNotEmpty) {
      playerOutlineColors = outColors.map((c) => Color(int.parse(c))).toList();
    } else {
      playerOutlineColors = [];
    }
    while (playerOutlineColors.length < players) {
      playerOutlineColors.add(Colors.black);
    }

    List<String>? useOut = prefs.getStringList('playerUseOutline');
    if (useOut != null && useOut.isNotEmpty) {
      playerUseOutline = useOut.map((p) => p == 'true').toList();
    } else {
      playerUseOutline = [];
    }
    while (playerUseOutline.length < players) {
      playerUseOutline.add(false);
    }

    List<String>? partners = prefs.getStringList('hasPartner');
    if (partners != null && partners.isNotEmpty) {
      hasPartner = partners.map((p) => p == 'true').toList();
    } else {
      hasPartner = [];
    }
    while (hasPartner.length < players) {
      hasPartner.add(false);
    }

    List<String>? images = prefs.getStringList('playerImageUrls');
    if (images != null && images.isNotEmpty) {
      playerImageUrls = images;
    } else {
      playerImageUrls = [];
    }
    while (playerImageUrls.length < players) {
      playerImageUrls.add('');
    }

    List<String>? pImages = prefs.getStringList('playerPartnerImageUrls');
    if (pImages != null && pImages.isNotEmpty) {
      playerPartnerImageUrls = pImages;
    } else {
      playerPartnerImageUrls = [];
    }
    while (playerPartnerImageUrls.length < players) {
      playerPartnerImageUrls.add('');
    }
  }

  static List<Shadow> getOutlineShadows(Color color) {
    const double stroke = 2.0;
    return [
      Shadow(offset: const Offset(-stroke, -stroke), color: color),
      Shadow(offset: const Offset(stroke, -stroke), color: color),
      Shadow(offset: const Offset(stroke, stroke), color: color),
      Shadow(offset: const Offset(-stroke, stroke), color: color),
    ];
  }

  static String? get savedGame => prefs.getString('savedGame');
  static Future<void> saveGame(String json) =>
      prefs.setString('savedGame', json);
  static Future<void> clearSavedGame() => prefs.remove('savedGame');
}
