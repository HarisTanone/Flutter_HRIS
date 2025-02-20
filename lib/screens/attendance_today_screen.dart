import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../services/attendance_service.dart';

class AttendanceScreen extends StatefulWidget {
  final int employeeId;

  const AttendanceScreen({super.key, required this.employeeId});

  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<Map<String, dynamic>?> _attendanceData;

  @override
  void initState() {
    super.initState();
    _attendanceData = AttendanceService().getTodayAttendance(widget.employeeId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Attendance Details"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Clock In"),
              Tab(text: "Clock Out"),
            ],
          ),
        ),
        body: FutureBuilder<Map<String, dynamic>?>(
          future: _attendanceData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text("No attendance data available"));
            }

            final data = snapshot.data!;
            return TabBarView(
              children: [
                _buildClockInTab(data),
                _buildClockOutTab(data),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClockInTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Clock In Time"),
          Text(data['clock_in'] ?? "Not Available", style: _infoTextStyle),
          const SizedBox(height: 10),
          _buildSectionTitle("Photo"),
          _buildImage(data['photo']),
          const SizedBox(height: 10),
          _buildSectionTitle("Location on Map"),
          _buildMap(data['latitude'], data['longitude']),
          const SizedBox(height: 10),
          _buildSectionTitle("Attendance Notes"),
          Text(data['attendance_notes'] ?? "No Notes", style: _infoTextStyle),
        ],
      ),
    );
  }

  Widget _buildClockOutTab(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("Clock Out Time"),
          Text(data['clock_out'] ?? "Not Available", style: _infoTextStyle),
          const SizedBox(height: 10),
          _buildSectionTitle("Photo"),
          data['photo_out'] != null
              ? _buildImage(data['photo_out'])
              : Text("No photo available", style: _infoTextStyle),
          const SizedBox(height: 10),
          _buildSectionTitle("Location on Map"),
          data['latitude_out'] != null && data['longitude_out'] != null
              ? _buildMap(data['latitude_out'], data['longitude_out'])
              : Text("No location data available", style: _infoTextStyle),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildImage(String? photo) {
    if (photo == null || photo.isEmpty) {
      return Text("No photo available", style: _infoTextStyle);
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        "https://7928-36-77-243-75.ngrok-free.app/storage/$photo",
        height: 200,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Center(
            child:
                Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  Widget _buildMap(String? lat, String? lng) {
    if (lat == null || lng == null) {
      return Text("Location not available", style: _infoTextStyle);
    }

    final double latitude = double.tryParse(lat) ?? 0.0;
    final double longitude = double.tryParse(lng) ?? 0.0;
    final LatLng position = LatLng(latitude, longitude);

    return SizedBox(
      height: 200,
      width: double.infinity,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: position, // Ganti dari 'center'
          initialZoom: 15, // Ganti dari 'zoom'
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: position,
                width: 40,
                height: 40,
                child: const Icon(
                  // Ganti dari 'builder'
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  final TextStyle _infoTextStyle =
      const TextStyle(fontSize: 16, color: Colors.black87);
}
