enum UserRole {
  user, // مستخدم
  owner, // مالك
}

extension UserRoleExtension on UserRole {
  String get arabicName {
    switch (this) {
      case UserRole.user:
        return 'مستخدم';
      case UserRole.owner:
        return 'مالك';
    }
  }
}

