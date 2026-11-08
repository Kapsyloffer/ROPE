import 'package:flutter/material.dart';

class PlayerLayout {
  static Widget build({
    required int playerCount,
    required Widget Function(int index) builder,
    Widget? centerMenu,
  }) {
    Widget buildRow(List<int> indices) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: indices.map((i) => Expanded(child: builder(i))).toList(),
      );
    }

    List<Widget> children = [];

    if (playerCount == 2) {
      children = [
        Expanded(child: builder(0)),
        if (centerMenu != null) centerMenu,
        Expanded(child: builder(1)),
      ];
    } else if (playerCount == 3) {
      children = [
        Expanded(child: buildRow([0, 1])),
        if (centerMenu != null) centerMenu,
        Expanded(child: builder(2)),
      ];
    } else if (playerCount == 4) {
      children = [
        Expanded(child: buildRow([0, 1])),
        if (centerMenu != null) centerMenu,
        Expanded(child: buildRow([3, 2])),
      ];
    } else if (playerCount == 5) {
      children = [
        Expanded(child: buildRow([0, 1])),
        Expanded(child: buildRow([4, 2])),
        if (centerMenu != null) centerMenu,
        Expanded(child: buildRow([3]))
      ];
    } else if (playerCount == 6) {
      children = [
        Expanded(child: buildRow([0, 1])),
        Expanded(child: buildRow([5, 2])),
        if (centerMenu != null) centerMenu,
        Expanded(child: buildRow([4, 3]))
      ];
    } else {
      children = List.generate(
        playerCount,
        (index) => Expanded(child: builder(index)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  static int getRotation(int playerCount, int index) {
    if (playerCount == 2) {
      return index == 0 ? 2 : 0;
    } else if (playerCount == 3) {
      if (index == 0) return 1; // Left
      if (index == 1) return 3; // Right
      return 0; // Bottom Center
    } else if (playerCount == 4) {
      if (index == 0) return 1; // Top Left
      if (index == 1) return 3; // Top Right
      if (index == 2) return 3; // Bottom Right
      if (index == 3) return 1; // Bottom Left
    } else if (playerCount == 5) {
      if (index == 0) return 1; // Top Left
      if (index == 1) return 3; // Top Right
      if (index == 2) return 3; // Bottom Right
      if (index == 3) return 0; // Bottom Center
      if (index == 4) return 1; // Bottom Left
    } else if (playerCount == 6) {
      if (index == 0) return 1; // Top Left
      if (index == 1) return 3; // Top Right
      if (index == 2) return 3; // Center Right
      if (index == 3) return 3; // Bottom Right 
      if (index == 4) return 1; // Bottom Left
      if (index == 5) return 1; // Center Left
    }
    return 0;
  }
}
