import 'dart:io';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class AttendanceService {
  static const String baseUrl = 'https://f1f0-36-70-93-80.ngrok-free.app/api';

  Future<bool> clockIn({
    required int employeeId,
    required int officeId,
    required double latitude,
    required double longitude,
    required File photo,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/admin/attendances'),
      );

      // Add text fields
      request.fields.addAll({
        'employee_id': employeeId.toString(),
        'office_id': officeId.toString(),
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'status': 'Hadir',
      });

      // Add photo
      request.files.add(
        await http.MultipartFile.fromPath('photo', photo.path),
      );

      // Add token to headers
      final token = await AuthService().getToken();
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      var response = await request.send();
      return response.statusCode == 200;
    } catch (e) {
      print('Clock in error: $e');
      return false;
    }
  }
}
