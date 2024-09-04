import 'package:flutter/material.dart';
import 'package:parentsapp/screens/firebase_notifications%20.dart';
import 'package:parentsapp/screens/welcome_screen.dart';
import 'package:parentsapp/theme/theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyAHclLcONExMUaxMcTGqKFrBNzsgHXtXeM',
      appId: '1:362796096790:android:a46fad9886e2411a7ec437',
      messagingSenderId: '362796096790',
      projectId: 'studentsystem-b31c2',
      storageBucket: 'studentsystem-b31c2.appspot.com',
    ),
  );
  await FirebaseNotifications().initNoifications();
  runApp(MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: lightMode,
      home: const WelcomeScreen(),
    );
  }
}
