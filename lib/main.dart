import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

import 'responsive/mobile_screen_layout.dart';
import 'screens/password_screen.dart';

// Import the datetime package
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  // await dotenv.load(fileName: ".env");

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

  // Example of automatically detecting the current date
  DateTime currentDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);
  print('Current Date: $formattedDate'); // This will log the date to the console

  runApp(const MyApp());
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
