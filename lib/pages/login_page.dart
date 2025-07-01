//beautiful login page in flutter
import 'package:flutter/material.dart';
import 'package:nav_monitor/services/sqlite_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nav_monitor/components/buttons.dart';
import 'package:nav_monitor/constants/fonts.dart';
import 'package:nav_monitor/services/login.dart';
import 'package:nav_monitor/pages/home_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController orgIdController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Login',
            style: headline1,
            textAlign: TextAlign.center,
          ),
        ),
        body: SafeArea(
          child: Center(
              child: Padding(
            padding: const EdgeInsets.all(38.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //button to clear the secure storage and shared preferences
                  ElevatedButton(
                    onPressed: () async {
                      final storage = FlutterSecureStorage();

                      try {
                        await DatabaseService().deleteDatabaseFile();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Database deleted")));
                        await storage.deleteAll();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Secure Storage Cleared')),
                        );
                        final SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        if (await prefs.clear()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Shared Preferences Cleared')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Error clearing Shared Preferences')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error clearing storage')),
                        );
                      }
                    },
                    child: Text('Clear Storage'),
                  ),
                  SizedBox(height: 20),
                  Image(
                    image: AssetImage('assets/images/logo.png'),
                    height: 150,
                    width: 150,
                  ),
                  SizedBox(height: 40),
                  TextField(
                    controller: orgIdController,
                    decoration: InputDecoration(
                      labelText: 'Organization ID',
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your Organization Id',
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: userNameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      helperText: "",
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your user Name',
                    ),
                  ),
                  SizedBox(height: 30),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      hintText: 'Enter Your user password',
                      helperText: "",
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: FormButton(
                      text: 'Login',
                      onPressed: () async {
                        //check if the fields are empty
                        if (orgIdController.text.isEmpty ||
                            userNameController.text.isEmpty ||
                            passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please fill all fields')),
                          );
                          return;
                        }
                        final success = await LoginRequest(
                          context,
                          orgIdController.text,
                          userNameController.text,
                          passwordController.text,
                        );

                        if (success) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => HomePage()),
                          );
                          await DatabaseService().InitDatabase();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login Successful')),
                          );
                          // Navigate to home screen
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Login failed')),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )),
        ));
  }
}
