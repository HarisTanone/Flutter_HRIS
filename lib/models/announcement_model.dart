class Announcement {
  final int id;
  final String title;
  final String body;
  final String poster;
  final int userId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.poster,
    required this.userId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      poster: json['poster'],
      userId: json['user_id'],
      isActive: json['isActive'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  static List<Announcement> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Announcement.fromJson(json)).toList();
  }
}
