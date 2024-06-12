import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String firstName;
  final String lastName;
  final String uid;
  final String email;
  final String? whatsapp;
  final String? ninPassport;

  const AppUser({
    required this.firstName,
    required this.lastName,
    required this.uid,
    required this.email,
    this.whatsapp,
    this.ninPassport,
  });

  Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
        "uid": uid,
        "email": email,
        "whatsapp": whatsapp,
        "ninPassport": ninPassport,
      };

  static AppUser fromJson(Map<String, dynamic> json) {
    return AppUser(
      firstName: json['firstName'],
      lastName: json['lastName'],
      uid: json['uid'],
      email: json['email'],
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
      firstName: snapshot["firstName"],
      lastName: snapshot["lastName"],
      uid: snapshot["uid"],
      email: snapshot["email"],
      whatsapp: snapshot["whatsapp"],
      ninPassport: snapshot["ninPassport"],
    );
  }
}
