import 'package:flutter/material.dart';

class EduPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFFf4ebc1),
      child: Column(children: [
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Image(
                image: NetworkImage(
                    'https://i.ytimg.com/vi/uAeBpzWyU2c/maxresdefault.jpg'))),
        Container(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            padding: EdgeInsets.all(10),
            child: Image(
                image: NetworkImage(
                    'https://i.ytimg.com/vi/prHUj6frMkY/maxresdefault.jpg'))),
        Container(
            padding: EdgeInsets.only(top: 30),
            child: Text(
              "更多惊喜正在酝酿中",
              style: TextStyle(fontSize: 20),
            ))
      ]),
    );
  }
}
