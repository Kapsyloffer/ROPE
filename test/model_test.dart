import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ROPE/models/player.dart';
import 'package:ROPE/models/game.dart';
import 'package:ROPE/models/settings.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'players': 4,
      'startLife': 40,
      'startTime': 10.0,
      'increment': 15,
      'useSlowBurn': false,
    });
    await Settings.init();
  });

  group('Player State & Elimination', () {
    test('Player dies when life reaches 0', () {
      final player = Player(0);
      expect(player.alive, true);

      player.decreaseLife(40); // Standard start life is 40

      expect(player.curLife, 0);
      expect(player.alive, false);
    });

    test('Player dies when receiving 10 poison counters', () {
      final player = Player(0);

      // Add 9 poison - should be alive
      player.counters.activeCounters['poison']!.amount = 9;
      player.alive = player.checkAlive();
      expect(player.alive, true);

      // Add 1 more poison (10 total) - should die
      player.counters.activeCounters['poison']!.amount = 10;
      player.alive = player.checkAlive();
      expect(player.alive, false);
    });

    test('Player dies when receiving 21 commander damage', () {
      final player = Player(0);

      // Take 20 damage from commander 1 (Player index 1, commander 0)
      player.commanderDamage.commanders[1].damageDealt[0] = 20;
      player.alive = player.checkAlive();
      expect(player.alive, true);

      // Take 1 more damage (21 total)
      player.commanderDamage.commanders[1].damageDealt[0] = 21;
      player.alive = player.checkAlive();
      expect(player.alive, false);
    });
  });

  group('Timer Logic', () {
    test('Timer adds increment on standard toggle off', () {
      final player = Player(0);
      double initialTime = player.timer.curTime;

      player.timer.toggleTimer(isInterrupt: false); // Turn on
      player.timer.toggleTimer(isInterrupt: false); // Turn off

      expect(player.timer.curTime, initialTime + Settings.increment);
    });

    test('Timer does NOT add increment on interrupted toggle off', () {
      final player = Player(0);
      double initialTime = player.timer.curTime;

      player.timer.toggleTimer(isInterrupt: false); // Turn on
      player.timer.toggleTimer(
        isInterrupt: true,
      ); // Turn off via interrupt release

      expect(player.timer.curTime, initialTime);
    });
  });

  group('Game Turn Flow & Interruptions', () {
    test('Game nextPlayer cycles correctly and skips dead players', () {
      final players = [Player(0), Player(1), Player(2)];
      final game = Game(players, 3, 0);

      expect(game.activePlayerIndex, 0);

      // Kill player 1
      players[1].decreaseLife(40);

      // Advance turn
      game.nextPlayer();

      // Should skip Player 1 and go straight to Player 2
      expect(game.activePlayerIndex, 2);

      // Advance again
      game.nextPlayer();

      // Should loop back to Player 0
      expect(game.activePlayerIndex, 0);
    });

    test('Game handles interruptions via turnStack correctly', () {
      final players = [Player(0), Player(1), Player(2)];
      final game = Game(players, 3, 0); // Player 0 is active

      // Player 2 interrupts Player 0
      game.interruptTurn(players[2]);

      expect(game.activePlayerIndex, 2);
      expect(game.turnStack.length, 1);
      expect(game.turnStack.first, 0); // Player 0 is waiting on the stack
      expect(players[0].isInterrupted, true);
      expect(
        players[2].timer.active,
        true,
      ); // Player 2's timer should be running

      // Player 2 finishes their interruption
      game.nextPlayer();

      // Control returns to Player 0
      expect(game.activePlayerIndex, 0);
      expect(game.turnStack.isEmpty, true);
      expect(players[0].isInterrupted, false);
      expect(players[0].timer.active, true); // Player 0's timer resumes
    });
  });
}
