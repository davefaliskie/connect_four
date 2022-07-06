import 'package:game_template/src/game_internals/board_setting.dart';

class Tile {
  final int col; // x
  final int row; // y

  Tile({required this.col, required this.row});

  factory Tile.fromBoardIndex(int boardIndex, BoardSetting setting) {
    final col = (boardIndex % setting.cols).ceil() + 1;
    final row = setting.rows - ((boardIndex + 1) / setting.cols).ceil() + 1;
    return Tile(col: col, row: row);
  }

  @override
  String toString() => "[$col,$row]";
}