import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Service for managing user roles in Firestore.
/// Single source of truth: collection "users", document id = uid, field "role" = "user" or "owner".
class UserRoleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get or create role for a user. Returns "user" or "owner" from Firestore.
  /// Creates user document if it doesn't exist with default role "user".
  Future<String> getOrCreateRole({required String uid, required String email}) async {
    debugPrint('[UserRoleService] getOrCreateRole - UID: $uid, Email: $email');
    
    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) {
        debugPrint('[UserRoleService] User document does not exist, creating with default role: user');
        await docRef.set(
          {
            'email': email,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        debugPrint('[UserRoleService] Created user document for UID $uid with role: user');
        return 'user';
      }

      final data = docSnapshot.data();
      if (data == null || data['role'] == null) {
        debugPrint('[UserRoleService] User document exists but role is missing, setting default role: user');
        await docRef.set(
          {
            'email': email,
            'role': 'user',
          },
          SetOptions(merge: true),
        );
        return 'user';
      }

      final roleString = data['role'] as String?;
      final role = roleString == 'owner' ? 'owner' : 'user';
      
      debugPrint('[UserRoleService] Found role for UID $uid: $role');
      return role;
    } catch (e, stackTrace) {
      debugPrint('[UserRoleService] Error in getOrCreateRole for UID $uid: $e');
      debugPrint('[UserRoleService] Stack trace: $stackTrace');
      // Return default role on error
      return 'user';
    }
  }
}

final userRoleService = UserRoleService();

