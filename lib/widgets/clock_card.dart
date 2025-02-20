import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/attendance_service.dart';
import '../services/auth_service.dart';
import '../services/camera_service.dart';
import '../services/location_service.dart';

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
  bool _showCamera = false;
  File? _capturedImage;
  String? _clockInTime;
  String? _clockOutTime;
  Map<String, dynamic>? _todayAttendance;

  String formattedDate = DateFormat('EEEE, dd MMM yyyy').format(DateTime.now());
  String officeName = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _cameraService.initialize();
      final user = await AuthService().getUserData();
      if (user?.employee?.officeId != null) {
        setState(() {
          officeName = user!.employee!.officeId.officeName;
        });
        await _checkTodayAttendance(user!.employee!.id);
      }
    } catch (e) {
      _showError('Initialization error: $e');
    }
  }

  Future<void> _checkTodayAttendance(int employeeId) async {
    try {
      final attendance =
          await _attendanceService.getTodayAttendance(employeeId);
      if (attendance != null) {
        setState(() {
          _todayAttendance = attendance;
          _clockInTime = DateFormat('HH:mm').format(
            DateTime.parse(attendance['clock_in']),
          );
          if (attendance['clock_out'] != null) {
            _clockOutTime = DateFormat('HH:mm').format(
              DateTime.parse(attendance['clock_out']),
            );
          }
        });
      }
    } catch (e) {
      _showError('Failed to check attendance: $e');
    }
  }

  Future<void> _handleAttendance(bool isClockIn) async {
    setState(() => _showCamera = true);
  }

  Future<void> _takePicture() async {
    try {
      setState(() => _isLoading = true);
      final capturedImage = await _cameraService.takePicture();
      if (capturedImage != null) {
        setState(() {
          _capturedImage = capturedImage;
          _showCamera = false;
        });

        final position = await _locationService.getCurrentLocation();
        if (position == null) throw 'Could not get location';

        final base64Image = await _cameraService.convertToBase64(capturedImage);
        final user = await AuthService().getUserData();
        if (user?.employee == null) throw 'User data not found';

        final response = _clockInTime == null
            ? await _attendanceService.clockIn(
                employeeId: user!.employee!.id,
                officeId: user.employee!.officeId.id,
                latitude: position.latitude,
                longitude: position.longitude,
                photoBase64: base64Image,
              )
            : await _attendanceService.clockOut(
                attendanceId: _todayAttendance!['id'],
                latitude: position.latitude,
                longitude: position.longitude,
                photoBase64: base64Image,
              );

        if (response['status'] == 200) {
          await _checkTodayAttendance(user!.employee!.id);
          _showSuccess(response['message']);
        } else {
          _showError(response['message']);
        }
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFAE0606), Color(0xFF900C0C)], // Warna gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: const Color(0xFF650000), // Warna border
          width: 2, // Ketebalan border
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.business, color: Colors.white, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  officeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            formattedDate,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          if (_clockInTime != null) ...[
            const SizedBox(height: 16),
            _buildTimeCard(
              icon: Icons.login,
              label: 'Clock In',
              time: _clockInTime!,
              color: Colors.black,
            ),
          ],
          if (_clockOutTime != null) ...[
            const SizedBox(height: 8),
            _buildTimeCard(
              icon: Icons.logout,
              label: 'Clock Out',
              time: _clockOutTime!,
              color: Colors.black,
            ),
          ],
          if (_showCamera && _cameraService.controller != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  SizedBox(
                    height: 550,
                    width: double.infinity,
                    child: CameraPreview(_cameraService.controller!),
                  ),
                  if (_isLoading)
                    Container(
                      height: 550,
                      width: double.infinity,
                      color: Colors.black45,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onPressed: _takePicture,
                  isLoading: _isLoading,
                ),
                _buildActionButton(
                  icon: Icons.close,
                  label: 'Cancel',
                  onPressed: () => setState(() => _showCamera = false),
                  color: Colors.red,
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 24),
            _buildMainButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.black,
    bool isLoading = false,
  }) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMainButton() {
    final bool canClockIn = _clockInTime == null;
    final bool canClockOut = _clockInTime != null && _clockOutTime == null;

    if (!canClockIn && !canClockOut) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAttendance(canClockIn),
        icon: Icon(canClockIn ? Icons.login : Icons.logout),
        label: Text(canClockIn ? 'Clock In' : 'Clock Out'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }
}
