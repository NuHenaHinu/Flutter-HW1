class GameManager {
  GameManager._private();
  static final GameManager instance = GameManager._private();

  int playerScore = 0;
  int aiScore = 0;

  void resetScores() {
    playerScore = 0;
    aiScore = 0;
  }
}

const int kWinningScore = 5;
