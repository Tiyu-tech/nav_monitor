import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nav_monitor/constants/api_link.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchQuestions() async {
  try {
    ApiDetails api = MyApiDetails();
    final apiLink = api.apiLink;
    final storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: 'accessToken');
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('org_id');

    if (accessToken == null) {
      throw Exception('Access token is not set. Please log in again.');
    }

    final response = await http.get(
      Uri.parse("$apiLink/api/questions/$orgId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => Map<String, dynamic>.from(item)).toList();
    } else {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (response.statusCode == 401 && refreshToken != null) {
        Future<void> refreshAccessToken(String refreshToken) async {
          ApiDetails api = MyApiDetails();
          final apiLink = api.apiLink;
          final response = await http.post(
            Uri.parse("$apiLink/api/refresh"),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $refreshToken',
            },
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            await storage.write(key: 'accessToken', value: data['accessToken']);
          } else {
            throw Exception('Failed to refresh access token');
          }
        }

        await refreshAccessToken(refreshToken);
        return fetchQuestions(); // retry
      }
      throw Exception('Failed to load questions');
    }
  } catch (e) {
    print('Error fetching questions: $e');
    return [];
  }
}
