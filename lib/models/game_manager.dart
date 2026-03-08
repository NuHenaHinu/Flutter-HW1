class GameManager {
  GameManager._private();
  static final GameManager instance = GameManager._private();

  int playerScore = 0;
  int aiScore = 0;
  // current game difficulty
  Difficulty currentDifficulty = Difficulty.noob;

  void setDifficulty(Difficulty d) => currentDifficulty = d;

  void resetScores() {
    playerScore = 0;
    aiScore = 0;
  }
}

const int kWinningScore = 5;

enum Difficulty { noob, notNoob, pro }
