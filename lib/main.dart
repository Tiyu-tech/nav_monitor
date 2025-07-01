import 'package:flutter/material.dart';
import 'package:nav_monitor/pages/home_page.dart';
import 'package:nav_monitor/pages/login_page.dart';
import 'package:nav_monitor/pages/question_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      title: 'M & E',
      theme: ThemeData(
        //
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 58, 102, 183)),
        useMaterial3: true,
      ),
      home: CheckIfUserIsLoggedIn(),
      routes: {
        "/home": (context) => HomePage(),
      },
    );
  }
}

class CheckIfUserIsLoggedIn extends StatelessWidget {
  const CheckIfUserIsLoggedIn({super.key});

  Future<bool> _isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('org_id');
    return orgId != null && orgId.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data!) {
          return const HomePage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
