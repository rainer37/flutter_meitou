import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  void _signIn() async {
    try {
      SignInResult res = await Amplify.Auth.signIn(
        username: _emailController.text,
        password: _passwordController.text,
      );
      print('has user logged in ? ${res.isSignedIn}');
      // CognitoAuthSession sess = await Amplify.Auth.fetchAuthSession(
      //     options: CognitoSessionOptions(getAWSCredentials: true));
      // print('has user logged in ? ${sess.isSignedIn}');
      // print(sess.userPoolTokens.idToken);
    } on AuthError catch (e) {
      print(e);
    }
  }

  void _configureAmplify() async {
    print('configuring amplify');
    // Add Pinpoint and Cognito Plugins, or any other plugins you want to use
    if (MeitouConfig.containsConfig('amplifyConfigured')) {
      print('amplify configured');
      return;
    }
    // try {
    //   Map<String, dynamic> userAttributes = {
    //     "email": 'rainer.1993@hotmail.com',
    //     "phone_number": '+12367776456',
    //     // additional attributes as needed
    //   };
    //   SignUpResult res = await Amplify.Auth.signUp(
    //       username: "rainer.1993@hotmail.com",
    //       password: "password",
    //       options: CognitoSignUpOptions(userAttributes: userAttributes));
    //   print('is sign up complete ? ${res.isSignUpComplete}');
    // } on AuthError catch (e) {
    //   print(e);
    // }
    // try {
    //   SignUpResult res = await Amplify.Auth.confirmSignUp(
    //       username: "rainer.1993@hotmail.com", confirmationCode: "467973");
    // } on AuthError catch (e) {
    //   print(e);
    // }
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
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _configureAmplify();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                style: TextStyle(color: Colors.white),
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: '请输入邮箱地址',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
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
                style: TextStyle(color: Colors.white),
                controller: _passwordController,
                decoration: InputDecoration(
                  hintText: '请输入登陆密码',
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 1.0)),
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
    );
  }

  void _loginClick() {
    _signIn();
  }
}
