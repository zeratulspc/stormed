import 'dart:collection';
import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:stormed/fnc/user.dart';

enum SelectedMode { StrokeWidth, Opacity, Color }

class SessionFnc {
  final DatabaseReference sessionDBRef;// address : sessions/key
  SessionFnc({this.sessionDBRef});

  String createSession(Session session) {
    session.sessionId = FirebaseDatabase.instance.reference().child("Session").push().key;
    FirebaseDatabase.instance.reference().child("Session").child(session.sessionId).set(session.toJson());
    return session.sessionId;
  }

  String addStroke(Stroke stroke) {
    stroke.key = sessionDBRef.child("strokes").push().key;
    sessionDBRef.child("strokes").child(stroke.key).set(stroke.toJson());
    return stroke.key;
  }

  deleteSession(String sessionId) {
    FirebaseDatabase.instance.reference().child("Session").child(sessionId).remove();
  }

  addMember(Members members) {
    sessionDBRef.child("members").child(members.key).set(members.toMap());
  }
  
  deleteMember(String sessionId, String userUid) {
    FirebaseDatabase.instance.reference().child("Session").child(sessionId).child("members").child(userUid).remove();
  }

  updateSession(Session session) {
    sessionDBRef.set(session.toJson());
  }

  updateStroke(Stroke stroke) {
    sessionDBRef.child("strokes").child(stroke.key).set(stroke.toJson());
  }

  clearBoard(){
    sessionDBRef.child("strokes").remove();
  }

  deleteStroke(String strokeKey) {
    sessionDBRef.child("strokes").child(strokeKey).remove();
  }
}

class Members {
  String key; // KEY == UID
  String userName; // 닉네임
  String recentLoginDate; // 최근 로그인 날짜
  String role; // GUEST, MEMBER, ADMIN

  Members({this.key,this.userName, this.recentLoginDate, this.role});

  Members.fromLinkedHashMap(LinkedHashMap linkedHashMap)
      :key = linkedHashMap["key"],
        userName = linkedHashMap["userName"],
        recentLoginDate = linkedHashMap["recentLoginDate"],
        role = linkedHashMap["role"];

  Members.fromSnapShot(DataSnapshot snapshot)
      :key = snapshot.key,
        userName = snapshot.value["userName"],
        recentLoginDate = snapshot.value["recentLoginDate"],
        role = snapshot.value["role"];

  toMap() {
    return {
      "key" : key,
      "userName" : userName,
      "recentLoginDate" : recentLoginDate,
      "role" : role,
    };
  }

  factory Members.fromJson(dynamic parsedJson) {
    return Members(
      key: parsedJson["key"],
      userName: parsedJson["userName"],
      recentLoginDate: parsedJson["recentLoginDate"],
      role: parsedJson["role"],
    );
  }

}

class Session {
  String title; // 제목
  String createdDate; // 생성일
  String hostUid; // 방장 UID
  String sessionId; // 세션 ID ( 파이어베이스에서 부여되는 key )
  List<Members> members; // 참가자 UID
  List<Stroke> strokes; // 획

  User hostInfo; // local 전용
  Session({this.title, this.createdDate, this.hostUid, this.members, this.strokes, this.sessionId});

  fromSnapShot(DataSnapshot snapshot) {
    var _strokeListSnapshot = snapshot.value["strokes"] as LinkedHashMap;
      List<Stroke> _strokeList;
      if(_strokeListSnapshot != null) {
        _strokeList = List();
        _strokeListSnapshot.forEach((key, value) {
          _strokeList.add(Stroke.fromJson(value));
        });
      }
    var _memberListSnapshot = snapshot.value["members"] as LinkedHashMap;
    List<Members> _membersList;
    if(_memberListSnapshot != null) {
      _membersList = List();
      _memberListSnapshot.forEach((key, value) {
        _membersList.add(Members.fromJson(value));
      });
    }

    return Session(
      title: snapshot.value["title"],
      createdDate: snapshot.value["createdDate"],
      hostUid: snapshot.value["hostUid"],
      sessionId: snapshot.value["sessionId"],
      members: _membersList,
      strokes:_strokeList,
    );
  }

  toJson(){
    List<Map> strokes =
        this.strokes != null ? this.strokes.map((i) => i.toJson()).toList() : null;
    return {
      "title" : title,
      "createdDate" : createdDate,
      "hostUid" : hostUid,
      "sessionId" : sessionId,
      "members" : members,
      "strokes" : strokes
    };
  }

}

class Stroke {
  String key;
  String userUid; // 유저 아이디
  int colorCode; // 헥스값 색상 코드
  double strokeWidth; // 브러쉬 굵기
  double strokeOpacity; //브러쉬 불투명도
  List<Offset> points;
  Stroke({this.key, this. userUid, this.strokeWidth, this.colorCode, this.points, this.strokeOpacity});

  toJson(){
    List<dynamic> points =
    this.points != null ? this.points.map((i) => OffsetJson(offset: i).toJson()).toList() : null;
    return {
      "key" : key,
      "userUid" : userUid,
      "strokeOpacity" : strokeOpacity,
      "strokeWidth" : strokeWidth,
      "colorCode" : colorCode,
      "points" : points
    };
  }

  fromSnapShot(DataSnapshot snapshot) {
    var list = snapshot.value["points"] as List;
    List<Offset> _points;
    if(list != null) {
      _points = list.map((i) => Offset(double.parse(i["dx"].toString()), double.parse(i["dy"].toString()))).toList();
    }

    return Stroke(
      key: snapshot.key,
      userUid: snapshot.value["userUid"],
      strokeOpacity: double.parse(snapshot.value["strokeOpacity"].toString()),
      strokeWidth: double.parse(snapshot.value["strokeWidth"].toString()),
      colorCode: snapshot.value["colorCode"],
      points: _points,
    );
  }

  factory Stroke.fromJson(dynamic parsedJson){
    var list = parsedJson['points'] as List;
    List<Offset> _points;
    if(list != null) {
      _points = list.map((i) => Offset(double.parse(i["dx"].toString()), double.parse(i["dy"].toString()))).toList();
    }

    return Stroke(
      key: parsedJson["key"],
      userUid: parsedJson["userUid"],
      strokeOpacity: double.parse(parsedJson["strokeOpacity"].toString()),
      strokeWidth: double.parse(parsedJson["strokeWidth"].toString()),
      colorCode: parsedJson["colorCode"],
      points: _points,
    );
  }
}

class OffsetJson{
  Offset offset;
  double get dx => offset.dx;
  double get dy => offset.dy;
  double get distance => offset.distance;
  double get distanceSquared => offset.distanceSquared;
  double get direction => offset.direction;
  OffsetJson({@required this.offset});

  toJson(){
    return{
      "dx" : dx,
      "dy" : dy,
      "distance" : distance,
      "distanceSquared" : distanceSquared,
      "direction" : direction,
    };
  }
}

class DrawingPainter extends CustomPainter { //TODO 지우개 구현
  DrawingPainter({this.pointsList});
  List<DrawingPoints> pointsList;
  List<Offset> offsetPoints = List();

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].points, pointsList[i + 1].points,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i].points);
        offsetPoints.add(Offset(
            pointsList[i].points.dx + 0.1, pointsList[i].points.dy + 0.1));
        canvas.drawPoints(PointMode.points, offsetPoints, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(DrawingPainter oldDelegate) => true;
}

class DrawingPoints {
  String strokeKey;
  Paint paint;
  Offset points;
  DrawingPoints({this.strokeKey, this.paint, this.points});
}
