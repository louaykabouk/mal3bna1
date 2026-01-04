import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/user_role_service.dart';
import 'presentation/pages/pages.dart';

/// AuthGate widget that handles authentication state and routes users based on their Firestore role.
/// This is the single source of truth for routing decisions.
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

        // No user logged in -> show login page
        if (user == null) {
          debugPrint('[AuthGate] No user logged in, showing LoginPage');
          return const LoginPage();
        }

        // User is logged in -> fetch role and route accordingly
        final uid = user.uid;
        final email = user.email ?? '';
        debugPrint('[AuthGate] User logged in - UID: $uid, Email: $email');
        
        return FutureBuilder<String>(
          future: userRoleService.getOrCreateRole(uid: uid, email: email),
          builder: (context, roleSnapshot) {
            // Show loading while fetching role
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              debugPrint('[AuthGate] Fetching role for UID: $uid...');
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
                        'جارٍ التحميل...',
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

            // Handle error
            if (roleSnapshot.hasError) {
              debugPrint('[AuthGate] Error fetching role: ${roleSnapshot.error}');
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
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'حدث خطأ أثناء التحميل',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          roleSnapshot.error.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Route based on role
            final role = roleSnapshot.data ?? 'user';
            debugPrint('[AuthGate] Routing decision - UID: $uid, Role: $role');
            
            if (role == 'owner') {
              debugPrint('[AuthGate] Routing to OwnerHomePage');
              return const OwnerHomePage();
            } else {
              debugPrint('[AuthGate] Routing to HomeShellPage (UserHome)');
              return const HomeShellPage();
            }
          },
        );
      },
    );
  }
}

