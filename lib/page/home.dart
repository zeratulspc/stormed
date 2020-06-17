import 'package:flutter/material.dart';
import 'package:stormed/fnc/session.dart';
import 'package:stormed/page/session/session.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String uid = "TEST";

  List<Session> sessions = List();

  @override
  void initState() {
    super.initState();
    sessions.add(Session(title: "TEST", hostUid: "1", createdDate: DateTime.now().toIso8601String(), members: null));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("안녕하세요 $uid 님"),
      ),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text(sessions[index].title),
            onTap: (){
              Navigator.push(
                  context, MaterialPageRoute(
                    builder: (context) => SessionDetail(
                      //정보 넘기기
                    )
                )
              );
            },
          );
        }
      ),
    );
  }
}