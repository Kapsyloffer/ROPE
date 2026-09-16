class Commander {
  int playerId;
  int damageDealt;
  Commander(this.playerId) : damageDealt = 0;
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
      if (commanders[i].damageDealt >= 21) {
        return true;
      }
    }
    return false;
  }
}
