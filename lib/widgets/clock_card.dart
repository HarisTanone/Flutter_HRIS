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
  bool _isClockInLoading = false;
  bool _isClockOutLoading = false;
  bool _hasCheckedIn = false;
  bool _hasCheckedOut = false;
  bool _showCamera = false;
  File? _capturedImage;
  String formattedDate = DateFormat('dd MMM yyyy').format(DateTime.now());
  String officeName = '';
  int? _todayAttendanceId;

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
        // Cek attendance hari ini
        await _checkTodayAttendance(user!.employee!.id);
      }
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  Future<void> _checkTodayAttendance(int employeeId) async {
    try {
      final attendance =
          await _attendanceService.getTodayAttendance(employeeId);
      if (attendance != null) {
        setState(() {
          _hasCheckedIn = true;
          _todayAttendanceId = attendance['id'];
          _hasCheckedOut = attendance['clock_out'] != null;
        });
      }
    } catch (e) {
      print('Check attendance error: $e');
    }
  }

  Future<void> _handleClockIn() async {
    setState(() => _showCamera = true);
  }

  Future<void> _handleClockOut() async {
    setState(() => _showCamera = true);
  }

  Future<void> _submitAttendance() async {
    try {
      setState(() => _isClockInLoading = true);

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
        // Refresh attendance data after clock in
        await _checkTodayAttendance(user.employee!.id);
        setState(() {
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
      setState(() => _isClockInLoading = false);
    }
  }

  Future<void> _submitClockOut() async {
    try {
      setState(() => _isClockOutLoading = true);

      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        throw 'Could not get location';
      }

      if (_capturedImage == null) {
        throw 'Please take a photo first';
      }

      if (_todayAttendanceId == null) {
        throw 'No clock in record found for today';
      }

      final base64Image = await _cameraService.convertToBase64(_capturedImage!);

      final response = await _attendanceService.clockOut(
        attendanceId: _todayAttendanceId!,
        latitude: position.latitude,
        longitude: position.longitude,
        photoBase64: base64Image,
      );

      if (response.statusCode == 200) {
        final user = await AuthService().getUserData();
        // Refresh attendance data after clock out
        if (user?.employee != null) {
          await _checkTodayAttendance(user!.employee!.id);
        }
        setState(() {
          _showCamera = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clock out successful')),
        );
      } else {
        throw 'Clock out failed with status: ${response.statusCode}';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isClockOutLoading = false);
    }
  }

  Future<void> _takePicture() async {
    try {
      final capturedImage = await _cameraService.takePicture();
      if (capturedImage != null) {
        setState(() {
          _capturedImage = capturedImage;
          _showCamera = false;
        });
        // Submit berdasarkan aksi yang sedang dilakukan
        if (!_hasCheckedIn) {
          await _submitAttendance();
        } else {
          await _submitClockOut();
        }
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
            Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera),
                    label: const Text('Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                  ),
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
                ],
              ),
            )
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _handleClockIn,
                    icon: _isClockInLoading
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
                    onPressed: (_hasCheckedIn && !_hasCheckedOut)
                        ? _handleClockOut
                        : null,
                    icon: _isClockOutLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.logout),
                    label: Text(_hasCheckedOut ? 'Checked Out' : 'Clock Out'),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.white),
                      foregroundColor: WidgetStateProperty.all(Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (_capturedImage != null && !(_hasCheckedIn && _hasCheckedOut)) ...[
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
