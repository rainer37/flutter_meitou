import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_meitou/widget/channel_button.dart';

void main() {
  testWidgets('Channel Button Test', (WidgetTester tester) async {
    final chanA =
        Channel('cb-12', 'CyberPunk', 'Channel for 2077', '123-456-abc-222', 5);
    // await tester.pumpWidget(ChannelButton(channel: chanA));
    // expect(find.text('##CyberPunk##'), findsNothing);
  });
}
