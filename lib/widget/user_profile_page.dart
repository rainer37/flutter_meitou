import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_meitou/model/config.dart';

import 'package:amplify_core/amplify_core.dart';

const defaultAvatarUrl =
    'https://i1.sndcdn.com/avatars-000617335083-cmq67l-t500x500.jpg';

class UserProfile extends StatefulWidget {
  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  var _userName = '', _avatar = defaultAvatarUrl;
  var _coin = 0;
  final items = List<String>.generate(5, (i) => "Item $i");

  @override
  void initState() {
    super.initState();
    setState(() {
      _userName = 'Loading';
      _coin = 0;
    });
    _fetchUserInfo();
  }

  void _fetchUserInfo() async {
    if (MeitouConfig.containsConfig('user_name') &&
        MeitouConfig.containsConfig('coins') &&
        MeitouConfig.containsConfig('avatar_url')) {
      setState(() {
        _userName = MeitouConfig.getConfig('user_name');
        _coin = MeitouConfig.getConfig('coins');
        _avatar = MeitouConfig.getConfig('avatar_url') == ''
            ? defaultAvatarUrl
            : MeitouConfig.getConfig('avatar_url');
      });
      return;
    } else {
      print('no logged in user detected!!!');
      _logOut();
    }
  }

  Widget _buildUserInfo() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      child: Padding(
          padding: EdgeInsets.only(left: 20, top: 20, bottom: 5),
          child: Row(
            children: <Widget>[
              Container(
                  width: 150,
                  height: 150,
                  child: CircleAvatar(
                    radius: 150,
                    backgroundImage: NetworkImage(_avatar),
                  )),
              Container(
                width: 200,
                height: 150,
                margin: EdgeInsets.only(left: 20),
                child: Padding(
                    padding: EdgeInsets.only(top: 10),
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
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            color: Color(0xFFf4ebc1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(),
                Padding(
                    padding: EdgeInsets.only(top: 10, left: 10),
                    child: Text('我的订阅频道们')),
                _buildSubscriptionList(),
                Container(
                  height: 140,
                  width: double.infinity,
                  margin: EdgeInsets.only(top: 30),
                  child: RaisedButton(
                    padding: EdgeInsets.all(20),
                    onPressed: _logOut,
                    color: Colors.white,
                    textColor: Colors.lightGreen,
                    child: Text(
                      '退出当前神奇的账号然后换一个登录',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            )));
  }

  void _logOut() async {
    print('logging out');
    try {
      await Amplify.Auth.signOut();
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    } on AuthError catch (e) {
      print(e);
    }
  }

  Widget _buildSubscriptionList() {
    return Container(
        height: MediaQuery.of(context).size.height * 0.2,
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
                          '## 某一个神奇的频道 \$5 per month',
                          textScaleFactor: 1.2,
                        )),
                    Icon(Icons.album_outlined, color: Colors.yellow),
                  ]),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.lightGreen,
                    boxShadow: [
                      BoxShadow(color: Color(0xFFf4ebc1), spreadRadius: 3),
                    ],
                  ),
                );
              },
            )));
  }
}
