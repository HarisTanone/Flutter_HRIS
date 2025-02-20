import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/employee_model.dart';
import 'auth_service.dart';

class EmployeeService {
  final String baseUrl = 'https://7928-36-77-243-75.ngrok-free.app/api/admin';

  Future<EmployeeResponse> getEmployees() async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/employees'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return EmployeeResponse.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching employees: $e');
    }
  }

  Future<Employee> getEmployeeDetails(int id) async {
    final token = await AuthService().getToken();
    if (token == null) throw Exception('No auth token found');

    final response = await http.get(
      Uri.parse('$baseUrl/employees/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      return Employee.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load employee details');
    }
  }
}
