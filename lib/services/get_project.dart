import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:nav_monitor/constants/api_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchProject() async {
  try {
    ApiDetails api = MyApiDetails();
    final apiLink = api.apiLink;
    final storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();
    final orgId = prefs.getString('org_id');
    if (orgId == null) {
      // Organization ID is not set; handle this error appropriately in the UI layer
      throw Exception('Organization ID is not set. Please log in again.');
    }
    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      // Access token is not set; handle this error appropriately in the UI layer
      throw Exception('Access token is not set. Please log in again.');
    }
    final response = await http.get(
      Uri.parse("$apiLink/api/project/$orgId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken'
      },
    );
    print('[fetchProject] Status Code: ${response.statusCode}');
    print('[fetchProject] Response Body: ${response.body}');
    if (response.statusCode == 200) {
      final body = json.decode(response.body);

      // Ensure it's a List of Map<String, dynamic>
      final List<Map<String, dynamic>> projectList =
          List<Map<String, dynamic>>.from(body);

      print('[fetchProject] Parsed Projects: $projectList');
      return projectList;
    } else {
      final storage = FlutterSecureStorage();
      final refreshToken = await storage.read(key: 'refreshToken');
      if (response.statusCode == 401 && refreshToken != null) {
        // Handle token refresh logic here
        // For example, call a function to refresh the token and retry the request
        Future<void> refreshAccessToken(String refreshToken) async {
          final response = await http.post(
            Uri.parse("http://192.168.195.238:3000/api/refresh"),
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
        // Then retry fetching projects
        return fetchProject();
      }
      throw Exception('Failed to load projects');
    }
  } catch (e) {
    print('Error fetching projects: $e');

    return [
      {"hasError": true, "message": e.toString()}
    ];
  }
}
