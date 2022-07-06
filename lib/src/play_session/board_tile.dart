import 'package:flutter/material.dart';
import 'package:game_template/src/style/palette.dart';
import 'package:provider/provider.dart';

import '../game_internals/board_setting.dart';

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
    return InkResponse(
      onTap: () {
        print ("Tapped ${widget.boardIndex}");
      },
      child: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Container(
          color: Colors.blue,
          child: Container(
            margin: EdgeInsets.all(3.0),
            decoration: BoxDecoration(
              color: context.read<Palette>().backgroundPlaySession,
              shape: BoxShape.circle,
            ),
            child: Center(child: Text("${widget.boardIndex}")),
          ),
        ),
      ),
    );
  }
}
