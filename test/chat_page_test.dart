import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_meitou/widget/chat_page.dart';

void main() {
  testWidgets('Main Page Sanity Test', (WidgetTester tester) async {
    await tester.pumpWidget(ChatPage());
    expect(find.text('-1'), findsNothing);
  });
}
