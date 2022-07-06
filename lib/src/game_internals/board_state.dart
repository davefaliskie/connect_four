
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:game_template/src/game_internals/board_setting.dart';
import 'package:game_template/src/game_internals/tile.dart';

import '../style/palette.dart';

enum TileOwner {
  blank,
  player,
  ai
}

class BoardState extends ChangeNotifier {
  final BoardSetting boardSetting;
  final List<Tile> playerTaken = [];
  final List<Tile> aiTaken = [];
  List<Tile> winTiles = [];

  final ChangeNotifier playerWon = ChangeNotifier();

  String noticeMessage = "";
  bool _isLocked = false;

  BoardState({required this.boardSetting});

  void clearBoard() {
    playerTaken.clear();
    aiTaken.clear();
    winTiles.clear();
    noticeMessage = "";
    _isLocked = false;
    notifyListeners();
  }

  Color tileColor(Tile tile) {
    if (winTiles.contains(tile)) {
      return Colors.green;
    } else if (getTileOwner(tile) == TileOwner.player) {
      return Colors.amber;
    } else if (getTileOwner(tile) == TileOwner.ai) {
      return Colors.redAccent;
    } else {
      return Palette().backgroundPlaySession;
    }
  }

  Future<void> makeMove(Tile tile) async {
    assert(!_isLocked);
    Tile? newTile = evaluateMove(tile);
    if (newTile == null) {
      noticeMessage = "Move not possible, try again";
      notifyListeners();
      return;
    }
    playerTaken.add(newTile);
    _isLocked = true;

    bool didPlayerWin = checkWin(newTile);
    if (didPlayerWin == true) {
      playerWon.notifyListeners();
      notifyListeners();
      return;
    }
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 500));

    // make the AI move
    Tile? aiTile = makeAiMove();
    if (aiTile == null) {
      noticeMessage = "No moves left, reset to play again";
      notifyListeners();
      return;
    }
    aiTaken.add(aiTile);
    bool didAiWin = checkWin(aiTile);
    if (didAiWin == true) {
      noticeMessage = "You lost, reset to play again";
      notifyListeners();
      return;
    }

    _isLocked = false;
    notifyListeners();
  }

  Tile? evaluateMove(Tile tile) {
    for (var bRow = 1; bRow < boardSetting.rows + 1; bRow++) {
      var evalTile = Tile(col: tile.col, row: bRow);
      if (getTileOwner(evalTile) == TileOwner.blank) {
        return evalTile;
      }
    }
    return null;
  }

  Tile? makeAiMove() {
    List<Tile> available = [];
    for (var row = 1; row < boardSetting.rows + 1; row++) {
      for (var col = 1; col < boardSetting.cols + 1; col++) {
        Tile tile = Tile(col: col, row: row);
        if (getTileOwner(tile) == TileOwner.blank) {
          available.add(tile);
        }
      }
    }

    if (available.isEmpty) { return null; }

    Tile aiTile = evaluateMove(available[Random().nextInt(available.length)])!;
    return aiTile;
  }

  TileOwner getTileOwner(Tile tile) {
    if (playerTaken.contains(tile)) {
      return TileOwner.player;
    } else if (aiTaken.contains(tile)) {
      return TileOwner.ai;
    } else {
      return TileOwner.blank;
    }
  }

  bool checkWin(Tile playTile) {
    var takenTiles = (getTileOwner(playTile) == TileOwner.player) ? playerTaken : aiTaken;

    List<Tile>? vertical = verticalCheck(playTile, takenTiles);
    if (vertical != null) {
      winTiles = vertical;
      return true;
    }

    List<Tile>? horizontal = horizontalCheck(playTile, takenTiles);
    if (horizontal != null) {
      winTiles = horizontal;
      return true;
    }

    List<Tile>? forwardDiagonal = forwardDiagonalCheck(playTile, takenTiles);
    if (forwardDiagonal != null) {
      winTiles = forwardDiagonal;
      return true;
    }

    List<Tile>? backDiagonal = backDiagonalCheck(playTile, takenTiles);
    if (backDiagonal != null) {
      winTiles = backDiagonal;
      return true;
    }

    return false;
  }

  List<Tile>? verticalCheck(Tile playTile, List<Tile> takenTiles) {
    List<Tile> tempWinTiles = [];

    for (var row = playTile.row; row > 0; row--) {
      Tile tile = Tile(col: playTile.col, row: row);
      if (takenTiles.contains(tile)) {
        tempWinTiles.add(tile);
      } else {
        break;
      }
    }

    if (tempWinTiles.length >= boardSetting.winCondition()) {
      return tempWinTiles;
    }

    return null;
  }

  List<Tile>? horizontalCheck(Tile playTile, List<Tile> takenTiles) {
    // add the play tile to the list
    List<Tile> tempWinTiles = [playTile];

    // Look left, unless playTile is the first tile.
    // Start at playTile.col - 1
    if (playTile.col > 1) {
      for (var col = playTile.col - 1; col > 0; col--) {
        Tile tile = Tile(col: col, row: playTile.row);

        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // Look right, unless playTile is the last tile.
    // Start at playTile.col + 1
    if (playTile.col < boardSetting.cols) {
      for (var col = playTile.col + 1; col < boardSetting.cols + 1; col++) {
        Tile tile = Tile(col: col, row: playTile.row);

        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // see if tempWinTiles meets the win condition, if so it's a win
    if (tempWinTiles.length >= boardSetting.winCondition()) {
      return tempWinTiles;
    }

    return null;
  }

  List<Tile>? forwardDiagonalCheck(Tile playTile, List<Tile> takenTiles) {
    // add the play tile to the list
    List<Tile> tempWinTiles = [playTile];

    // Look left & down, unless playTile is the first tile or in row 1.
    // Start at playTile.col - 1
    if (playTile.col > 1 && playTile.row > 1) {
      // iterate to check all lower rows
      for (var i = 1; i < playTile.row + 1; i++) {
        Tile tile = Tile(col: playTile.col - i, row: playTile.row - i);

        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // Look right & up, unless playTile is the last tile or in top row.
    // Start at playTile.col - 1
    if (playTile.col < boardSetting.cols && playTile.row < boardSetting.rows) {
      // iterate to check all upper rows. loop until hitting the top.
      // so from (top - playTile.row) times.
      for (var i = 1; i < (boardSetting.rows + 1) - playTile.row; i++) {
        Tile tile = Tile(col: playTile.col + i, row: playTile.row + i);
        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // see if tempWinTiles meets the win condition, if so it's a win
    if (tempWinTiles.length >= boardSetting.winCondition()) {
      return tempWinTiles;
    }

    return null;
  }

  List<Tile>? backDiagonalCheck(Tile playTile, List<Tile> takenTiles) {
    // add the play tile to the list
    List<Tile> tempWinTiles = [playTile];

    // Look left & up, unless playTile is the first tile or in top row.
    if (playTile.col > 1 && playTile.row < boardSetting.rows) {
      // iterate to check all upper rows
      for (var i = 1; i < (boardSetting.rows + 1) - playTile.row; i++) {
        Tile tile = Tile(col: playTile.col - i, row: playTile.row + i);

        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // Look right & down, unless playTile is the last tile or bottom row.
    if (playTile.col < boardSetting.cols && playTile.row > 1) {
      // iterate to check all lower rows. loop until hitting the bottom.
      for (var i = 1; i < playTile.row + 1; i++) {
        Tile tile = Tile(col: playTile.col + i, row: playTile.row - i);
        if (takenTiles.contains(tile)) {
          tempWinTiles.add(tile);
        } else {
          break;
        }
      }
    }

    // see if tempWinTiles meets the win condition, if so it's a win
    if (tempWinTiles.length >= boardSetting.winCondition()) {
      return tempWinTiles;
    }

    return null;
  }

}