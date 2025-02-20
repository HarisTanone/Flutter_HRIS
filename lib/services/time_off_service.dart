import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../models/attendance_type.dart';
import '../models/time_off_request.dart';
import 'auth_service.dart';

class TimeOffService {
  static const String baseUrl =
      'https://7928-36-77-243-75.ngrok-free.app/api/admin';

  Future<List<AttendanceType>> getAttendanceTypes() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$baseUrl/attendance-types'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => AttendanceType.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load attendance types');
  }

  Future<List<TimeOffRequest>> getEmployeeTimeOffs(int employeeId) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$baseUrl/timeoff/employee/$employeeId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return (data['data'] as List)
          .map((json) => TimeOffRequest.fromJson(json))
          .toList();
    }
    throw Exception('Failed to load time off requests');
  }

  Future<void> createTimeOffRequest({
    required int employeeId,
    required DateTime startDate,
    required DateTime endDate,
    required int attendanceTypeId,
    required String reason,
    String? documentPath,
  }) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');

    var uri = Uri.parse('$baseUrl/time-offs');
    var request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    // print('url => $uri');
    request.fields.addAll({
      'employee_id': employeeId.toString(),
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'attendance_type_id': attendanceTypeId.toString(),
      'reason': reason,
      'status': 'Menunggu',
    });

    if (documentPath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'document',
        documentPath,
        contentType: MediaType('application', 'octet-stream'),
      ));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    print('response => $response');
    if (response.statusCode != 200) {
      throw Exception('Failed to create time off request: ${response.body}');
    }
  }
}
