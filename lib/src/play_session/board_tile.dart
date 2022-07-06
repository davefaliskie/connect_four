import 'package:flutter/material.dart';
import 'package:game_template/src/game_internals/board_state.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_setting.dart';
import '../game_internals/tile.dart';

class BoardTile extends StatefulWidget {
  final int boardIndex;
  final BoardSetting boardSetting;

  const BoardTile(
      {super.key, required this.boardIndex, required this.boardSetting});

  @override
  State<BoardTile> createState() => _BoardTileState();
}

class _BoardTileState extends State<BoardTile> {
  @override
  Widget build(BuildContext context) {
    final tile = Tile.fromBoardIndex(widget.boardIndex, widget.boardSetting);

    return InkResponse(
      onTap: () {
        Provider.of<BoardState>(context, listen: false).makeMove(tile);
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          color: Colors.blue,
          child: Consumer<BoardState>(
              builder: (context, boardState, child)  {
              return Container(
                margin: EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                  color: boardState.tileColor(tile),
                  shape: BoxShape.circle,
                ),
                child: Center(child: Text(tile.toString())),
              );
            }
          ),
        ),
      ),
    );
  }
}
