import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/employee_model.dart';
import '../services/employee_service.dart';
import '../widgets/appbar_widget.dart';

class EmployeeScreen extends StatefulWidget {
  const EmployeeScreen({super.key});

  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  final String api_url = "https://7928-36-77-243-75.ngrok-free.app/";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    try {
      final response = await _employeeService.getEmployees();
      setState(() {
        _employees = response.data; // response.data berisi List<Employee>
        _filteredEmployees = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employees: $e')),
      );
    }
  }

  void _filterEmployees(String query) {
    setState(() {
      _filteredEmployees = _employees
          .where((employee) =>
              employee.fullName.toLowerCase().contains(query.toLowerCase()) ||
              employee.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _showEmployeeDetails(Employee employee) async {
    try {
      final employeeDetails =
          await _employeeService.getEmployeeDetails(employee.id);
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) => _buildEmployeeDetailsSheet(
            employeeDetails,
            scrollController,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading employee details: $e')),
      );
    }
  }

  Widget _buildEmployeeDetailsSheet(
    Employee employee,
    ScrollController scrollController,
  ) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: employee.photo != null
                    ? NetworkImage('${api_url}storage/${employee.photo}')
                    : null,
                child: employee.photo == null
                    ? Text(
                        employee.fullName.substring(0, 2).toUpperCase(),
                        style: const TextStyle(fontSize: 30),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),
            _buildDetailItem('Full Name', employee.fullName),
            _buildDetailItem('Email', employee.email),
            _buildDetailItem('Phone', employee.mobilePhone),
            _buildDetailItem('Birth Place', employee.placeOfBirth),
            _buildDetailItem('Birth Date', employee.birthdate),
            _buildDetailItem('Gender', employee.gender),
            // _buildDetailItem('Religion', employee.religion),
            _buildDetailItem('NIK', employee.nik),
            _buildDetailItem('Address', employee.residentialAddress),
            _buildDetailItem('Join Date', employee.joinDate),
            _buildDetailItem('Office', employee.officeId.officeName),
            _buildDetailItem('Manager', getManagerName(employee.managerId)),
            // _buildDetailItem('Manager', employee.managerId.full_name),
          ],
        ),
      ),
    );
  }

  String getManagerName(dynamic managerId) {
    if (managerId is Map<String, dynamic>) {
      return managerId['full_name'] ?? 'No manager name';
    }
    return 'No manager';
  }

// Contoh penggunaan di widget
// Text(getManagerName(employee.managerId))
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: 'Employees',
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _filterEmployees,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEmployees,
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: InkWell(
                            onTap: () => _showEmployeeDetails(employee),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundImage: employee.photo != null
                                        ? NetworkImage(
                                            '${api_url}storage/${employee.photo}')
                                        : null,
                                    child: employee.photo == null
                                        ? Text(
                                            employee.fullName
                                                .substring(0, 2)
                                                .toUpperCase(),
                                            style:
                                                const TextStyle(fontSize: 20),
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          employee.fullName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          employee.email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.phone,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _launchUrl(
                                            'tel:${employee.mobilePhone}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.email,
                                          color: Color(0xFF900C0C),
                                        ),
                                        onPressed: () => _launchUrl(
                                            'mailto:${employee.email}'),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.mobile_screen_share,
                                          color: Colors.green,
                                        ),
                                        onPressed: () => _launchUrl(
                                            'https://wa.me/${employee.mobilePhone}'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
