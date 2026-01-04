import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/user_role_repository.dart';
import '../../../core/models/user_role.dart';
import '../pages.dart';

/// AuthGate widget that handles authentication state and routes users based on their role.
/// This is the single source of truth for routing decisions based on Firestore roles.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          debugPrint('[AuthGate] Waiting for auth state...');
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: const Color(0xFF4BCB78),
              ),
            ),
          );
        }

        final user = snapshot.data;

        // No user logged in -> show onboarding/login
        if (user == null) {
          debugPrint('[AuthGate] No user logged in, showing onboarding');
          return const OnboardingFlowPage();
        }

        // User is logged in -> fetch role and route accordingly
        final uid = user.uid;
        final email = user.email;
        debugPrint('[AuthGate] User logged in - UID: $uid, Email: $email');
        return _RoleResolver(userId: uid, userEmail: email);
      },
    );
  }
}

/// Widget that resolves the user's role from Firestore and routes accordingly.
class _RoleResolver extends StatefulWidget {
  final String userId;
  final String? userEmail;

  const _RoleResolver({required this.userId, this.userEmail});

  @override
  State<_RoleResolver> createState() => _RoleResolverState();
}

class _RoleResolverState extends State<_RoleResolver> {
  UserRole? _role;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    debugPrint('[RoleResolver] Fetching role for user - UID: ${widget.userId}, Email: ${widget.userEmail}');
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure user document exists (create with default "user" if missing)
      final role = await userRoleRepository.ensureUserDocument(
        widget.userId,
        email: widget.userEmail,
      );
      
      debugPrint('[RoleResolver] Resolved role: ${role.name} for UID: ${widget.userId}');
      debugPrint('[RoleResolver] Routing decision: ${role == UserRole.owner ? "OwnerHomePage" : "HomeShellPage"}');
      
      if (mounted) {
        setState(() {
          _role = role;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      debugPrint('[RoleResolver] Error fetching role for UID ${widget.userId}: $e');
      debugPrint('[RoleResolver] Stack trace: $stackTrace');
      
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
          // Default to user role on error for safety
          _role = UserRole.user;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF4BCB78),
              ),
              const SizedBox(height: 16),
              Text(
                'جارٍ التحقق من الصلاحيات...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show error screen if there was an error (but still allow access with default role)
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('خطأ'),
          backgroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  'حدث خطأ أثناء تحميل البيانات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchRole,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4BCB78),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Route based on role
    final role = _role ?? UserRole.user;
    
    if (role == UserRole.owner) {
      debugPrint('[RoleResolver] Routing to OwnerHomePage');
      return const OwnerHomePage();
    } else {
      debugPrint('[RoleResolver] Routing to HomeShellPage');
      return const HomeShellPage();
    }
  }
}
