import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class EmployeeSidebar extends StatefulWidget {
  const EmployeeSidebar({super.key});

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<EmployeeSidebar> {
  Employee? _employee;
  bool _isLoading = false;

  // Define the new color scheme
  final List<Color> gradientColors = const [
    Color(0xFF900C0C), // Red
    Color(0xFF22577A), // Blue
  ];

  final Color backgroundColor = const Color(0xFFF8F7F2); // Light Beige

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService().getUserData();
      if (user != null && user.employee != null) {
        setState(() {
          _employee = user.employee;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _logout() async {
    setState(() {
      _isLoading = true;
    });

    await AuthService().logout();

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: _employee == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: gradientColors[0],
                  child: UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                    ),
                    accountName: Text(
                      _employee!.fullName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    accountEmail: Text(
                      _employee!.email,
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundImage: _employee!.photo != null
                          ? NetworkImage(
                              'https://7928-36-77-243-75.ngrok-free.app/storage/${_employee!.photo}')
                          : const AssetImage('assets/default_avatar.png')
                              as ImageProvider,
                    ),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.work, color: gradientColors[0]),
                  title: Text(
                    _employee!.officeId.officeName,
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gradientColors[0],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _logout,
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
