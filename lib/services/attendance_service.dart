import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class AttendanceService {
  static const String baseUrl = 'https://9d3d-36-70-95-221.ngrok-free.app/api';

  Future<http.Response> clockIn({
    required int employeeId,
    required int officeId,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    try {
      final body = jsonEncode({
        'employee_id': employeeId,
        'office_id': officeId,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'Hadir',
        'photo': photoBase64,
      });

      final token = await AuthService().getToken();

      final response = await http.post(
        Uri.parse('$baseUrl/admin/attendances'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Response: ${response.body}');
      return response;
    } catch (e) {
      print('Clock in error: $e');
      return http.Response('Failed to clock in', 500);
    }
  }

  Future<Map<String, dynamic>?> getTodayAttendance(int employeeId) async {
    try {
      final token = await AuthService().getToken();
      print('$baseUrl/admin/attendances/today/$employeeId');
      final response = await http.get(
        Uri.parse('$baseUrl/admin/attendances/today/$employeeId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
      return null;
    } catch (e) {
      print('Get today attendance error: $e');
      return null;
    }
  }

  Future<http.Response> clockOut({
    required int attendanceId,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    try {
      final body = jsonEncode({
        'clock_out': DateTime.now().toIso8601String(),
        'latitude_out': latitude,
        'longitude_out': longitude,
        'photo_out': photoBase64,
      });

      final token = await AuthService().getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/admin/attendances/$attendanceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Clock out response: ${response.body}');
      return response;
    } catch (e) {
      print('Clock out error: $e');
      return http.Response('Failed to clock out', 500);
    }
  }
}
