import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../screens/employee_screen.dart';
import '../screens/login_screen.dart';
import '../screens/overtime_screen.dart';
import '../screens/time_off_request_screen.dart';
import '../services/auth_service.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _currentIndex = 0;
  final AuthService _authService = AuthService();
  User? _currentUser;

  // Define gradient colors
  final List<Color> gradientColors = const [
    Color(0xFF900C0C),
    Color(0xFFd40101),
    Color(0xFFff5a5a),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _onItemTapped(int index, BuildContext context) {
    if (index == 2) {
      _showSubmissionBottomSheet(context);
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeScreen()),
      );
    } else if (index == 4) {
      Scaffold.of(context).openEndDrawer();
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _logout() async {
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showSubmissionBottomSheet(BuildContext context) {
    if (_currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login first',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Reimburstment'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Cuti'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TimeOffRequestScreen(
                            employeeId: _currentUser!.employee!.id)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.schedule),
                title: const Text('Perubahan Shift'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: const Text('Lembur'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OvertimeScreen(
                            employeeId: _currentUser!.employee!.id)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Perubahan Data'),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }
  // Previous methods remain the same
  // ... (, _logout, _showSubmissionBottomSheet,)

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
              ],
            ),
          ),
          child: BottomNavigationBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => _onItemTapped(index, context),
            selectedItemColor: gradientColors[0],
            unselectedItemColor: Colors.grey.shade600,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 11,
            ),
            items: [
              _buildNavItem(Icons.home_rounded, 'Beranda'),
              _buildNavItem(Icons.groups_rounded, 'Karyawan'),
              _buildNavItem(Icons.add_circle_rounded, 'Pengajuan'),
              _buildNavItem(Icons.inbox_rounded, 'Inbox'),
              _buildNavItem(Icons.person_rounded, 'Akun'),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(IconData icon, String label) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _currentIndex == _getIndexForLabel(label)
                ? gradientColors[0].withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: label == 'Pengajuan' ? 30 : 24,
          ),
        ),
      ),
      label: label,
    );
  }

  int _getIndexForLabel(String label) {
    switch (label) {
      case 'Beranda':
        return 0;
      case 'Karyawan':
        return 1;
      case 'Pengajuan':
        return 2;
      case 'Inbox':
        return 3;
      case 'Akun':
        return 4;
      default:
        return 0;
    }
  }
}
