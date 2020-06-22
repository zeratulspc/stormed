import 'package:flutter/material.dart';

import 'package:stormed/fnc/user.dart';
import 'package:stormed/fnc/session.dart';
import 'package:stormed/page/session/session.dart';
import 'package:stormed/page/session/editSession.dart';
import 'package:stormed/page/basicDialogs.dart';
import 'package:stormed/page/setting.dart';
import 'package:stormed/page/mySession.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  BasicDialogs basicDialogs = BasicDialogs();
  UserDBFNC userDBFNC = UserDBFNC();
  SessionFnc sessionFnc = SessionFnc();
  List<Session> sessions = List();

  FirebaseUser currentUser;
  User currentUserInfo;
  Query sessionQuery;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((data) {
      setState(() {
        currentUser = data;
      });
      userDBFNC.getUserInfo(currentUser.uid).then((data) {
        setState(() {
          currentUserInfo = data;
        });
      });
    });
    sessionQuery = FirebaseDatabase.instance.reference().child("Session");
    sessionQuery.onChildAdded.listen(onEntryAdded);
    sessionQuery.onChildChanged.listen(onEntryChanged);
    sessionQuery.onChildRemoved.listen(onEntryRemoved);
  }

  onEntryAdded(Event event) {
    Session snap = Session().fromSnapShot(event.snapshot);
    userDBFNC.getUserInfo(snap.hostUid).then((value) {
              snap.hostInfo = value;
              setState(() {
                sessions.add(snap);
              });
    });

  }

  onEntryChanged(Event event) {
    Session snap = Session().fromSnapShot(event.snapshot);
    userDBFNC.getUserInfo(snap.hostUid).then((value) {
      snap.hostInfo = value;
      setState(() {
        var oldEntry = sessions.singleWhere((element) => element.sessionId == snap.sessionId);
        sessions[sessions.indexOf(oldEntry)] = snap;
      });
    });
  }

  onEntryRemoved(Event event) {
    Session snap = Session().fromSnapShot(event.snapshot);
    setState(() {
      sessions.removeWhere((element) => element.sessionId == snap.sessionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.person, color: Colors.black,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => MySessions(currentUserInfo),
              ));
            },
          ),
          IconButton(
            icon: Icon(Icons.settings, color: Colors.black,),
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SettingPage(),
              ));
            },
          ),
        ],
        backgroundColor: Colors.white,
        title: Text(
          "STORMED",
          style: TextStyle(color: Colors.black, fontFamily: "Montserrat",)
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          Session session = await Navigator.push(context, MaterialPageRoute(
              builder: (context) => EditSession(currentUserInfo)
          ));
          if(session != null) {
            Navigator.push(
                context, MaterialPageRoute(
              builder: (context) => SessionDetail(currentUserInfo, session),
            )
            );
          }
        },
      ),
      body: ListView.builder(
        itemCount: sessions.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(vertical: 3.0, horizontal: 15.0),
              title: Row(
                children: <Widget>[
                  Text(sessions[index].title, style: TextStyle(
                      color: Colors.black, fontSize: 20
                  ),),
                  Text(" | ", style: TextStyle(
                      color: Colors.black54, fontSize: 14
                  ),),
                  Text("${sessions[index].hostInfo.userName}님의 세션", style: TextStyle(
                      color: Colors.black54, fontSize: 14
                  ),),
                ],
              ),
              trailing: Text(
                  "${sessions[index].members != null ? sessions[index].members.length : "0"}명",
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              subtitle: Text(
                "${sessions[index].strokes != null ? sessions[index].strokes.length : "0"}개의 획이 그어졌습니다"
              ),
              onTap: (){
                Navigator.push(
                    context, MaterialPageRoute(
                  builder: (context) => SessionDetail(currentUserInfo, sessions[index]),)
                );
              },
              onLongPress: (){
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext _context){
                      return Container(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.delete),
                              title: Text("세션 삭제"),
                              subtitle: Text("다시 되돌릴 수 없습니다!"),
                              onTap: sessions[index].hostUid == currentUserInfo.key ? () {
                                Navigator.pop(context);
                                basicDialogs.dialogWithFunction(
                                    context, "게시글 삭제", "게시글을 삭제하시겠습니까?",
                                        () {
                                      Navigator.pop(context);
                                      basicDialogs.showLoading(context, "게시글을 삭제하는 중입니다.");
                                      sessionFnc.deleteSession(sessions[index].sessionId);
                                      Navigator.pop(context);
                                    });
                              } : null,
                            ),
                          ],
                        ),
                      );
                    }
                );
              },
            ),
          );
        }
      ),
    );
  }
}