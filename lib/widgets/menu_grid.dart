import 'package:flutter/material.dart';

import '../models/menu_item.dart';
import '../models/user_model.dart';
import '../screens/attendance_page.dart';
import '../screens/attendance_today_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/login_screen.dart';
import '../screens/overtime_screen.dart';
import '../screens/time_off_request_screen.dart';
import '../services/auth_service.dart';

class MenuGrid extends StatefulWidget {
  const MenuGrid({super.key});

  @override
  State<MenuGrid> createState() => _MenuGridState();
}

class _MenuGridState extends State<MenuGrid> {
  final AuthService _authService = AuthService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await _authService.getUserData();
    if (user == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      setState(() {
        _currentUser = user;
      });
    }
  }

  void _handleMenuTap(BuildContext context, MenuItem item) async {
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

    if (item.title == 'Daftar Absensi') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AttendancePage(employeeId: _currentUser!.employee!.id),
        ),
      );
    } else if (item.title == 'Cuti') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              TimeOffRequestScreen(employeeId: _currentUser!.employee!.id),
        ),
      );
    } else if (item.title == 'Lembur') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              OvertimeScreen(employeeId: _currentUser!.employee!.id),
        ),
      );
    } else if (item.title == 'Kalender') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BirthdayCalendar(),
        ),
      );
    } else if (item.title == 'Absen') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              AttendanceScreen(employeeId: _currentUser!.employee!.id),
        ),
      );
    }
    // Add logic for other menu items here
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: menuItems
          .map((item) => MenuItemWidget(
                item: item,
                onTap: () => _handleMenuTap(context, item),
              ))
          .toList(),
    );
  }
}

class MenuItemWidget extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuItemWidget({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.title,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
