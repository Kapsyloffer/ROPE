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
  bool isInterrupted = false;
  bool isPriority = false;
  bool isInterrupting = false;
  int queuePosition = 0;

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
    isInterrupted = false;
    isPriority = false;
    isInterrupting = false;
    queuePosition = 0;
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

  Map<String, dynamic> toJson() => {
    'order': order,
    'curLife': curLife,
    'alive': alive,
    'isInterrupted': isInterrupted,
    'isPriority': isPriority,
    'isInterrupting': isInterrupting,
    'queuePosition': queuePosition,
    'timer': timer.toJson(),
    'commanderDamage': commanderDamage.toJson(),
    'counters': counters.toJson(),
  };

  void loadFromJson(Map<String, dynamic> json) {
    curLife = json['curLife'];
    alive = json['alive'];
    isInterrupted = json['isInterrupted'] ?? false;
    isPriority = json['isPriority'] ?? false;
    isInterrupting = json['isInterrupting'] ?? false;
    queuePosition = json['queuePosition'] ?? 0;
    timer.loadFromJson(json['timer']);
    commanderDamage.loadFromJson(json['commanderDamage']);
    counters.loadFromJson(json['counters']);
  }
}
