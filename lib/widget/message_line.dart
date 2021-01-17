import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/message.dart';
import 'package:flutter_meitou/model/user.dart';

class MessageLine extends StatefulWidget {
  final Message msg;
  final User user;
  MessageLine(this.msg, this.user);
  @override
  _MessageLineState createState() => _MessageLineState();
}

class _MessageLineState extends State<MessageLine> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Container(
                color: Colors.yellow,
              ),
              flex: 1),
          Expanded(
              child: Container(
                color: Colors.red,
                child: Text(
                  widget.msg.content,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.yellow,
                  ),
                ),
              ),
              flex: 9)
        ],
      ),
    );
  }
}
