import 'package:flutter/material.dart';

import 'package:stormed/fnc/user.dart';
import 'package:stormed/fnc/preferencesData.dart';

import 'package:stormed/page/auth/login.dart';

class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  UserDBFNC userDBFNC = UserDBFNC();
  @override
  void initState() {
    getAutoLogin().then((_isAutoLogin) {
      if(_isAutoLogin) {
        getEmail().then((_email) => getPassword().then((_password) =>
            userDBFNC.loginUser(email: _email, password: _password).then(
                    (user) {
                  userDBFNC.updateUserRecentLoginDate(uid: user.user.uid, recentLoginDate: DateTime.now().toIso8601String());
                  Navigator.of(context).pushReplacementNamed('/home');
                }).catchError((e) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            })));
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
      }
    });
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
       child: Image.asset(
         'assets/logo.png',
          width: screenSize.width /2,
        ),
      ),
    );
  }

}