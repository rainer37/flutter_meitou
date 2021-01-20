import 'dart:collection';

import 'message.dart';

class MessageWarlock {
  static MessageWarlock _instance;
  Map<String, SplayTreeSet<Message>> messageBook;

  MessageWarlock._internal() {
    messageBook = new Map();
    print('Message Warlock is born!');
  }

  static MessageWarlock summon() {
    if (_instance == null) _instance = MessageWarlock._internal();
    return _instance;
  }

  List<String> listActiveChannels() {
    return messageBook.keys;
  }

  void addMessageToChannel(String channelId, Message msg) {
    if (messageBook[channelId] == null)
      messageBook[channelId] = new SplayTreeSet();
    messageBook[channelId].add(msg);
  }

  String lastSeenInChannel(String channelId) {
    return messageBook[channelId] == null
        ? '0'
        : messageBook[channelId].last.lastUpdatedAt;
  }

  void spellMessagesInChannel(String channelId) {
    for (Message m in messageBook[channelId]) {
      print(m);
    }
  }

  int numMessagesInChannel(String channelId) {
    return messageBook[channelId] == null ? 0 : messageBook[channelId].length;
  }

  List<Message> castMessagesInChannel(String channelId) {
    return messageBook[channelId] == null
        ? List.empty()
        : messageBook[channelId].toList();
  }
}
