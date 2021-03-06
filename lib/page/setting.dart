import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:stormed/fnc/preferencesData.dart';
import 'package:stormed/fnc/user.dart';
import 'package:stormed/fnc/versionCheck.dart';
import 'package:stormed/page/editProfile.dart';

class SettingPage extends StatefulWidget {
  @override
  SettingPageState createState() => SettingPageState();
}

class SettingPageState extends State<SettingPage> {
  ScrollController scrollController = ScrollController();
  VersionCheck versionCheck = VersionCheck();
  UserDBFNC userDBFNC = UserDBFNC();
  FirebaseUser currentUser;
  String userName;
  String description;
  String email;
  String userRole;
  String version;

  @override
  void initState() {
    super.initState();
    userDBFNC.getUser().then(
            (data) {
          currentUser = data;
          userDBFNC.getUserInfo(currentUser.uid).then(
                  (data) {
                if(this.mounted) {
                  setState(() {
                    userName = data.userName;
                    description = data.description;
                    userRole = data.role;
                    email = data.email;
                  });
                }
              }
          );
        }
    );
    versionCheck.getVersion().then((data) {
      setState(() {
        version = data.versionName;
      });
    });
  }

  _logOut(BuildContext context) {
    showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('정말 로그아웃 하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  userDBFNC.logout().then((_) {
                    setAutoLogin(false);
                    if(Navigator.canPop(context)) {
                      Navigator.popUntil(
                          context, ModalRoute.withName("/home"));
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  });

                }),
          ],
        );
      },
      context: context,
    );
  }

  removeAccount() {
    showDialog(
      builder: (context) {
        return AlertDialog(
          title: Text('정말 계정을 삭제하시겠습니까?'),
          actions: <Widget>[
            FlatButton(
                child: Text('취소'),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
            FlatButton(
                child: Text('확인'),
                onPressed: () {
                  Navigator.of(context).pop();
                  userDBFNC.deleteUser(currentUser: currentUser);
                  setAutoLogin(false);
                  if(Navigator.canPop(context)) {
                    Navigator.popUntil(
                        context, ModalRoute.withName("/home"));
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                }),
          ],
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("설정", style: TextStyle(color: Colors.black),),
      ),
      body: Container(
        color: Colors.white,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              child: Text("${userName??"불러오는 중..."} 님의 정보",
                style: TextStyle(fontSize: 18.0,
                    color: Colors.black),),
            ),
            ListTile(
              title: Text("닉네임"),
              trailing: Container(
                width: screenSize.width / 1.5,
                child: Text("${userName??"없음"}", overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.right,),
              ),
            ),
            ListTile(
              title: Text("한줄소개"),
              trailing: Container(
                width: screenSize.width / 1.5,
                child: Text("${description??"없음"}", overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.right,),
              ),
            ),
            ListTile(
              title: Text("이메일 주소"),
              trailing: Container(
                width: screenSize.width / 1.5,
                child: Text("${email??"없음"}", overflow: TextOverflow.ellipsis, maxLines: 1, textAlign: TextAlign.right,),
              ),
            ),
            ListTile(
              title: Text("회원 정보 수정"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(
                    builder: (_) => EditProfilePage(callback: () {
                      userDBFNC.getUserInfo(currentUser.uid).then(
                              (data) {
                            setState(() {
                              userName = data.userName;
                              description = data.description;
                              userRole = data.role;
                              email = data.email;
                            });
                          }
                      );
                    },)
                ));
              },
            ),
            Divider(color: Colors.grey,),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              child: Text("상태 설정",
                style: TextStyle(fontSize: 18.0,
                    color: Colors.black),),
            ),
            ListTile(
              title: Text("로그아웃"),
              onTap: () {_logOut(context);},
            ),
            ListTile(
              title: Text("탈퇴하기",style: TextStyle(color: Colors.red),),
              subtitle: Text("개인 정보가 모두 삭제됩니다"),
              onTap: () {removeAccount();},
            ),
            Divider(color: Colors.grey,),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              child: Text("앱 정보",
                style: TextStyle(fontSize: 18.0,
                    color: Colors.black),),
            ),
            ListTile(
              title: Text("버전"),
              trailing: Text("${version??"없음"}"),
            ),
            ListTile(
              title: Text("권한"),
              trailing: Text("${userRole??"없음"}"),
              onTap: (){
                if(userRole == "ADMIN") {
                  versionCheck.updateVersion();//버전 업데이트
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}