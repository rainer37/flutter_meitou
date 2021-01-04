import 'package:flutter_meitou/model/chat_history.dart';

class Channel {
  String id, name, desc, ownerId;
  int subscriptionFee;
  bool subbed;
  ChatHistory chatHistory;

  Channel(this.id, this.name, this.desc, this.ownerId, this.subscriptionFee) {
    this.subbed = false;
    this.chatHistory = ChatHistory();
  }

  Channel.withSub(this.id, this.name, this.desc, this.ownerId,
      this.subscriptionFee, this.subbed) {
    this.chatHistory = ChatHistory();
  }

  void subscribe() {
    if (this.subbed) throw Exception('Already subbed');
    this.subbed = true;
  }
}
