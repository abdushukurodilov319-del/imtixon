import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/admin.dart';
import '../features/auth.dart';
import '../features/student.dart';
import '../features/teacher.dart';

// Demo rejim uchun qo'lda rol tayinlash
final manualRoleProvider = StateProvider<String?>((ref) => null);
final loggedInUserEmailProvider = StateProvider<String?>((ref) => null);

final routerProvider = Provider<GoRouter>((ref) {
  final manualRole = ref.watch(manualRoleProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/admin/dashboard', builder: (context, state) => const AdminDashboardScreen()),
      GoRoute(path: '/teacher/dashboard', builder: (context, state) => const TeacherDashboardScreen()),
      GoRoute(path: '/student/dashboard', builder: (context, state) => const StudentDashboardScreen()),
    ],
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      
      // 1. Demo rejim tekshiruvi (manualRole orqali)
      if (manualRole != null) {
        if (isLoggingIn) {
          return '/$manualRole/dashboard';
        }
        return null;
      }

      // 2. Supabase sessiya tekshiruvi
      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        return isLoggingIn ? null : '/login';
      }

      return null;
    },
  );
});
