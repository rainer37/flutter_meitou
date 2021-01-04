import 'package:flutter_meitou/model/channel.dart';
import 'package:test/test.dart';

void main() {
  group('Channel Basic', () {
    final chanA =
        Channel('cb-12', 'CyberPunk', 'Channel for 2077', '123-456-abc-222', 5);
    test('Channel Constructors', () {
      expect(chanA.subscriptionFee, 5);
      expect(chanA.id, 'cb-12');
      expect(chanA.name, 'CyberPunk');
      expect(chanA.subbed, false);
    });
    test('Channel Subscription', () {
      expect(chanA.subbed, false);
      chanA.subscribe();
      expect(chanA.subbed, true);
      expect(() => chanA.subscribe(), throwsException);
    });
  });
}
