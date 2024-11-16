import 'dart:convert';
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
  bool _hasCheckedIn = false;
  bool _showCamera = false;
  File? _capturedImage;
  String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
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
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _handleClockIn() async {
    // Tampilkan kamera terlebih dahulu
    setState(() => _showCamera = true);
  }

  Future<void> _submitAttendance() async {
    try {
      setState(() => _isLoading = true);

      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw 'Could not get location';
      }

      if (_capturedImage == null) {
        throw 'Please take a photo first';
      }

      final base64Image = await _cameraService.convertToBase64(_capturedImage!);

      final user = await AuthService().getUserData();
      if (user?.employee == null) {
        throw 'User data not found';
      }

      final response = await _attendanceService.clockIn(
        employeeId: user!.employee!.id,
        officeId: user.employee!.officeId.id,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: base64Image,
      );

      if (response.statusCode == 200) {
        setState(() {
          _hasCheckedIn = true;
          _showCamera = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clock in successful')),
        );
      } else if (response.statusCode == 404) {
        final errorMessage = response.body.isNotEmpty
            ? json.decode(response.body)['message']
            : 'Unknown error occurred';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } else {
        throw 'Clock in failed with status: ${response.statusCode}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _takePicture() async {
    try {
      final capturedImage = await _cameraService.takePicture();
      if (capturedImage != null) {
        setState(() {
          _capturedImage = capturedImage;
          _showCamera = false; // Sembunyikan kamera setelah mengambil gambar
        });
        // Lanjut ke proses submit
        await _submitAttendance();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
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
          if (_showCamera && _cameraService.controller != null) ...[
            SizedBox(
              height: 420,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CameraPreview(_cameraService.controller!),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _takePicture,
              icon: const Icon(Icons.camera),
              label: const Text('Take Picture'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showCamera = false;
                  _capturedImage = null;
                });
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleClockIn,
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
          if (_capturedImage != null && !_hasCheckedIn) ...[
            const SizedBox(height: 16),
            const Text(
              'Photo captured successfully!',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
