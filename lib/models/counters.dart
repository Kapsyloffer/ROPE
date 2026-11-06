class Counter {
  int amount;
  Counter() : amount = 0;
}

class LethalCounter extends Counter {
  int lethalAmount;
  LethalCounter(this.lethalAmount);

  bool isLethal() {
    if (amount < lethalAmount) {
      return false;
    }
    return true;
  }
}

class PairCounter extends Counter {
  List<int> amounts;
  PairCounter() : amounts = [0, 0];
}

class ToggleCounter extends Counter {
  bool enabled;
  ToggleCounter(this.enabled);
}

class PlayerCounters {
  Map<String, Counter> activeCounters = {
    'poison': LethalCounter(10),
    'energy': Counter(),
    'commanderTax': PairCounter(),
    'monarch': ToggleCounter(false),
  };

  bool isLethal() {
    for (var counter in activeCounters.values) {
      if (counter is LethalCounter && counter.isLethal()) {
        return true;
      }
    }
    return false;
  }

  void reset() {
    for (var counter in activeCounters.values) {
      counter.amount = 0;
      if (counter is ToggleCounter) {
        counter.enabled = false;
      } else if (counter is PairCounter) {
        counter.amounts = [0, 0];
      }
    }
  }
}
