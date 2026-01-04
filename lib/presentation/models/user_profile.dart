import 'dart:typed_data';

class UserProfile {
  String? name;
  int? age;
  String? phone;
  String? address;
  Uint8List? avatarBytes;

  UserProfile({
    this.name,
    this.age,
    this.phone,
    this.address,
    this.avatarBytes,
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? phone,
    String? address,
    Uint8List? avatarBytes,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      avatarBytes: avatarBytes ?? this.avatarBytes,
    );
  }
}

