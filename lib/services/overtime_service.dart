import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/overtime_model.dart';
import 'auth_service.dart';

class OvertimeService {
  static const String baseUrl =
      'https://7928-36-77-243-75.ngrok-free.app/api/admin';

  Future<List<OvertimeModel>> getOvertimesByEmployee(int employeeId) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/overtime/employee/$employeeId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];
        return data.map((json) => OvertimeModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load overtimes');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> createOvertime(OvertimeModel overtime) async {
    final token = await AuthService().getToken();
    print('token => $token');
    if (token == null) throw Exception('No auth token found');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/overtimes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(overtime.toJson()),
      );
      print(overtime.toJson());
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create overtime');
      }
    } catch (e) {
      print('aaa test => $e');
      throw Exception('Error: $e');
    }
  }
}
