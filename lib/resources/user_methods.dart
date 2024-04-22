import 'package:cloud_firestore/cloud_firestore.dart';
import "package:kings_cogent/models/user.dart" as model;
import 'package:kings_cogent/utils/shared_prefs.dart';

class UserMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPrefs sharedPrefs;

  UserMethods({required this.sharedPrefs});

  Future<model.AppUser?> getUserProfile() async {
    final existingProfile = await sharedPrefs.getUser();
    if (existingProfile != null) {
      return existingProfile;
    }

    final uid = await sharedPrefs.getUid();
    if (uid == null) {
      return null;
    }

    QuerySnapshot querySnapshot =
        await _firestore.collection('users').where('uid', isEqualTo: uid).get();

    final data = querySnapshot.docs.first;
    if (data.data() == null) {
      return null;
    }

    final user = model.AppUser.fromSnap(querySnapshot.docs.first);
    await sharedPrefs.storeUserData(user);
    return user;
  }
}
