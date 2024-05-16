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
      print('Returning existing user profile from SharedPrefs');
      return existingProfile;
    } else {
      print('No existing user profile found in SharedPrefs');
    }

    final uid = await sharedPrefs.getUid();
    if (uid == null) {
      print('UID not found in SharedPrefs');
      return null; // Handle the case where UID is not available
    } else {
      print('Retrieved UID from SharedPrefs: $uid');
    }

    QuerySnapshot querySnapshot =
        await _firestore.collection('users').where('uid', isEqualTo: uid).get();

    if (querySnapshot.docs.isEmpty) {
      print('No user data found in Firestore for UID: $uid');
      return null; // Handle the case where no user data is found for the given UID
    } else {
      print('Found user data in Firestore for UID: $uid');
    }

    final data = querySnapshot.docs.first;
    if (data.data() == null) {
      print('Data retrieved from Firestore is null for UID: $uid');
      return null;
    } else {
      print('Data retrieved from Firestore for UID: $uid (not null)');
    }

    final user = model.AppUser.fromSnap(data);
    await sharedPrefs.storeUserData(user);
    return user;
  }
}