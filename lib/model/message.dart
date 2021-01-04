class HashTag {
  String content;
}

class Message {
  String id, senderId;
  List<HashTag> hashtags;
  Message(this.id, this.senderId);
}

class ImageMessage extends Message {
  String imgUrl;

  ImageMessage(String id, String senderId, String imgUrl)
      : super(id, senderId) {
    this.imgUrl = imgUrl;
  }
}

class QueryMessage extends Message {
  QueryMessage(String id, senderId) : super(id, senderId);
}
