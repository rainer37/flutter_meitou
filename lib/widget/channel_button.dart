import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/chat_board.dart';

class ChannelButton extends StatelessWidget {
  final Channel channel;
  ChannelButton({this.channel});

  void _channelTapped(context) {
    print(channel.name);
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return Scaffold(
          appBar: AppBar(
            title: Text('开一个新的频道吧'),
          ),
          body: Text('你有什么想说的'));
    }));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        print(channel.name);
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (BuildContext context) {
          return ChatBoard(channel);
        }));
      },
    );
  }
}
