import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meitou/widget/transaction.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

Map<String, dynamic> userConfig = {};

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userName = '';
  var _coin = 0;
  final items = List<String>.generate(5, (i) => "Item $i");

  @override
  void initState() {
    super.initState();
    setState(() {
      _userName = 'Rain';
      _coin = 0;
    });
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    if (userConfig.containsKey('user_name') &&
        userConfig.containsKey('coins')) {
      setState(() {
        _userName = userConfig['user_name'];
        _coin = userConfig['coins'];
      });
      return;
    }
    final user_id = '198405c8-ca46-4818-ab51-5b612149d2d1';
    var url =
        "https://usdeuu1gp5.execute-api.us-west-2.amazonaws.com/user/$user_id/info";
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      // var itemCount = jsonResponse['totalItems'];
      // print('Number of books about http: $jsonResponse.');
      // print("${jsonResponse['user_name']['S']}");
      userConfig['user_name'] = jsonResponse['user_name']['S'];
      userConfig['coins'] = int.parse(jsonResponse['coins']['N']);
      setState(() {
        _userName = jsonResponse['user_name']['S'];
        _coin = int.parse(jsonResponse['coins']['N']);
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Widget _buildTransRow(index) {
    return Transaction(index: index);
  }

  Widget _buildTransList() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: items.length,
              itemExtent: 40,
              itemBuilder: (context, index) {
                return _buildTransRow(index);
              },
            )));
  }

  Widget _buildUserInfo() {
    return Padding(
        padding: EdgeInsets.only(left: 20, top: 20, bottom: 5),
        child: Row(
          children: <Widget>[
            Container(
                width: 150,
                height: 150,
                color: Colors.white,
                child: Icon(
                  Icons.verified_user,
                  color: Colors.blue,
                  size: 150,
                )),
            Container(
              width: 200,
              height: 150,
              margin: EdgeInsets.only(left: 20),
              color: Colors.white,
              child: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Column(
                    children: <Widget>[
                      Text(
                        "$_userName",
                        style: TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('美投币',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          )),
                      Text(
                        '$_coin',
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ],
                  )),
            )
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                _buildTransList(),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('我的订阅频道们')),
                _buildSubscriptionList(),
              ],
            )));
  }

  Widget _buildSubscriptionList() {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(top: 10),
        child: SizedBox(
            height: 150,
            child: ListView.builder(
              itemCount: 3,
              itemExtent: 40,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(5),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Padding(
                        padding: EdgeInsets.only(left: 10, right: 5),
                        child: Text(
                          '## Channnnnnn \$5 per month',
                          textScaleFactor: 1.2,
                        )),
                    Icon(Icons.album_outlined, color: Colors.yellow),
                  ]),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreen,
                    boxShadow: [
                      BoxShadow(color: Colors.white, spreadRadius: 3),
                    ],
                  ),
                );
              },
            )));
  }
}
