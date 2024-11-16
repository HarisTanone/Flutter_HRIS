class User {
  final int id;
  final String name;
  final String email;
  final Employee? employee;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.employee,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'employee': employee?.toJson(),
      };
}

class Employee {
  final int id;
  final String fullName;
  final String email;
  final String mobilePhone;
  final String placeOfBirth;
  final String birthdate;
  final String gender;
  final String religion;
  final String nik;
  final String citizenIdAddress;
  final String residentialAddress;
  final String joinDate;
  final String barcode;
  final Manager managerId;
  final Office officeId;
  final String photo;

  Employee({
    required this.id,
    required this.fullName,
    required this.email,
    required this.mobilePhone,
    required this.placeOfBirth,
    required this.birthdate,
    required this.gender,
    required this.religion,
    required this.nik,
    required this.citizenIdAddress,
    required this.residentialAddress,
    required this.joinDate,
    required this.barcode,
    required this.managerId,
    required this.officeId,
    required this.photo,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
      mobilePhone: json['mobile_phone'],
      placeOfBirth: json['place_of_birth'],
      birthdate: json['birthdate'],
      gender: json['gender'],
      religion: json['religion'],
      nik: json['nik'],
      citizenIdAddress: json['citizen_id_address'],
      residentialAddress: json['residential_address'],
      joinDate: json['join_date'],
      barcode: json['barcode'],
      managerId: Manager.fromJson(json['manager_id']),
      officeId: Office.fromJson(json['office_id']),
      photo: json['photo'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'mobile_phone': mobilePhone,
        'place_of_birth': placeOfBirth,
        'birthdate': birthdate,
        'gender': gender,
        'religion': religion,
        'nik': nik,
        'citizen_id_address': citizenIdAddress,
        'residential_address': residentialAddress,
        'join_date': joinDate,
        'barcode': barcode,
        'manager_id': managerId.toJson(),
        'office_id': officeId.toJson(),
        'photo': photo,
      };
}

class Manager {
  final int id;
  final String fullName;
  final String email;

  Manager({
    required this.id,
    required this.fullName,
    required this.email,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['id'],
      fullName: json['full_name'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
      };
}

class Office {
  final int id;
  final String officeName;
  final String description;

  Office({
    required this.id,
    required this.officeName,
    required this.description,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'],
      officeName: json['office_name'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'office_name': officeName,
        'description': description,
      };
}
