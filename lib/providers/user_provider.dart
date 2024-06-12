import 'package:flutter/widgets.dart';
import 'package:KcfApp/models/user.dart';
import 'package:KcfApp/resources/auth_methods.dart';
import 'package:KcfApp/utils/shared_prefs.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  final AuthMethods _authMethods = AuthMethods();

  AppUser? get getUser => _user;

  Future<void> refreshUser() async {
    try {
      String? uid = await SharedPrefs().getUid();
      if (uid == null) {
        print("No existing user profile found in SharedPrefs");
        return;
      }
      print("Retrieved UID from SharedPrefs: $uid");
      AppUser? user = await _authMethods.getUserDetails(uid);
      if (user == null) {
        print("No user data found in Firestore for UID: $uid");
      } else {
        _user = user;
        print("User Data Available: true");
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }
}
