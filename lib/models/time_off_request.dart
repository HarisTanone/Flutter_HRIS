class TimeOffRequest {
  final int? id;
  final int employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String status;
  final String? document;
  final int? approvedBy;
  final DateTime? approvedAt;
  final int attendanceTypeId;

  TimeOffRequest({
    this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    this.document,
    this.approvedBy,
    this.approvedAt,
    required this.attendanceTypeId,
  });

  factory TimeOffRequest.fromJson(Map<String, dynamic> json) {
    return TimeOffRequest(
      id: json['id'],
      employeeId: json['employee_id'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      reason: json['reason'],
      status: json['status'],
      document: json['document'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'] != null
          ? DateTime.parse(json['approved_at'])
          : null,
      attendanceTypeId: json['attendance_type_id'],
    );
  }
}
