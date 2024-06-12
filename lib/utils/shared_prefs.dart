import 'dart:convert';
import 'package:KcfApp/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs() {
    () async {
      sharedPreferences = await SharedPreferences.getInstance();
    }();
  }

  SharedPreferences? sharedPreferences;
  static const String tagUid = 'uid';
  static const String tagUserData = 'user-data';
  static const String tagNinPassport = 'ninPassport';

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

  Future storeNinPassport(final String ninPassport) async {
    sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences?.setString(tagNinPassport, ninPassport);
  }

  Future<String?> getNinPassport() async {
    sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences?.getString(tagNinPassport);
  }

  Future<double?> getMonthlySavings() async {
    return null;
  }

  Future<double?> getWeeklySavings() async {
    return null;
  }

  Future<double?> getDailySavings() async {
    return null;
  }

  Future<double?> getOneTimeSavings() async {
    return null;
  }
}
