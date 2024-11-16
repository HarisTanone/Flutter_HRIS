import 'dart:convert';

import 'package:http/http.dart' as http;

import 'auth_service.dart';

class AttendanceService {
  static const String baseUrl = 'https://60b1-175-158-56-88.ngrok-free.app/api';

  Future<http.Response> clockIn({
    required int employeeId,
    required int officeId,
    required double latitude,
    required double longitude,
    required String photoBase64,
  }) async {
    try {
      // Data yang akan dikirim ke API
      final body = jsonEncode({
        'employee_id': employeeId,
        'office_id': officeId,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'Hadir',
        'photo': photoBase64,
      });

      // Mendapatkan token autentikasi
      final token = await AuthService().getToken();

      // Permintaan HTTP POST
      final response = await http.post(
        Uri.parse('$baseUrl/admin/attendances'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('Response: ${response.body}'); // Untuk debugging

      // Mengembalikan response untuk memproses status code dan body di tempat lain
      return response;
    } catch (e) {
      print('Clock in error: $e');
      // Jika terjadi error pada request, kembalikan response dengan status 500
      return http.Response('Failed to clock in', 500);
    }
  }
}
