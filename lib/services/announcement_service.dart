import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/announcement_model.dart';
import 'auth_service.dart';

class AnnouncementService {
  static const String baseUrl =
      'https://7928-36-77-243-75.ngrok-free.app/api/admin/announcements';

  // Get all announcements
  Future<List<Announcement>> getAnnouncements() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Announcement.fromJsonList(data['data']);
    } else {
      throw Exception('Failed to load announcements');
    }
  }

  // Get single announcement by ID
  Future<Announcement> getAnnouncementById(int id) async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Announcement.fromJson(data['data']);
    } else {
      throw Exception('Failed to load announcement');
    }
  }
}
