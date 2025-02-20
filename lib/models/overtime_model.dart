class OvertimeModel {
  final int? id;
  final int employeeId;
  final String date;
  final String startTime;
  final String endTime;
  final String? totalHours;
  final String status;
  final String reason;
  final int? approvedBy;
  final String? approvedAt;
  final String? createdAt;
  final String? updatedAt;

  OvertimeModel({
    this.id,
    required this.employeeId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.totalHours,
    this.status = 'Menunggu',
    required this.reason,
    this.approvedBy,
    this.approvedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory OvertimeModel.fromJson(Map<String, dynamic> json) {
    return OvertimeModel(
      id: json['id'],
      employeeId: json['employee_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      totalHours: json['total_hours'],
      status: json['status'] ?? 'Menunggu',
      reason: json['reason'],
      approvedBy: json['approved_by'],
      approvedAt: json['approved_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'reason': reason,
    };
  }
}
