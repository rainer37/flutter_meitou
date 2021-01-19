import 'dart:convert';

class Message extends Comparable {
  String channelId, senderId, content, hashtags, lastUpdatedAt;
  Message(this.channelId, this.senderId, this.content, this.hashtags,
      this.lastUpdatedAt);

  String toJSON() {
    return json.encode({
      'channel_id': this.channelId,
      'msg_sk': "${this.lastUpdatedAt}#${this.senderId}",
      'sender_id': this.senderId,
      'content': this.content,
      'hashtags': this.hashtags,
      'last_updated_at': this.lastUpdatedAt,
    });
  }

  static Message fromJSON(String msgJSON) {
    Map<String, dynamic> m = json.decode(msgJSON);
    return Message(m['channel_id'], m['sender_id'], m['content'], m['hashtags'],
        m['last_updated_at']);
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
          hashtags == other.hashtags &&
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
