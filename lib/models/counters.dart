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

  Map<String, dynamic> toJson() => {
    'poison': activeCounters['poison']!.amount,
    'energy': activeCounters['energy']!.amount,
    'commanderTax': (activeCounters['commanderTax'] as PairCounter).amounts,
    'monarch': (activeCounters['monarch'] as ToggleCounter).enabled,
  };

  void loadFromJson(Map<String, dynamic> json) {
    activeCounters['poison']!.amount = json['poison'] as int? ?? 0;
    activeCounters['energy']!.amount = json['energy'] as int? ?? 0;
    var cTax = json['commanderTax'] as List?;
    if (cTax != null) {
      (activeCounters['commanderTax'] as PairCounter).amounts = cTax.cast<int>();
    }
    (activeCounters['monarch'] as ToggleCounter).enabled = json['monarch'] as bool? ?? false;
  }
}
