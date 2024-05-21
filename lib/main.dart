// ignore_for_file: prefer_const_constructors, unnecessary_import

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kings_cogent/screens/splashscreen.dart';
import 'package:provider/provider.dart';

import 'package:kings_cogent/providers/user_provider.dart';
import 'package:kings_cogent/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBQCrbMLwMAxgK8Aky5RfkQE8bmquRplnQ',
      authDomain: 'kings-cogent-finance-ltd-ecab6.firebaseapp.com',
      projectId: 'kings-cogent-finance-ltd-ecab6',
      storageBucket: 'kings-cogent-finance-ltd-ecab6.appspot.com',
      messagingSenderId: '589265652458',
      appId: '1:589265652458:web:3787a3dcf5d0e4eb49e593',
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kings Cogent',
        themeMode: ThemeMode.system, // Enable system theme mode
        theme: ThemeData.light().copyWith(
          scaffoldBackgroundColor: Colors.white,
        ),
        darkTheme: ThemeData.dark().copyWith(
            // Customize dark theme if needed
        ),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
            child: child!,
          );
        },
        routes: {
          '/login': (context) => const LoginScreen(),
        },
        home: const SplashScreen(), // Set SplashScreen as the home screen
      ),
    );
  }
}
