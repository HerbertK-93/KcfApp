import 'package:flutter/widgets.dart';
import 'package:kings_cogent/models/user.dart';
import 'package:kings_cogent/resources/auth_methods.dart';

class UserProvider with ChangeNotifier {
  AppUser? _user;
  final AuthMethods _authMethods = AuthMethods();

  AppUser get getUser => _user!;

  Future<void> refreshUser() async {
    AppUser? user =
        await _authMethods.getUserDetails(); // Change type to AppUser?
    _user = user;
    notifyListeners();
  }
}
