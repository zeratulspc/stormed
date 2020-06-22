import 'dart:ui';
import 'package:stack/stack.dart' as stk;
import 'package:flutter/material.dart';

import 'package:stormed/fnc/user.dart';
import 'package:stormed/fnc/session.dart';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';



class SessionDetail extends StatefulWidget {
  final User currentUser;
  final Session sessionInfo;
  SessionDetail(this.currentUser, this.sessionInfo);
    @override
    SessionDetailState createState() => SessionDetailState(currentUser, sessionInfo);
}

class SessionDetailState extends State<SessionDetail> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = List(); // 화면 표기용 리스트
  stk.Stack<String> strokeStacks = stk.Stack(); // 스트로크 순서 기록
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  Session sessionInfo;
  User currentUser;
  SessionDetailState(this.currentUser, this.sessionInfo);

  Query strokeQuery;

  SessionFnc sessionFnc;
  Stroke tempStroke;

  @override
  void initState(){
    super.initState();
    sessionFnc = SessionFnc(
        sessionDBRef: FirebaseDatabase.instance.reference().child("Session").child(sessionInfo.sessionId));
    sessionFnc.addMember(Members(
      key: currentUser.key,
      userName: currentUser.userName,
      recentLoginDate: DateTime.now().toIso8601String(),
    ));
    strokeQuery = FirebaseDatabase.instance.reference().child("Session").child(sessionInfo.sessionId).child("strokes");
    strokeQuery.onChildAdded.listen(onEntryAdded);
    strokeQuery.onChildChanged.listen(onEntryChanged);
    strokeQuery.onChildRemoved.listen(onEntryRemoved);
  }

  @override
  void dispose() {
    super.dispose();
    strokeQuery = null;
  }

  onEntryAdded(Event event) {
    Stroke snap = Stroke().fromSnapShot(event.snapshot);
    List<Offset> _points = snap.points;
    if(snap.points != null) {
        setState(() {
          for(int i = 0; i< _points.length;i++){
            points.add(DrawingPoints(
                strokeKey: snap.key,
                points: _points[i],
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = Color(snap.colorCode).withOpacity(snap.strokeOpacity)
                  ..strokeWidth = snap.strokeWidth
            ));
          }
          if(snap.userUid == currentUser.key || snap.userUid == sessionInfo.hostUid){
            strokeStacks.push(snap.key);
          }
          points.add(null);
        });
    }
  }

  onEntryChanged(Event event) {
    Stroke snap = Stroke().fromSnapShot(event.snapshot);
    List<Offset> _points = snap.points;
    if(snap.points != null) {
      if(this.mounted) {
        setState(() {
          for(int i = 0; i< _points.length;i++){
            points.add(DrawingPoints(
                strokeKey: snap.key,
                points: _points[i],
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = Color(snap.colorCode).withOpacity(snap.strokeOpacity)
                  ..strokeWidth = snap.strokeWidth
            ));
          }
          points.add(null);
        });
      }
    }
  }

  onEntryRemoved(Event event) {
    Stroke snap = Stroke().fromSnapShot(event.snapshot);
    if(snap.points != null) {
      if(this.mounted) {
        setState(() {
          points.removeWhere((points) {
            if(points != null) {
              return points.strokeKey == snap.key;
            } else {
              return false;
            }
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconColor = Colors.white;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding:  EdgeInsets.all(8.0),
        child: Container(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.black54),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: iconColor,
                          ),
                          onPressed: () {
                            if(strokeStacks.isNotEmpty){
                              sessionFnc.deleteStroke(strokeStacks.pop());
                            }
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.album,
                            color: iconColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.StrokeWidth)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.StrokeWidth;
                            });
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.opacity,
                            color: iconColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Opacity)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Opacity;
                            });
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.color_lens,
                            color: iconColor,
                          ),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Color)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Color;
                            });
                          }),
                      IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: currentUser.key == sessionInfo.hostUid ? iconColor : Colors.black87,
                          ),
                          onPressed: currentUser.key == sessionInfo.hostUid ? () {
                            setState(() {
                              showBottomList = false;
                              points.clear();
                              sessionFnc.clearBoard();
                            });
                          } : null),
                    ],
                  ),
                  Visibility(
                    child: (selectedMode == SelectedMode.Color)
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: getColorList(),
                    )
                        : Slider(
                        value: (selectedMode == SelectedMode.StrokeWidth)
                            ? strokeWidth
                            : opacity,
                        max: (selectedMode == SelectedMode.StrokeWidth)
                            ? 50.0
                            : 1.0,
                        min: 0.0,
                        onChanged: (val) {
                          setState(() {
                            if (selectedMode == SelectedMode.StrokeWidth)
                              strokeWidth = val;
                            else
                              opacity = val;
                          });
                        }),
                    visible: showBottomList,
                  ),
                ],
              ),
            )),
      ),
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            tempStroke = Stroke(
                strokeOpacity: opacity,
                strokeWidth: strokeWidth,
                colorCode: selectedColor.value,
                userUid: currentUser.key,
                points: List(),
            );
            tempStroke.key = sessionFnc.addStroke(tempStroke);
            tempStroke.points.add(renderBox.globalToLocal(details.globalPosition));
            points.add(DrawingPoints(
                strokeKey: tempStroke.key,
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject();
            tempStroke.points.add(renderBox.globalToLocal(details.globalPosition));
            points.add(DrawingPoints(
                strokeKey: tempStroke.key,
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeCap
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          strokeStacks.push(tempStroke.key);
          sessionFnc.updateStroke(tempStroke);
          setState(() {
            points.add(null);
          });
        },
        child: CustomPaint(
          size: Size.infinite,
          painter: DrawingPainter(
            pointsList: points,
          ),
        ),
      ),
    );
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          child: AlertDialog(
            title: Text('색을 고르세요!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('저장'),
                onPressed: () {
                  setState(() => selectedColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink,  Colors.blue],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
}