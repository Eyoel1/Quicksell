import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_auth_service.dart';
import '../models/user_model.dart';

final authServiceProvider = Provider((ref) => FirebaseAuthService());

final authStateProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final user = authService.currentUser;
  if (user != null) {
    return await authService.getUserProfile(user.uid);
  }
  return null;
});

final signUpProvider = FutureProvider.family<UserModel?, Map<String, String>>(
  (ref, params) async {
    final authService = ref.watch(authServiceProvider);
    return await authService.signUp(
      email: params['email']!,
      password: params['password']!,
      displayName: params['displayName']!,
    );
  },
);

final loginProvider = FutureProvider.family<UserModel?, Map<String, String>>(
  (ref, params) async {
    final authService = ref.watch(authServiceProvider);
    return await authService.login(
      email: params['email']!,
      password: params['password']!,
    );
  },
);

final userProfileProvider = FutureProvider.family<UserModel?, String>(
  (ref, uid) async {
    final authService = ref.watch(authServiceProvider);
    return await authService.getUserProfile(uid);
  },
);
