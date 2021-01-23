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

  void morphMessage(String channelId, Message msg) {
    Message morph = messageBook[channelId].lookup(msg);
    print('found message $morph');
  }

  void cleanse(String channelId) {
    for (String tag in releaseTheRageOfTags(channelId)) {
      messageBook.remove('$channelId#tag#$tag');
    }
    messageBook.remove(channelId);
  }

  void addMessageToChannel(String channelId, Message msg) {
    if (messageBook[channelId] == null)
      messageBook[channelId] = new SplayTreeSet();
    for (String tag in msg.hashtags.split(',')) {
      if (messageBook['$channelId#tag#$tag'] == null)
        messageBook['$channelId#tag#$tag'] = new SplayTreeSet();
      messageBook['$channelId#tag#$tag'].add(msg);
    }
    messageBook[channelId].add(msg);
  }

  List<String> releaseTheRageOfTags(String channelId) {
    List<String> tags = messageBook.keys
        .where((element) => element.startsWith('$channelId#tag#'))
        .map((e) => e.split('#')[2])
        .toList();
    // print(tags);
    return tags;
  }

  List<Message> summonTaggedMessages(String channelId, tag) {
    return messageBook['$channelId#tag#$tag'] == null
        ? List.empty()
        : messageBook['$channelId#tag#$tag'].toList();
  }

  void polluteChannel(String channelId) {
    messageBook['$channelId#dirty'] = null;
    print('polluted ? ${messageBook.containsKey('$channelId#dirty')}');
  }

  void rinseChannel(String channelId) {
    messageBook.remove('$channelId#dirty');
    print('still polluted ? ${messageBook.containsKey('$channelId#dirty')}');
  }

  String lastSeenInChannel(String channelId) {
    if (messageBook.containsKey('$channelId#dirty')) return '0';
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
