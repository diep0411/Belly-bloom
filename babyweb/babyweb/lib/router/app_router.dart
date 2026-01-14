import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../page/login_page.dart';
import '../page/home_page.dart';
import '../page/content_page.dart';
import '../page/pregnancy_week_page.dart';
import '../page/exercise_page.dart';
import '../page/reminder_page.dart';
import '../page/admin_user.dart';
import '../service/base_common.dart';

class AppRouter {
  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      // Authentication Guard cho Admin Routes
      // Kiểm tra nếu đang truy cập vào admin routes
      if (state.matchedLocation.startsWith('/admin/') && 
          state.matchedLocation != '/') {
        
        // Kiểm tra xem user đã đăng nhập chưa
        await BaseCommon().checkLoginTest();
        final isLoggedIn = BaseCommon().isLogin;
        
        // Nếu chưa đăng nhập, redirect về trang login
        if (!isLoggedIn) {
          return '/';
        }
      }
      
      // Auto redirect: Nếu đã đăng nhập và đang ở trang login, redirect về dashboard
      if (state.matchedLocation == '/') {
        await BaseCommon().checkLoginTest();
        final isLoggedIn = BaseCommon().isLogin;
        
        if (isLoggedIn) {
          return '/admin/dashboard';
        }
      }
      
      return null; // Không redirect
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginPage(),
      ),
      
      // GoRoute(
      //   path: '/admin/login',
      //   name: 'admin/login',
      //   builder: (context, state) => const LoginPage(),
      // ),
      
      // Admin Shell Route
      ShellRoute(
        builder: (context, state, child) {
          return Homepage(child: child);
        },
        routes: [
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin_dashboard',
            builder: (context, state) => const ContentPage(),
          ),
          GoRoute(
            path: '/admin/pregnancy-weeks',
            name: 'admin_pregnancy_weeks',
            builder: (context, state) => const PregnancyWeekPage(),
          ),
          GoRoute(
            path: '/admin/exercises',
            name: 'admin_exercises',
            builder: (context, state) => const ExercisePage(),
          ),
          GoRoute(
            path: '/admin/content',
            name: 'admin_content',
            builder: (context, state) => const ContentPage(),
          ),
          GoRoute(
            path: '/admin/reminders',
            name: 'admin_reminders',
            builder: (context, state) => const ReminderPage(),
          ),
          GoRoute(
            path: '/admin/accounts',
            name: 'admin_accounts',
            builder: (context, state) => const AdminUserAccountList(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
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
              'Trang không tìm thấy',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Đường dẫn: ${state.matchedLocation}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/admin/dashboard'),
              child: const Text('Về trang chủ'),
            ),
          ],
        ),
      ),
    ),
  );

  static GoRouter get router => _router;
}
