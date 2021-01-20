import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:amplify_core/amplify_core.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:flutter_meitou/model/config.dart';
import '../amplifyconfiguration.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _emailController = TextEditingController();
  var _passwordController = TextEditingController();

  void _showAlertDialog(BuildContext context, String action, title, content) {
    // Create button
    Widget okButton = FlatButton(
      child: Text(action),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _signIn() async {
    try {
      CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
          options: CognitoSessionOptions(getAWSCredentials: true));
      print('${sess.userSub} already signed in');
      _fetchUserInfo();
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    } on AuthError catch (e) {
      print('not logged in, proceed to sign in');
    }

    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      print('[${_emailController.text}][${_passwordController.text}]');
      print('has user logged in ? ${res.isSignedIn}');
      // CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
      //     options: CognitoSessionOptions(getAWSCredentials: true));
      // print('has user logged in ? ${sess.isSignedIn}');
      // print(sess.userSub);

      _fetchUserInfo();
      _showAlertDialog(context, '好嘞', '登陆成功', '开始探索美投吧！');
      Navigator.of(context).pushReplacementNamed('/home');
    } on AuthError catch (e) {
      print(e);
      _showAlertDialog(context, '谢谢', '登陆失败', '请检查你的邮箱密码...');
    }
  }

  void _configureAmplify() async {
    print('configuring amplify');
    // Add Pinpoint and Cognito Plugins, or any other plugins you want to use
    if (MeitouConfig.containsConfig('amplifyConfigured')) {
      print('amplify configured');
      return;
    }

    try {
      Amplify amplifyInstance = Amplify();
      AmplifyAuthCognito authPlugin = AmplifyAuthCognito();
      amplifyInstance
          .addPlugin(authPlugins: [authPlugin], analyticsPlugins: []);

      // Once Plugins are added, configure Amplify
      await amplifyInstance.configure(amplifyconfig);
      AmplifyAuthCognito auth = AmplifyAuthCognito();
      setState(() {
        MeitouConfig.setConfig('amplifyConfigured', true);
      });
      // try {
      //   Map<String, dynamic> userAttributes = {
      //     "email": 'rainer.1993@hotmail.com',
      //     "phone_number": '+12367776456',
      //     // additional attributes as needed
      //   };
      //   SignUpResult res = await Amplify.Auth.signUp(
      //       username: "rainer.1993@hotmail.com",
      //       password: "Abcd1234!!!",
      //       options: CognitoSignUpOptions(userAttributes: userAttributes));
      //   print('is sign up complete ? ${res.isSignUpComplete}');
      // } on AuthError catch (e) {
      //   print(e);
      // }
      // try {
      //   SignUpResult res = await Amplify.Auth.confirmSignUp(
      //       username: "rainer.1993@hotmail.com", confirmationCode: "838881");
      // } on AuthError catch (e) {
      //   print(e);
      // }
    } on AuthError catch (e) {
      print(e.exceptionList);
    }
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: GestureDetector(
            onTap: () {
              FocusScope.of(context).requestFocus(new FocusNode());
            },
            child: Container(
              color: Colors.lightGreen,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                          'https://yt3.ggpht.com/ytc/AAUvwnh90LNf2_wRdm3PPbWtSL7I-h0jOIV0D9P7lqF7=s88-c-k-c0x00ffffff-no-rj'),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: TextField(
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(color: Colors.white),
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: '请输入邮箱地址',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.white,
                          ),
                        ),
                        obscureText: false,
                      ),
                    ),
                  ),
                  Container(
                    child: Padding(
                      padding: EdgeInsets.only(left: 40, right: 40),
                      child: TextField(
                        autocorrect: false,
                        enableSuggestions: false,
                        style: TextStyle(color: Colors.white),
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '请输入登陆密码',
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.white, width: 1.0)),
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Colors.white,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 30),
                    child: RaisedButton(
                      padding: EdgeInsets.all(20),
                      onPressed: _loginClick,
                      color: Colors.white,
                      textColor: Colors.lightGreen,
                      child: Text(
                        '开始涨涨涨！',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  )
                ],
              ),
            )));
  }

  void _loginClick() {
    _signIn();
  }

  void _fetchUserInfo() async {
    if (MeitouConfig.containsConfig('user_name') &&
        MeitouConfig.containsConfig('coins')) {
      print('already has user info??/');
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
      // print("${jsonResponse}");
      MeitouConfig.setConfig('user_id', jsonResponse['userId']['S']);
      MeitouConfig.setConfig('user_name', jsonResponse['user_name']['S']);
      MeitouConfig.setConfig('coins', int.parse(jsonResponse['coins']['N']));
      print('user info fetched!');
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }
}
