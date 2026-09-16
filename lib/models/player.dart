import 'timer.dart';
import 'settings.dart';
import 'commander.dart';
import 'counters.dart';

class Player {
  int order;
  bool activePlayer;

  int curLife;
  int startLife;
  bool alive;

  Timer timer;
  late CommanderDamage commanderDamage;
  late PlayerCounters counters;

  Player(this.order)
    : activePlayer = false,
      curLife = Settings.startLife,
      startLife = Settings.startLife,
      alive = true,
      timer = Timer() {
    commanderDamage = CommanderDamage(Settings.players);
    counters = PlayerCounters();
  }

  void reset() {
    curLife = startLife;
    alive = true;
    timer.reset();
    commanderDamage = CommanderDamage(Settings.players);
    counters.reset();
  }

  void addLife(int amount) {
    curLife += amount;
    alive = checkAlive();
  }

  void decreaseLife(int amount) {
    curLife -= amount;
    alive = checkAlive();
  }

  bool checkAlive() {
    if (curLife <= 0) {
      return false;
    }
    if (timer.curTime <= 0) {
      return false;
    }
    if (commanderDamage.isLethal()) {
      return false;
    }
    if (counters.isLethal()) {
      return false;
    }

    return true;
  }
}
