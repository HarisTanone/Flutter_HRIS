class AttendanceData {
  final List<Attendance> absen;
  final List<Attendance> lateClockIn;
  final List<Attendance> earlyClockIn;
  final List<Attendance> noClockIn;
  final List<Attendance> noClockOut;
  final AttendanceMeta meta;

  AttendanceData({
    required this.absen,
    required this.lateClockIn,
    required this.earlyClockIn,
    required this.noClockIn,
    required this.noClockOut,
    required this.meta,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) {
    return AttendanceData(
      absen: (json['data']['absen'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
      lateClockIn: (json['data']['late_clock_in'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
      earlyClockIn: (json['data']['early_clock_in'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
      noClockIn: (json['data']['no_clock_in'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
      noClockOut: (json['data']['no_clock_out'] as List)
          .map((e) => Attendance.fromJson(e))
          .toList(),
      meta: AttendanceMeta.fromJson(json['meta']),
    );
  }
}

class Attendance {
  final int id;
  final int employeeId;
  final String clockIn;
  final String? clockOut;
  final String status;
  final String attendanceNotes;
  final bool isHoliday;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.clockIn,
    this.clockOut,
    required this.status,
    required this.attendanceNotes,
    this.isHoliday = false,
  });

  String get dateFormatted {
    final dateTime = DateTime.parse(clockIn);
    return "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
  }

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      employeeId: json['employee_id'],
      clockIn: json['clock_in'],
      clockOut: json['clock_out'],
      status: json['status'],
      attendanceNotes: json['attendance_notes'],
      isHoliday: json['is_holiday'] ?? false,
    );
  }
}

class AttendanceMeta {
  final String employeeId;
  final String month;
  final int totalAttendances;
  final int totalAbsen;
  final int totalLateClockIn;
  final int totalEarlyClockIn;
  final int totalNoClockIn;
  final int totalNoClockOut;

  AttendanceMeta({
    required this.employeeId,
    required this.month,
    required this.totalAttendances,
    required this.totalAbsen,
    required this.totalLateClockIn,
    required this.totalEarlyClockIn,
    required this.totalNoClockIn,
    required this.totalNoClockOut,
  });

  factory AttendanceMeta.fromJson(Map<String, dynamic> json) {
    return AttendanceMeta(
      employeeId: json['employee_id'],
      month: json['month'],
      totalAttendances: json['total_attendances'],
      totalAbsen: json['total_absen'],
      totalLateClockIn: json['total_late_clock_in'],
      totalEarlyClockIn: json['total_early_clock_in'],
      totalNoClockIn: json['total_no_clock_in'],
      totalNoClockOut: json['total_no_clock_out'],
    );
  }
}
