import 'dart:convert';

import 'package:kings_cogent/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs() {
    // ignore: discarded_futures
    () async {
      sharedPreferences = await SharedPreferences.getInstance();
    }();
  }

  SharedPreferences? sharedPreferences;
  static const String tagUid = 'uid';
  static const String tagUserData = 'user-data';

  Future storeUid(final String uid) async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences?.setString(tagUid, uid);
  }

  Future<String?> getUid() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getString(tagUid);
  }

  Future storeUserData(AppUser user) async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences?.setString(tagUserData, jsonEncode(user.toJson()));
  }

  Future<AppUser?> getUser() async {
    sharedPreferences = await SharedPreferences.getInstance();
    final data = sharedPreferences?.getString(tagUserData);
    if (data == null) {
      return null;
    }
    return AppUser.fromJson(jsonDecode(data));
  }

  Future logoutApp() async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences?.remove(tagUid);
    await sharedPreferences?.remove(tagUserData);
  }

  Future<double?> getMonthlySavings() async {
    // Implement method to retrieve monthly savings from SharedPrefs
  }

  Future<double?> getWeeklySavings() async {
    // Implement method to retrieve weekly savings from SharedPrefs
  }

  Future<double?> getDailySavings() async {
    // Implement method to retrieve daily savings from SharedPrefs
  }

  Future<double?> getOneTimeSavings() async {
    // Implement method to retrieve one-time savings from SharedPrefs
  }
}
