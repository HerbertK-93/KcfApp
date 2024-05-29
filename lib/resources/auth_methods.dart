import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kings_cogent/models/user.dart' as model;
import 'package:kings_cogent/resources/storage_methods.dart';
import 'package:kings_cogent/utils/shared_prefs.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.AppUser?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      if (!snap.exists || snap.data() == null) {
        return null;
      }
      return model.AppUser.fromSnap(snap);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<String> signUpUser({
    required String email,
    required String password,
    required String username,
    required String bio,
    required String whatsapp,
    required String ninPassport,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty || username.isNotEmpty || bio.isNotEmpty || whatsapp.isNotEmpty || ninPassport.isNotEmpty) {
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);

        String photoUrl = await StorageMethods().uploadImageToStorage('profilePics', file);

        model.AppUser user = model.AppUser(
          username: username,
          uid: cred.user!.uid,
          email: email,
          bio: bio,
          whatsapp: whatsapp,
          ninPassport: ninPassport,
          photoUrl: photoUrl,
        );

        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());
        res = "Success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        final data = await _auth.signInWithEmailAndPassword(email: email, password: password);

        final uid = data.user?.uid;
        if (uid != null) {
          await SharedPrefs().storeUid(uid);
        }

        res = "success";
      } else {
        res = "Please enter both email and password";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> resetPassword({required String email}) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty) {
        await _auth.sendPasswordResetEmail(email: email);
        res = "Password reset email sent";
      } else {
        res = "Please enter your email";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
