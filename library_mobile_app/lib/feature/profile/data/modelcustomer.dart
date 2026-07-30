//هاد الكلاس مو مستعمل

class CustomerModel {
  final String name;
  final String email;
  final String? phone;
  final String? gender;
  final String? dob;
  final String? lang;
  final String? avatar;
  final int points;

  CustomerModel({
    required this.name,
    required this.email,
    this.phone,
    this.gender,
    this.dob,
    this.lang,
    this.avatar,
    required this.points,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      gender: json['gender'],
      dob: json['DOB'] ?? json['dob'],
      lang: json['lang'],
      avatar: json['avatar'],
      points: json['points'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'gender': gender,
      'DOB': dob,
      'lang': lang,
      'avatar': avatar,
      'points': points,
    };
  }
}
