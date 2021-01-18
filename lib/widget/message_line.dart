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
      padding: EdgeInsets.only(bottom: 10, top: 10, left: 10, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    print('${widget.user.name} avatar clicked');
                  },
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(widget.user.avatarUrl),
                  )),
              flex: 1),
          Expanded(
              child: GestureDetector(
                  onLongPress: () {
                    print('long pressing message');
                  },
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 15, bottom: 5),
                          child: Row(
                            children: [
                              Padding(
                                  padding: EdgeInsets.only(right: 5),
                                  child: Text(
                                    widget.user.name,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 10),
                                  )),
                              Text(
                                new DateTime.fromMillisecondsSinceEpoch(
                                        int.parse(widget.msg.lastUpdatedAt))
                                    .toString(),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 15),
                          child: LimitedBox(
                            maxWidth: MediaQuery.of(context).size.width * 0.5,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 5, left: 10, right: 10, bottom: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.lightGreen,
                              ),
                              child: Text(
                                widget.msg.content,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                              ),
                            ),
                          ),
                        )
                      ])),
              flex: 8),
          Expanded(flex: 1, child: Container())
        ],
      ),
    );
  }
}
