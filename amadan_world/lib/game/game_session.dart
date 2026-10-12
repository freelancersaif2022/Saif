/// Score and progression for one run.
class GameSession {
  double _score = 0;
  int kills = 0;
  int headshots = 0;
  int level = 1;
  int levelKills = 0;
  int bossesDefeated = 0;
  double time = 0;
  bool bossActive = false;
  bool newHighScore = false;

  int get score => _score.floor();

  int get killsForNextLevel => 6 + level * 3;

  void addScore(double amount) => _score += amount;

  void reset() {
    _score = 0;
    kills = 0;
    headshots = 0;
    level = 1;
    levelKills = 0;
    bossesDefeated = 0;
    time = 0;
    bossActive = false;
    newHighScore = false;
  }
}
