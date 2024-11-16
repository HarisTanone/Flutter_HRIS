import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:intl/intl.dart';
import '../services/location_service.dart';
import '../services/camera_service.dart';
import '../services/attendance_service.dart';

class ClockCard extends StatefulWidget {
  const ClockCard({super.key});

  @override
  State<ClockCard> createState() => _ClockCardState();
}

class _ClockCardState extends State<ClockCard> {
  final _locationService = LocationService();
  final _cameraService = CameraService();
  final _attendanceService = AttendanceService();
  bool _isLoading = false;
  bool _hasCheckedIn = false;
  String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  String officeName = ''; // Untuk menyimpan nama kantor secara dinamis

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _cameraService.initialize();

      // Ambil data user untuk mendapatkan nama kantor
      final user = await AuthService().getUserData();
      if (user?.employee?.officeId != null) {
        setState(() {
          officeName = user!.employee!.officeId.officeName;
        });
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _handleClockIn() async {
    try {
      setState(() => _isLoading = true);

      // Get current location
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw 'Could not get location';
      }

      // Take picture
      final photo = await _cameraService.takePicture();
      if (photo == null) {
        throw 'Could not take picture';
      }

      // Get user data
      final user = await AuthService().getUserData();
      if (user?.employee == null) {
        throw 'User data not found';
      }

      // Submit attendance
      final success = await _attendanceService.clockIn(
        employeeId: user!.employee!.id,
        officeId: user.employee!.officeId.id,
        latitude: position.latitude,
        longitude: position.longitude,
        photo: photo,
      );

      if (success) {
        setState(() => _hasCheckedIn = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clock in successful')),
        );
      } else {
        throw 'Clock in failed';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            officeName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$formattedDate (08:30 - 17:00)',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      _hasCheckedIn || _isLoading ? null : _handleClockIn,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.login),
                  label: Text(_hasCheckedIn ? 'Checked In' : 'Clock In'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.logout),
                  label: const Text('Clock Out'),
                  style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
