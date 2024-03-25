import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kings_cogent/screens/profile_screen.dart';

const webScreenSize = 600;

List<Widget> homeScreenItems = [
  ProfileScreen(
    uid: FirebaseAuth.instance.currentUser!.uid,
  ),
];
