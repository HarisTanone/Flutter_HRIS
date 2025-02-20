import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/attendance_model.dart';
import 'auth_service.dart';

class AttendanceService {
  static const String baseUrl = 'https://7928-36-77-243-75.ngrok-free.app/api';

  Future<Map<String, dynamic>> clockIn({
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

      final Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'status': response.statusCode,
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'status': 500,
        'message': 'Failed to clock in: $e',
        'data': null,
      };
    }
  }

  Future<Map<String, dynamic>?> getTodayAttendance(int employeeId) async {
    try {
      final token = await AuthService().getToken();
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
      return null;
    }
  }

  Future<Map<String, dynamic>> clockOut({
    required int attendanceId,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    try {
      final body = jsonEncode({
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

      final Map<String, dynamic> responseData = json.decode(response.body);
      return {
        'status': response.statusCode,
        'message': responseData['message'],
        'data': responseData['data'],
      };
    } catch (e) {
      return {
        'status': 500,
        'message': 'Failed to clock out: $e',
        'data': null,
      };
    }
  }

  static Future<AttendanceData> getMonthlyAttendance(
      int employeeId, String month) async {
    try {
      final token = await AuthService().getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/attendance/monthly/$employeeId/$month'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return AttendanceData.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Tidak Ada Data Absensi Bulan Ini');
      }
    } catch (e) {
      print('Get monthly attendance error: $e');
      throw Exception('Tidak Ada Data Absensi Bulan Ini');
    }
  }
}
