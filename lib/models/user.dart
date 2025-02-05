import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String email;
  final String uid;
  final String photoUrl;
  final String username;
  final String bio;

  const AppUser({
    required this.username,
    required this.uid,
    required this.photoUrl,
    required this.email,
    required this.bio,
  });

  Map<String, dynamic> toJson() => {
        "username": username,
        "uid": uid,
        "email": email,
        "photoUrl": photoUrl,
        "bio": bio,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      photoUrl: json['photoUrl'],
      bio: json['bio'],
      email: json['email'],
      username: json['username'],
    );
  }

  static AppUser fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return AppUser(
      username: snapshot["username"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      photoUrl: snapshot["photoUrl"],
      bio: snapshot["bio"],
    );
  }
}
