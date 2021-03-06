import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:stormed/fnc/user.dart';
import 'package:stormed/page/basicDialogs.dart';

class EditProfilePage extends StatefulWidget {
  final Function() callback;
  EditProfilePage({this.callback});

  @override
  EditProfilePageState createState() => EditProfilePageState();
}

class EditProfilePageState extends State<EditProfilePage> {
  BasicDialogs basicDialogs = BasicDialogs();
  UserDBFNC authDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  String userName;
  String description;
  String email;

  @override
  void initState() {
    super.initState();
    authDBFNC.getUser().then(
            (data) {
          currentUser = data;
          authDBFNC.getUserInfo(currentUser.uid).then(
                  (data) {
                setState(() {
                  userName = data.userName;
                  description = data.description;
                  email = data.email;
                });
              }
          );
        }
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("프로필 수정", style: TextStyle(color: Colors.black),),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Column(
              children: <Widget>[
                ListTile(
                    title: Text("닉네임", style: TextStyle(fontWeight: FontWeight.bold),),
                    trailing: FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Text("수정", style: TextStyle(color: Theme.of(context).primaryColor),),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TextFieldPage(object: "userName", uid: currentUser.uid, item: userName,
                              callback: () { // Reload
                                authDBFNC.getUserInfo(currentUser.uid).then(
                                        (data) {
                                      setState(() {
                                        userName = data.userName;
                                        description = data.description;
                                        email = data.email;
                                      });
                                    }
                                );
                                this.widget.callback();
                              },)
                        ));
                      },
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Center(
                    child: Text(userName??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
                  ),
                ),
                Divider(),
                ListTile(
                    title: Text("한줄 소개", style: TextStyle(fontWeight: FontWeight.bold),),
                    trailing: FlatButton(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Text("수정", style: TextStyle(color: Theme.of(context).primaryColor),),
                      onPressed: (){
                        Navigator.push(context, MaterialPageRoute(
                            builder: (_) => TextFieldPage(object: "description", uid: currentUser.uid, item: description,
                              callback: () { // Reload
                                authDBFNC.getUserInfo(currentUser.uid).then(
                                        (data) {
                                      setState(() {
                                        userName = data.userName;
                                        description = data.description;
                                        email = data.email;
                                      });
                                    }
                                );
                                this.widget.callback();
                              },
                            )
                        ));
                      },
                    )
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
                  child: Center(
                    child: Text(description??"불러오는 중...", style: TextStyle(color: Colors.grey[700]),),
                  ),
                ),
                Divider(),

              ],
            ),
          )
      ),
    );
  }
}

class TextFieldPage extends StatefulWidget {
  final Function() callback;
  final String object;
  final String uid;
  final String item;
  TextFieldPage({this.object, this.uid, this.item, this.callback});

  @override
  TextFieldPageState createState() => TextFieldPageState(object: object, uid: uid, item: item);
}

class TextFieldPageState extends State<TextFieldPage> {
  final editProfileFormKey = GlobalKey<FormState>();
  final String object;
  final String uid;
  String item;
  TextFieldPageState({this.object, this.uid, this.item});

  UserDBFNC authDBFNC = UserDBFNC();

  String objectToInfo(String object) {
    switch(object) {
      case "userName":
        return "닉네임";
        break;
      case "description":
        return "한줄소개";
        break;
      default:
        return "정보";
        break;
    }
  }

  objectToFnc(String object) {
    switch(object) {
      case "userName":
        authDBFNC.updateUserName(uid: uid, userName: item);
        break;
      case "description":
        authDBFNC.updateUserDescription(uid: uid, description: item);
        break;
      default:
        break;
    }
  }

  void confirmDialog(BuildContext context, String object) {
    String contentText;
    String titleText;
    switch(object) {
      case "userName":
        contentText = "닉네임을 수정하시겠습니까?";
        titleText = "닉네임";
        break;
      case "description":
        contentText = "한줄소개를 수정하시겠습니까?";
        titleText = "한줄소개";
        break;
      default:
        contentText = "정보를 수정하시겠습니까?";
        titleText = "정보";
        break;
    }
    showDialog(context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("$titleText 수정"),
          content: Text(contentText),
          actions: <Widget>[
            FlatButton(
              child: Text("취소"),
              onPressed: (){
                Navigator.pop(context); // dialog pop
              },
            ),
            FlatButton(
              child: Text("확인"),
              onPressed: (){
                var form = editProfileFormKey.currentState;
                form.save();
                if(form.validate()) {
                  objectToFnc(object);
                  this.widget.callback();
                  Navigator.pop(context); // 컨펌 다이알로그 팝
                  Navigator.pop(context); // 페이지 팝
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 1,
        backgroundColor: Colors.white,
        title: Text("${objectToInfo(object)} 수정", style: TextStyle(color: Colors.black),),
        actions: <Widget>[
          FlatButton(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Text("저장", style: TextStyle(color: Colors.black),),
            onPressed: () {
              confirmDialog(context,object);
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Form(
            key: editProfileFormKey,
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(
                      10, 10, 10, 1
                  ),
                  height: 90,
                  child: TextFormField(
                    initialValue: item,
                    onSaved: (value) => item = value,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: objectToInfo(object),
                      fillColor: Colors.grey[300],
                      filled: true,),
                    validator: (String name) {
                      if (name.length == 0)
                        return '${objectToInfo(object)}을 입력해주세요.';
                      else
                        return null;
                    },
                  ),
                ),
              ],
            ),
          )
      ),
    );
  }
}