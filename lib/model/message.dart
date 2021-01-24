import 'dart:convert';

class Message extends Comparable {
  String channelId, senderId, content, hashtags, lastUpdatedAt;
  int likes;
  Message(this.channelId, this.senderId, this.content, this.hashtags,
      this.lastUpdatedAt,
      {this.likes = 0});

  String toJSON() {
    return json.encode({
      'channel_id': this.channelId,
      'msg_sk': "${this.lastUpdatedAt}#${this.senderId}",
      'sender_id': this.senderId,
      'content': this.content,
      'hashtags': this.hashtags,
      'last_updated_at': this.lastUpdatedAt,
      'likes': this.likes.toString(),
    });
  }

  static Message fromJSON(String msgJSON) {
    Map<String, dynamic> m = json.decode(msgJSON);
    if (!m.containsKey('likes')) m['likes'] = 0;
    return Message(m['channel_id'], m['sender_id'], m['content'], m['hashtags'],
        m['last_updated_at'],
        likes: int.parse(m['likes']));
  }

  @override
  String toString() {
    return toJSON();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          channelId == other.channelId &&
          senderId == other.senderId &&
          content == other.content &&
          lastUpdatedAt == other.lastUpdatedAt;

  @override
  int get hashCode =>
      channelId.hashCode ^
      senderId.hashCode ^
      content.hashCode ^
      hashtags.hashCode ^
      lastUpdatedAt.hashCode;

  @override
  int compareTo(other) {
    Message otherMsg = (other as Message);
    if (lastUpdatedAt == otherMsg.lastUpdatedAt &&
        senderId == otherMsg.senderId) return 0;
    return lastUpdatedAt.compareTo(otherMsg.lastUpdatedAt);
  }
}
