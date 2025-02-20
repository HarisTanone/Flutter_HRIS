// employee_response.dart

// EmployeeResponse Model
class EmployeeResponse {
  final List<Employee> data;
  final Links links;
  final Meta meta;

  EmployeeResponse({
    required this.data,
    required this.links,
    required this.meta,
  });

  factory EmployeeResponse.fromJson(Map<String, dynamic> json) {
    return EmployeeResponse(
      data:
          (json['data'] as List?)?.map((e) => Employee.fromJson(e)).toList() ??
              [],
      links:
          json['links'] != null ? Links.fromJson(json['links']) : Links.empty(),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : Meta.empty(),
    );
  }
}

class Employee {
  final int id;
  final String fullName;
  final String email;
  final String mobilePhone;
  final String placeOfBirth;
  final String birthdate;
  final String gender;
  final String? religion;
  final String nik;
  final String citizenIdAddress;
  final String residentialAddress;
  final String joinDate;
  final String? barcode;
  final User userId;
  final dynamic managerId;
  final Office officeId;
  final String? photo;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobilePhone,
    required this.placeOfBirth,
    required this.birthdate,
    required this.gender,
    this.religion,
    required this.nik,
    required this.citizenIdAddress,
    required this.residentialAddress,
    required this.joinDate,
    this.barcode,
    required this.userId,
    this.managerId,
    required this.officeId,
    this.photo,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      mobilePhone: json['mobile_phone'] ?? '',
      placeOfBirth: json['place_of_birth'] ?? '',
      birthdate: json['birthdate'] ?? '',
      gender: json['gender'] ?? '',
      religion: json['religion'],
      nik: json['nik'] ?? '',
      citizenIdAddress: json['citizen_id_address'] ?? '',
      residentialAddress: json['residential_address'] ?? '',
      joinDate: json['join_date'] ?? '',
      barcode: json['barcode'],
      userId: json['user_id'] != null
          ? User.fromJson(json['user_id'])
          : User.empty(),
      managerId: json['manager_id'],
      officeId: json['office_id'] != null
          ? Office.fromJson(json['office_id'])
          : Office.empty(),
      photo: json['photo'],
    );
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String createdAt;
  final String updatedAt;
  final int sortOrder;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.sortOrder,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      sortOrder: json['sort_order'],
    );
  }
  static User empty() {
    return User(
      id: 0,
      name: '',
      email: '',
      emailVerifiedAt: null,
      createdAt: '',
      updatedAt: '',
      sortOrder: 0,
    );
  }
}

class Office {
  final int id;
  final String officeName;
  final String latitude;
  final String longitude;
  final int radius;
  final String description;
  final String createdAt;
  final String updatedAt;

  Office({
    required this.id,
    required this.officeName,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      officeName: json['office_name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      radius: json['radius'],
      description: json['description'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
  static Office empty() {
    return Office(
      id: 0,
      officeName: '',
      latitude: '',
      longitude: '',
      radius: 0,
      description: '',
      createdAt: '',
      updatedAt: '',
    );
  }
}

class Links {
  final String first;
  final String last;
  final String? prev;
  final String? next;

  Links({
    required this.first,
    required this.last,
    this.prev,
    this.next,
  });

  factory Links.fromJson(Map<String, dynamic> json) {
    return Links(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }

  static Links empty() {
    return Links(
      first: '',
      last: '',
      prev: null,
      next: null,
    );
  }
}

class Meta {
  final int currentPage;
  final int from;
  final int lastPage;
  final List<Link> links;
  final String path;
  final int perPage;
  final int to;
  final int total;

  Meta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.links,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      from: json['from'],
      lastPage: json['last_page'],
      links: (json['links'] as List).map((e) => Link.fromJson(e)).toList(),
      path: json['path'],
      perPage: json['per_page'],
      to: json['to'],
      total: json['total'],
    );
  }

  static Meta empty() {
    return Meta(
      currentPage: 0,
      from: 0,
      lastPage: 0,
      links: [],
      path: '',
      perPage: 0,
      to: 0,
      total: 0,
    );
  }
}

class Link {
  final String? url;
  final String label;
  final bool active;

  Link({
    this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) {
    return Link(
      url: json['url'],
      label: json['label'],
      active: json['active'],
    );
  }
}
