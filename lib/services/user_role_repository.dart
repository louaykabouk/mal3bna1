import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/models/user_role.dart';

/// Repository for managing user roles in Firestore.
/// Single source of truth: collection "users", document id = FirebaseAuth uid, field "role" = "user" or "owner".
class UserRoleRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get role for a specific UID from Firestore.
  /// Returns "user" as default if document doesn't exist or role is missing.
  Future<UserRole> getRole(String uid) async {
    debugPrint('[UserRoleRepository] Fetching role for UID: $uid');
    try {
      final docSnapshot = await _firestore.collection('users').doc(uid).get();

      if (!docSnapshot.exists || docSnapshot.data() == null) {
        debugPrint('[UserRoleRepository] Document does not exist for UID $uid, returning default role: user');
        return UserRole.user;
      }

      final data = docSnapshot.data()!;
      final roleString = data['role'] as String?;

      if (roleString == null) {
        debugPrint('[UserRoleRepository] Role field is missing for UID $uid, returning default role: user');
        return UserRole.user;
      }

      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.user,
      );

      debugPrint('[UserRoleRepository] Role for UID $uid: ${role.name}');
      return role;
    } catch (e, stackTrace) {
      debugPrint('[UserRoleRepository] Error fetching role for UID $uid: $e');
      debugPrint('[UserRoleRepository] Stack trace: $stackTrace');
      // Return default role on error
      return UserRole.user;
    }
  }

  /// Ensure user document exists with default role "user" if missing.
  /// Creates document with role="user", email, and createdAt serverTimestamp.
  /// Returns the role (either existing or newly created default).
  Future<UserRole> ensureUserDocument(String uid, {String? email}) async {
    debugPrint('[UserRoleRepository] Ensuring user document exists for UID: $uid, email: $email');
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        debugPrint('[UserRoleRepository] Creating user document with default role: user, email: $email');
        final userData = <String, dynamic>{
          'role': UserRole.user.name,
          'createdAt': FieldValue.serverTimestamp(),
        };
        if (email != null) {
          userData['email'] = email;
        }
        await docRef.set(userData);
        debugPrint('[UserRoleRepository] Created user document for UID $uid with role: user');
        return UserRole.user;
      }

      final data = docSnapshot.data();
      if (data == null || data['role'] == null) {
        debugPrint('[UserRoleRepository] User document exists but role is missing, setting default role: user');
        final updateData = <String, dynamic>{
          'role': UserRole.user.name,
        };
        if (email != null && data?['email'] == null) {
          updateData['email'] = email;
        }
        await docRef.set(updateData, SetOptions(merge: true));
        return UserRole.user;
      }

      final roleString = data['role'] as String;
      final role = UserRole.values.firstWhere(
        (r) => r.name == roleString,
        orElse: () => UserRole.user,
      );

      debugPrint('[UserRoleRepository] User document exists with role: ${role.name}');
      return role;
    } catch (e, stackTrace) {
      debugPrint('[UserRoleRepository] Error ensuring user document for UID $uid: $e');
      debugPrint('[UserRoleRepository] Stack trace: $stackTrace');
      return UserRole.user;
    }
  }

  /// Save role for a specific UID to Firestore.
  Future<void> saveRole(String uid, UserRole role) async {
    debugPrint('[UserRoleRepository] Saving role for UID $uid: ${role.name}');
    try {
      await _firestore.collection('users').doc(uid).set(
        {'role': role.name},
        SetOptions(merge: true),
      );
      debugPrint('[UserRoleRepository] Successfully saved role for UID $uid');
    } catch (e, stackTrace) {
      debugPrint('[UserRoleRepository] Error saving role for UID $uid: $e');
      debugPrint('[UserRoleRepository] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

final userRoleRepository = UserRoleRepository();
