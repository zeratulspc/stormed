import 'package:flutter/material.dart';

import 'package:stormed/fnc/session.dart';
import 'package:stormed/fnc/user.dart';

class EditSession extends StatefulWidget {
  final User currentUserInfo;
  EditSession(this.currentUserInfo);
  @override
  EditSessionState createState() => EditSessionState(currentUserInfo);
}

class EditSessionState extends State<EditSession> {
  final User currentUserInfo;
  final titleFormKey = GlobalKey<FormState>();
  EditSessionState(this.currentUserInfo);


  SessionFnc sessionFnc = SessionFnc();
  Session session;
  String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("세션 만들기"),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.check),
        onPressed: () async {
          final form = titleFormKey.currentState;
          form.save();
          if(form.validate()) {
            session = Session(
              hostUid: currentUserInfo.key,
              title: title.trim(),
              createdDate: DateTime.now().toIso8601String(),
            );
            session.sessionId = sessionFnc.createSession(session);
            Navigator.pop(context, session);
          }
        },
      ),
      body: Form(
        key: titleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(
                    10, 10, 10, 1
                ),
                height: 90,
                child: TextFormField(
                  onSaved: (value) => title = value,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: "방 제목",
                    fillColor: Colors.grey[300],
                    filled: true,),
                  validator: (String name) {
                    if (name.length == 0)
                      return '방 제목을 입력해주세요.';
                    else if(name.length >= 16)
                      return "16자 까지만 입력 가능합니다.";
                    else
                      return null;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

}