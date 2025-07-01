import "package:nav_monitor/constants/api_link.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import 'package:flutter/material.dart';
import "dart:convert";

Future<bool> LoginRequest(BuildContext context, String org_id, String username,
    String password) async {
  final storage = FlutterSecureStorage();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  ApiDetails api = MyApiDetails();
  final apiLink = api.apiLink;
  final url = Uri.parse('$apiLink/api/login');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'org_id': org_id,
        'username': username,
        'password': password,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 && body['accessToken'] != null) {
      try {
        await storage.write(key: 'accessToken', value: body['accessToken']);
        await storage.write(key: 'refreshToken', value: body['refreshToken']);
        await prefs.setString('org_id', org_id);
        await prefs.setString('username', username);
      } catch (e) {
        print("error while storing preferences $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful')),
      );

      return true; // ✅ success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Login failed. Please check your credentials.')),
      );
      return false; // ❌ login failed (invalid credentials or bad response)
    }
  } catch (e) {
    debugPrint('Login error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login error: $e')),
    );
    return false; // ❌ exception occurred
  }
}
