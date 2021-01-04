class Channel {
  String id, name, desc, ownerId;
  int subscriptionFee;
  bool subbed;

  Channel(this.id, this.name, this.desc, this.ownerId, this.subscriptionFee) {
    this.subbed = false;
  }

  void subscribe() {
    if (this.subbed) throw Exception('Already subbed');
    this.subbed = true;
  }
}
