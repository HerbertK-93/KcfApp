import 'package:KcfApp/providers/savings_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // <-- Added Firestore import
import 'package:KcfApp/providers/daily_provider.dart';
import 'package:KcfApp/providers/once_provider.dart';
import 'package:KcfApp/providers/weekly_provider.dart';
import 'package:KcfApp/providers/deposit_provider.dart';
import 'package:KcfApp/providers/user_provider.dart';
import 'package:KcfApp/providers/transaction_provider.dart';
import 'package:KcfApp/screens/splashscreen.dart';
import 'package:KcfApp/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart'; // <-- Import for handling permissions

import 'responsive/mobile_screen_layout.dart';
import 'screens/password_screen.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyBQCrbMLwMAxgK8Aky5RfkQE8bmquRplnQ',
      authDomain: 'kings-cogent-finance-ltd-ecab6.firebaseapp.com',
      projectId: 'kings-cogent-finance-ltd-ecab6',
      storageBucket: 'kings-cogent-finance-ltd-ecab6',
      messagingSenderId: '589265652458',
      appId: '1:589265652458:web:3787a3dcf5d0e4eb49e593',
    ),
  );

  // Request storage permission
  await _requestStoragePermission(); // <-- Request storage permission during app start

  // Listen to authentication state changes
  FirebaseAuth.instance.authStateChanges().listen((User? user) async {
    if (user != null) {
      // User is logged in, generate and store FCM token
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // Request notification permissions when the user signs in for the first time
      NotificationSettings settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print("User granted notification permission");

        // Get the FCM token and store it in Firestore
        String? token = await messaging.getToken();
        if (token != null) {
          print("FCM Token: $token");

          // Store the token in Firestore under the user's profile
          await storeFCMToken(token);
        }
      } else {
        print("User denied notification permission");
      }

      // Listen for foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Received a message in the foreground!');
        print('Message data: ${message.data}');

        if (message.notification != null) {
          print('Notification title: ${message.notification?.title}');
          print('Notification body: ${message.notification?.body}');
        }
      });
    } else {
      print("User signed out, no FCM token will be stored.");
    }
  });

  // Background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

// Function to request storage permission
Future<void> _requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    status = await Permission.storage.request();
  }

  if (status.isDenied || status.isPermanentlyDenied) {
    // Optionally handle the scenario where permission is denied
    print("Storage permission denied.");
  } else {
    print("Storage permission granted.");
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}

// Function to store FCM token in Firestore
Future<void> storeFCMToken(String token) async {
  try {
    // Get the current user's UID (assuming Firebase Authentication is used)
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      // Update the user's profile with the FCM token
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'fcmToken': token,
      });
      print("FCM Token saved to Firestore");
    } else {
      print("No user logged in");
    }
  } catch (e) {
    print("Error storing FCM token: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => DepositProvider()),
        ChangeNotifierProvider(create: (_) => WeeklyProvider()),
        ChangeNotifierProvider(create: (_) => DailyProvider()),
        ChangeNotifierProvider(create: (_) => OnceProvider()),
        ChangeNotifierProvider(create: (_) => SavingsProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Kings Cogent',
            themeMode: ThemeMode.system,
            theme: ThemeData.light().copyWith(scaffoldBackgroundColor: Colors.white),
            darkTheme: ThemeData.dark().copyWith(),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(1.0)),
                child: child!,
              );
            },
            home: const SplashScreen(),
            routes: {
              '/password': (context) => PasswordScreen(),
              '/home': (context) => const MobileScreenLayout(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
