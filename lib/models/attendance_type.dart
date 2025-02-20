class AttendanceType {
  final int id;
  final String typeName;
  final DateTime createdAt;
  final DateTime updatedAt;

  AttendanceType({
    required this.id,
    required this.typeName,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceType && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  factory AttendanceType.fromJson(Map<String, dynamic> json) {
    return AttendanceType(
      id: json['id'],
      typeName: json['type_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
