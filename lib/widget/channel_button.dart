import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/channel.dart';

class ChannelButton extends StatelessWidget {
  final Channel channel;
  ChannelButton({this.channel});

  void _channelTapped() {
    print(channel.name);
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
      onTap: _channelTapped,
    );
  }
}
