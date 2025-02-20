import 'package:flutter/material.dart';

import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../widgets/appbar_widget.dart';

class AttendancePage extends StatefulWidget {
  final int employeeId;

  const AttendancePage({super.key, required this.employeeId});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<AttendanceData> attendanceData;
  String selectedMonth =
      "${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _fetchAttendanceData();
  }

  void _fetchAttendanceData() {
    setState(() {
      attendanceData = AttendanceService.getMonthlyAttendance(
          widget.employeeId, selectedMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(title: 'Attendance List'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Pilih Bulan: ', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  items: _generateMonthDropdownItems(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        selectedMonth = newValue;
                        _fetchAttendanceData();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                _fetchAttendanceData();
              },
              child: FutureBuilder<AttendanceData>(
                future: attendanceData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.absen.isEmpty) {
                    return const Center(
                        child: Text('Tidak ada data absensi untuk bulan ini.'));
                  } else {
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildSummaryCard(snapshot.data!.meta),
                          _buildAttendanceList(snapshot.data!.absen),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AttendanceMeta meta) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.check_circle,
                    label: 'Total Absensi',
                    value: meta.totalAttendances.toString(),
                    color: Colors.green[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.error_outline,
                    label: 'Tidak Absen Masuk',
                    value: meta.totalNoClockIn.toString(),
                    color: Colors.red[700]!,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.access_time,
                    label: 'Terlambat',
                    value: meta.totalLateClockIn.toString(),
                    color: Colors.orange[700]!,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    icon: Icons.exit_to_app,
                    label: 'Tidak Absen Pulang',
                    value: meta.totalNoClockOut.toString(),
                    color: Colors.purple[700]!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceList(List<Attendance> attendances) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: attendances.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final attendance = attendances[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attendance.dateFormatted,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        attendance.isHoliday ? Colors.redAccent : Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        attendance.status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.login,
                            size: 16,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(attendance.clockIn),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.logout,
                            size: 16,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(attendance.clockOut),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '-';
    }
  }

  List<DropdownMenuItem<String>> _generateMonthDropdownItems() {
    final now = DateTime.now();
    final items = <DropdownMenuItem<String>>[];

    for (var i = 0; i < 12; i++) {
      final date = DateTime(now.year, now.month - i);
      final value = "${date.year}-${date.month.toString().padLeft(2, '0')}";
      items.add(DropdownMenuItem(value: value, child: Text(value)));
    }

    return items;
  }
}
