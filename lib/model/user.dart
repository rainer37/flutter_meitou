class User {
  String id, name, email, avatarUrl;
  int coins;
  User(this.id, this.name, this.email, this.avatarUrl) {
    User._(id, name, email, avatarUrl, 0);
  }
  User._(this.id, this.name, this.email, this.avatarUrl, this.coins);

  void fillCoins(int coins) => this.coins += coins;
}
