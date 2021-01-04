class User {
  String id, name, email;
  int coins;
  User(this.id, this.name, this.email) {
    User._(id, name, email, 0);
  }
  User._(this.id, this.name, this.email, this.coins);

  void fillCoins(int coins) => this.coins += coins;
}
