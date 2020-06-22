import 'package:flutter/material.dart';

import 'package:stormed/page/home.dart';
import 'package:stormed/page/auth/login.dart';
import 'package:stormed/page/splash.dart';

void main() {
  runApp(MyApp());
}

final routes = {
  '/login': (BuildContext context) => LoginPage(),
  '/home': (BuildContext context) => HomePage(),
};


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: routes,
      title: 'Stomred!',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Splash(),
    );
  }
}

