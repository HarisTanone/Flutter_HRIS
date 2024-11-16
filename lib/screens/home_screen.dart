import 'package:flutter/material.dart';
import '../widgets/clock_card.dart';
import '../widgets/menu_grid.dart';
import '../widgets/announcement_section.dart';
import '../widgets/bottom_navigation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Fungsi untuk menentukan ucapan berdasarkan waktu
  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour >= 6 && hour < 12) {
      return 'Selamat pagi,';
    } else if (hour >= 12 && hour < 15) {
      return 'Selamat siang,';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat sore,';
    } else {
      return 'Selamat malam,';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: AuthService().getUserData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!;
        final employee = user.employee!;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Menampilkan ucapan berdasarkan waktu
                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      employee.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jangan lupa absen hari ini!',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ClockCard(),
                    const SizedBox(height: 24),
                    const MenuGrid(),
                    const SizedBox(height: 24),
                    const AnnouncementSection(),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: const BottomNavigation(),
        );
      },
    );
  }
}
