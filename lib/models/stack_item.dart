enum TurnType { normal, interrupt, priority }

class StackItem {
  final int playerId;
  final TurnType returnType;
  final bool isFresh;

  StackItem(this.playerId, this.returnType, {this.isFresh = false});

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'returnType': returnType.index,
    'isFresh': isFresh,
  };

  StackItem.fromJson(Map<String, dynamic> json)
    : playerId = json['playerId'],
      returnType = TurnType.values[json['returnType']],
      isFresh = json['isFresh'] ?? false;
}

