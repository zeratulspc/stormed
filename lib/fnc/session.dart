import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:stormed/fnc/user.dart';

enum SelectedMode { StrokeWidth, Opacity, Color }

class SessionFnc {
  final DatabaseReference sessionDBRef;// address : sessions/key
  SessionFnc({this.sessionDBRef});

  createSession(Session session) {

  }

  addStroke(String sessionId)
}

class Session {
  String title; // 제목
  String createdDate; // 생성일
  String hostUid; // 방장 UID
  String sessionId; // 세션 ID ( 파이어베이스에서 부여되는 key )
  List<String> members; // 참가자 UID
  List<Stroke> strokes;
  Session({this.title, this.createdDate, this.hostUid, this.members});

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
  String userUid; // 유저 아이디
  String brushType; // 브러쉬 굵기
  String colorCode; // 헥스값 색생 코드
  List<Offset> points;
  Stroke({this. userUid, this.brushType, this.colorCode, this.points});

  toJson(){
    List<Map> points =
    this.points != null ? this.points.map((i) => OffsetJson(offset: i).toJson()).toList() : null;
    return {
      "userUid" : userUid,
      "brushType" : brushType,
      "colorCode" : colorCode,
      "points" : points //TODO list to Json
    };
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
      "direction" : direction
    };
  }
}

class DrawingPainter extends CustomPainter {
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
  Paint paint;
  Offset points;
  DrawingPoints({this.paint, this.points});
}
