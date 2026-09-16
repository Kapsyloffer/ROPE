class Commander {
  int playerId;
  List<int> damageDealt;
  Commander(this.playerId) : damageDealt = [0, 0];
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
}
