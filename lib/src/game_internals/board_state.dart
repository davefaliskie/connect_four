
import 'package:flutter/material.dart';
import 'package:game_template/src/game_internals/board_setting.dart';
import 'package:game_template/src/game_internals/tile.dart';

class BoardState extends ChangeNotifier {
  final BoardSetting boardSetting;
  final List<Tile> playerTaken = [];
  final List<Tile> aiTaken = [];

  BoardState({required this.boardSetting});

  void makeMove(Tile tile) {
    playerTaken.add(tile);
    notifyListeners();
  }

}