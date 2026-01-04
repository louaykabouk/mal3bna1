import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserProfileStore extends ChangeNotifier {
  static final UserProfileStore _instance = UserProfileStore._internal();
  factory UserProfileStore() => _instance;
  UserProfileStore._internal();

  UserProfile profile = UserProfile();

  void update({
    String? name,
    int? age,
    String? phone,
    String? address,
    Uint8List? avatarBytes,
  }) {
    profile = profile.copyWith(
      name: name,
      age: age,
      phone: phone,
      address: address,
      avatarBytes: avatarBytes,
    );
    notifyListeners();
  }
}

final userProfileStore = UserProfileStore();

