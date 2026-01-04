import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_role.dart';

class RoleState {
  final UserRole? currentRole;
  final bool isLoading;

  RoleState({
    this.currentRole,
    this.isLoading = false,
  });

  RoleState copyWith({
    UserRole? currentRole,
    bool? isLoading,
  }) {
    return RoleState(
      currentRole: currentRole ?? this.currentRole,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class RoleController extends StateNotifier<RoleState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  RoleController() : super(RoleState(isLoading: false)) {
    _initRole();
  }

  Future<void> _initRole() async {
    final user = _auth.currentUser;
    if (user != null) {
      await loadRoleForUid(user.uid);
    }
  }

  /// Load role from Firestore using UID
  Future<void> loadRoleForUid(String uid) async {
    state = state.copyWith(isLoading: true);
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists && doc.data() != null) {
        final roleString = doc.data()!['role'] as String?;
        final role = roleString == 'owner' ? UserRole.owner : UserRole.user;
        
        state = state.copyWith(
          currentRole: role,
          isLoading: false,
        );
        debugPrint('[RoleController] Loaded role from Firestore: ${role.name} for UID: $uid');
      } else {
        // Document doesn't exist, default to user
        state = state.copyWith(
          currentRole: UserRole.user,
          isLoading: false,
        );
        debugPrint('[RoleController] User document not found, defaulting to user role for UID: $uid');
      }
    } catch (e) {
      debugPrint('[RoleController] Error loading role: $e');
      // Default to user on error
      state = state.copyWith(
        currentRole: UserRole.user,
        isLoading: false,
      );
    }
  }

  /// Save role to Firestore using UID
  Future<void> saveRoleForUid(String uid, UserRole role) async {
    try {
      await _firestore.collection('users').doc(uid).set(
        {'role': role.name},
        SetOptions(merge: true),
      );
      
      state = state.copyWith(currentRole: role);
      debugPrint('[RoleController] Saved role to Firestore: ${role.name} for UID: $uid');
    } catch (e) {
      debugPrint('[RoleController] Error saving role: $e');
      rethrow;
    }
  }

  /// Clear current role (for logout)
  Future<void> clearRole() async {
    state = RoleState(isLoading: false);
    debugPrint('[RoleController] Role cleared');
  }
}

final roleControllerProvider = StateNotifierProvider<RoleController, RoleState>(
  (ref) => RoleController(),
);
