import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ROPE/models/player.dart';
import 'package:ROPE/models/settings.dart';
import 'package:ROPE/UI/life_display.dart';
import 'package:ROPE/UI/timer_display.dart';
import 'package:ROPE/UI/counters_grid.dart';
import 'package:ROPE/UI/commander_damage_grid.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({
      'players': 4,
      'startLife': 40,
      'startTime': 10.0,
      'increment': 15,
      'useSlowBurn': false,
      'playerNames': ["Timmy", "Johnny", "Spike", "Vorthos"],
      'hasPartner': ['false', 'false', 'false', 'false'],
    });
    await Settings.init();
  });

  Widget wrapInMaterialApp(Widget child) {
    return MaterialApp(home: Scaffold(body: child));
  }

  group('LifeDisplay Widget Tests', () {
    testWidgets('Renders correct life and player name', (
      WidgetTester tester,
    ) async {
      final player = Player(0);
      player.curLife = 40;

      await tester.pumpWidget(
        wrapInMaterialApp(
          LifeDisplay(player: player, onLifeAdjust: (amount) {}),
        ),
      );

      expect(find.text('40'), findsOneWidget);
      expect(find.text('Timmy'), findsOneWidget);
    });

    testWidgets('Tapping +/- buttons fires onLifeAdjust callback', (
      WidgetTester tester,
    ) async {
      final player = Player(0);
      int adjustedAmount = 0;

      await tester.pumpWidget(
        wrapInMaterialApp(
          LifeDisplay(
            player: player,
            onLifeAdjust: (amount) {
              adjustedAmount = amount;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(adjustedAmount, -1);

      await tester.tap(find.byIcon(Icons.add));
      expect(adjustedAmount, 1);
    });
  });

  group('TimerDisplay Widget Tests', () {
    testWidgets('Correctly formats and displays time', (
      WidgetTester tester,
    ) async {
      final player = Player(0);
      player.timer.curTime = 65.0; // 1 minute 5 seconds

      await tester.pumpWidget(
        wrapInMaterialApp(
          TimerDisplay(
            player: player,
            onTimerTap: () {},
            onTimerLongPress: () {},
            onTimeAdjust: (amount) {},
          ),
        ),
      );

      expect(find.text('1:05'), findsOneWidget);
    });

    testWidgets('Tapping timer fires onTimerTap callback', (
      WidgetTester tester,
    ) async {
      final player = Player(0);
      bool tapFired = false;

      await tester.pumpWidget(
        wrapInMaterialApp(
          TimerDisplay(
            player: player,
            onTimerTap: () {
              tapFired = true;
            },
            onTimerLongPress: () {},
            onTimeAdjust: (amount) {},
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapFired, true);
    });
  });

  group('CountersGrid Widget Tests', () {
    testWidgets('Renders counters and fires onCounterAdjust', (
      WidgetTester tester,
    ) async {
      final player = Player(0);
      player.counters.activeCounters['poison']!.amount = 5;

      String? adjustedCounter;
      int? adjustedAmount;

      await tester.pumpWidget(
        wrapInMaterialApp(
          CountersGrid(
            player: player,
            isVisible: true,
            onCounterAdjust: (type, amount) {
              adjustedCounter = type;
              adjustedAmount = amount;
            },
          ),
        ),
      );

      expect(find.text('POISON'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.add).first);

      expect(adjustedCounter, 'poison');
      expect(adjustedAmount, 1);
    });
  });

  group('CommanderDamageGrid Widget Tests', () {
    testWidgets('Renders zero damage correctly for self', (
      WidgetTester tester,
    ) async {
      final player = Player(0); // Player 0 looking at Player 0's damage

      await tester.pumpWidget(
        wrapInMaterialApp(
          CommanderDamageGrid(
            player: player,
            rotations: 0,
            isVisible: true,
            onCommanderDamageAdjust: (target, index, amount) {},
          ),
        ),
      );

      expect(find.text('--'), findsOneWidget);
    });
  });
}
