import 'package:flutter/material.dart';

import 'package:stormed/fnc/user.dart';
import 'package:stormed/fnc/session.dart';
import 'package:stormed/page/session/session.dart';
import 'package:stormed/page/session/editSession.dart';
import 'package:stormed/page/basicDialogs.dart';

import 'package:firebase_database/firebase_database.dart';

class MySessions extends StatefulWidget {
  final User currentUserInfo;

  MySessions(this.currentUserInfo);
  @override
  _MySessionsState createState() => _MySessionsState(currentUserInfo);
}

class _MySessionsState extends State<MySessions> {
  BasicDialogs basicDialogs = BasicDialogs();
  UserDBFNC userDBFNC = UserDBFNC();
  SessionFnc sessionFnc = SessionFnc();
  List<Session> sessions = List();

  final User currentUserInfo;
  Query sessionQuery;

  _MySessionsState(this.currentUserInfo);

  @override
  void initState() {
    super.initState();
      sessionQuery = FirebaseDatabase.instance.reference().child("Session");
      sessionQuery.onChildAdded.listen(onEntryAdded);
      sessionQuery.onChildChanged.listen(onEntryChanged);
      sessionQuery.onChildRemoved.listen(onEntryRemoved);
  }

  onEntryAdded(Event event) {
    if(this.mounted) {
      Session snap = Session().fromSnapShot(event.snapshot);
      bool isContained = false;
      if(snap.members != null) {
        snap.members.forEach((element) {
          if (element.key == currentUserInfo.key) {
            isContained = true;
          } else {
            if (!isContained) {
              isContained = false;
            }
          }
        });
      }
      if(isContained) {
        userDBFNC.getUserInfo(snap.hostUid).then((value) {
          snap.hostInfo = value;
          setState(() {
            sessions.add(snap);
          });
        });
      }
    }
  }

  onEntryChanged(Event event) {
    if(this.mounted) {
      Session snap = Session().fromSnapShot(event.snapshot);
      bool isContained = false;
      if(snap.members != null) {
        snap.members.forEach((element) {
          if(element.key == currentUserInfo.key) {
            isContained = true;
          } else {
            if(!isContained) {
              isContained = false;
            }
          }
        });
      }
      if(isContained) {
        userDBFNC.getUserInfo(snap.hostUid).then((value) {
          snap.hostInfo = value;
          setState(() {
            var oldEntry = sessions.singleWhere((element) => element.sessionId == snap.sessionId);
            sessions[sessions.indexOf(oldEntry)] = snap;
          });
        });
      } else {
        setState(() {
          sessions.removeWhere((element) => element.sessionId == snap.sessionId);
        });
      }
    }
  }

  onEntryRemoved(Event event) {
    if(this.mounted) {
      Session snap = Session().fromSnapShot(event.snapshot);
      setState(() {
        sessions.removeWhere((element) => element.sessionId == snap.sessionId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        title: Text(
            "내가 참가한 세션",
            style: TextStyle(color: Colors.black,)
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
                                leading: Icon(Icons.exit_to_app),
                                title: Text("세션 나가기"),
                                onTap: sessions[index].hostUid != currentUserInfo.key ? () {
                                  Navigator.pop(context);
                                  basicDialogs.dialogWithFunction(
                                      context, "세션 나가기", "세션에서 나가시겠습니까?", () {
                                    sessionFnc.deleteMember(sessions[index].sessionId, currentUserInfo.key);
                                    Navigator.pop(context);
                                  });
                                } : null,
                              ),
                              ListTile(
                                leading: Icon(Icons.delete),
                                title: Text("세션 삭제"),
                                subtitle: Text("다시 되돌릴 수 없습니다!"),
                                onTap: sessions[index].hostUid == currentUserInfo.key ? () {
                                  Navigator.pop(context);
                                  basicDialogs.dialogWithFunction(
                                      context, "세션 삭제", "세션을 삭제하시겠습니까?",
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