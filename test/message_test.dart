import 'package:flutter_meitou/model/message.dart';
import 'package:test/test.dart';

void main() {
  group('Channel Basic', () {
    final msg0 = Message(
        'chan-0', 'sender-1', 'message-2', 't1,aws,azz', '1610852828.3629782');
    final String expected =
        '{"channel_id":"chan-0","msg_sk":"1610852828.3629782#sender-1","sender_id":"sender-1","content":"message-2","hashtags":"t1,aws,azz","last_updated_at":"1610852828.3629782"}';
    test('Message Constructors', () {
      expect(msg0.channelId, 'chan-0');
      expect(msg0.senderId, 'sender-1');
      expect(msg0.content, 'message-2');
      expect(msg0.hashtags, 't1,aws,azz');
      expect(msg0.lastUpdatedAt, '1610852828.3629782');
    });
    test('Message toJSON', () {
      expect(msg0.toJSON(), expected);
    });
    test('Message fromJSON', () {
      expect(msg0, Message.fromJSON(expected));
    });
  });
}
