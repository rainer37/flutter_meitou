import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/chat_board.dart';

class ChannelButton extends StatelessWidget {
  final Channel channel;
  ChannelButton({this.channel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4),
      child: ListTile(
        dense: true,
        isThreeLine: false,
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
        tileColor: Colors.lightGreen,
        title: Text(
          "## ${channel.name}${channel.subbed ? '' : ' (💰${channel.subscriptionFee})'}",
          style: TextStyle(
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          channel.desc,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
        onTap: () {
          print('clicking on ' + channel.name);
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return ChatBoard(channel);
          }));
        },
      ),
    );
  }
}
