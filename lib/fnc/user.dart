import 'dart:io';

class User {
  String userName;
  String bio;
  String email;
  String userUid;
  String registerDate;
  String recentLoginDate;
  String role;

  User({this. userName, this.bio, this.email, this.userUid, this.registerDate, this.recentLoginDate, this.role});

  toJson(){
    return {
      "userName" : userName,
      "bio" : bio,
      "email" : email,
      "userUid" : userUid,
      "registerDate" : registerDate,
      "recentLoginDate" : recentLoginDate,
      "role" : role
    };
  }
}