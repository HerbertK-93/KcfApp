import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String username;
  final String uid;
  final String email;
  final String photoUrl;
  final String bio;
  final String? whatsapp;
  final String? ninPassport;

  const AppUser({
    required this.username,
    required this.uid,
    required this.email,
    required this.photoUrl,
    required this.bio,
    this.whatsapp,
    this.ninPassport,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
        "whatsapp": whatsapp,
        "ninPassport": ninPassport,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      username: json['username'],
      uid: json['uid'],
      email: json['email'],
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      whatsapp: json['whatsapp'],
      ninPassport: json['ninPassport'],
    );
  }

  static AppUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>?;
    if (snapshot == null) {
      throw Exception("User data is null");
    }
    return AppUser(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
      whatsapp: snapshot["whatsapp"],
      ninPassport: snapshot["ninPassport"],
    );
  }
}
