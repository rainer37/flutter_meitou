import 'package:flutter/material.dart';

class Transaction extends StatelessWidget {
  final index;
  Transaction({this.index});
  @override
  Widget build(BuildContext context) {
    return ListTile(
        tileColor: index % 2 == 0 ? Colors.grey : Colors.white,
        title: Align(
            alignment: Alignment(-1, -0.5),
            child: Text(
              'testt st ate a ',
              style: TextStyle(
                fontSize: 15,
              ),
            )),
        trailing: Icon(
          Icons.add_alert,
          color: Colors.green,
        ));
  }
}
