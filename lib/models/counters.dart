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

class ToggleCounter extends Counter {
  bool enabled;
  ToggleCounter(this.enabled);
}

class PlayerCounters {
  Map<String, Counter> activeCounters = {
    'poison': LethalCounter(10),
    'energy': Counter(),
    'taxMain': Counter(),
    'taxPartner': Counter(),
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
      }
    }
  }
}
