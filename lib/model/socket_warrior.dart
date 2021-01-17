import 'dart:convert';

import 'package:web_socket_channel/io.dart';

class SocketWarrior {
  String channelId;
  IOWebSocketChannel openConn;

  SocketWarrior(this.channelId);

  void sendMessage(String msg) {
    if (openConn != null) {
      msg = json.encode({'action': "onMessage", 'message': msg});
      print('sending message $msg');
      openConn.sink.add(msg);
    }
  }

  void open(String serverEndpoint) {
    print('connecting to $serverEndpoint');
    if (openConn == null) {
      openConn = IOWebSocketChannel.connect(serverEndpoint,
          headers: {'channel_id': this.channelId});
    }
  }

  void close() {
    print('closing connection ${openConn.toString()}');
    if (openConn != null) {
      openConn.sink.close();
    }
  }
}
