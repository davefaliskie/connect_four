class BoardSetting {
  final int cols;
  final int rows;

  const BoardSetting({required this.cols, required this.rows});

  int totalTiles() {
    return cols * rows;
  }

  int winCondition() {
    return 4;
  }
}