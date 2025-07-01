import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nav_monitor/constants/api_link.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchActivity() async {
  ApiDetails api = MyApiDetails();
  final apiLink = api.apiLink;

  try {
    final storage = FlutterSecureStorage();
    final prefs = await SharedPreferences.getInstance();

    final orgId = prefs.getString('org_id'); // ✅ Don't shadow function param
    if (orgId == null) {
      throw Exception('Organization ID is not set. Please log in again.');
    }

    final accessToken = await storage.read(key: 'accessToken');
    if (accessToken == null) {
      throw Exception('Access token is not set. Please log in again.');
    }

    final response = await http.get(
      Uri.parse("$apiLink/api/activity/$orgId"),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );

    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // 🔍 Adjust this based on your actual API structure
      if (jsonResponse is List) {
        return List<Map<String, dynamic>>.from(jsonResponse);
      } else if (jsonResponse['activities'] != null) {
        return List<Map<String, dynamic>>.from(jsonResponse['activities']);
      } else {
        throw Exception('Invalid response structure');
      }
    }

    if (response.statusCode == 401) {
      final refreshToken = await storage.read(key: 'refreshToken');
      if (refreshToken != null) {
        await _refreshAccessToken(refreshToken);
        return await fetchActivity(); // 🔁 retry after refresh
      } else {
        throw Exception('Unauthorized. No refresh token available.');
      }
    }

    throw Exception('Failed to load activity (${response.statusCode})');
  } catch (e) {
    print('Error fetching activity: $e');
    return [];
  }
}

// ✅ Token Refresh Function
Future<void> _refreshAccessToken(String refreshToken) async {
  final storage = FlutterSecureStorage();
  ApiDetails api = MyApiDetails();
  final apiLink = api.apiLink;

  final response = await http.post(
    Uri.parse("$apiLink/api/refresh"), // ✅ update if needed
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
