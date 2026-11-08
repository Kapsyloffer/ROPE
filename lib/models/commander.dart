class Commander {
  int playerId;
  List<int> damageDealt;
  
  Commander(this.playerId) : damageDealt = [0, 0];

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'damageDealt': damageDealt,
  };

  Commander.fromJson(Map<String, dynamic> json)
      : playerId = json['playerId'],
        damageDealt = (json['damageDealt'] as List).cast<int>();
}

class CommanderDamage {
  List<Commander> commanders = [];
  int numPlayers;

  CommanderDamage(this.numPlayers) {
    for (int i = 0; i < numPlayers; i++) {
      commanders.add(Commander(i));
    }
  }

  bool isLethal() {
    for (int i = 0; i < numPlayers; i++) {
      if (commanders[i].damageDealt[0] >= 21 ||
          commanders[i].damageDealt[1] >= 21) {
        return true;
      }
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
    'numPlayers': numPlayers,
    'commanders': commanders.map((c) => c.toJson()).toList(),
  };

  void loadFromJson(Map<String, dynamic> json) {
    numPlayers = json['numPlayers'];
    var cmds = json['commanders'] as List;
    commanders = cmds.map((c) => Commander.fromJson(c as Map<String, dynamic>)).toList();
  }
}
