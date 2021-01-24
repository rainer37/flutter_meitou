import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_meitou/model/channel.dart';
import 'package:flutter_meitou/widget/chat_board.dart';
import 'package:vibration/vibration.dart';

class ChannelButton extends StatelessWidget {
  final Channel channel;
  ChannelButton({this.channel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, right: 4, bottom: 4),
      child: ListTile(
        dense: true,
        isThreeLine: false,
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
        tileColor: Colors.lightGreen,
        title: Row(
          children: [
            Text(
              "## ${channel.name}",
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            Container(
              width: 10,
            ),
            RawChip(
              backgroundColor: Colors.green,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              label: Text(
                "${channel.subbed ? '💰30000' : '💰${channel.subscriptionFee}'}",
                style: TextStyle(fontSize: 15, color: Colors.yellow[600]),
              ),
            )
          ],
        ),
        subtitle: Text(
          channel.desc,
          style: TextStyle(
            fontSize: 12,
            color: Colors.blueGrey,
          ),
        ),
        onTap: () async {
          print('clicking on ' + channel.name);
          if (channel.id.startsWith('rpc')) {
            if (await Vibration.hasVibrator()) {
              Vibration.vibrate();
            }
            print('private chan cannot go in!');
            return;
          }
          HapticFeedback.heavyImpact();
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (BuildContext context) {
            return ChatBoard(channel);
          }));
        },
      ),
    );
  }
}
