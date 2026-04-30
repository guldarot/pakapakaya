import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_page.dart';
import '../../features/auth/application/auth_controller.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/chat/presentation/chat_page.dart';
import '../../features/discovery/presentation/discovery_page.dart';
import '../../features/orders/presentation/order_page.dart';
import '../../features/vendor/presentation/vendor_dashboard_page.dart';
import '../../features/vendor/presentation/vendor_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (session.isLoading) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }

      final isLoggedIn = session.isAuthenticated;
      final isLogin = state.matchedLocation == '/login';
      final isLoading = state.matchedLocation == '/loading';

      if (!isLoggedIn && !isLogin) {
        return '/login';
      }

      if (isLoggedIn && isLogin) {
        return '/';
      }

      if (isLoggedIn && isLoading) {
        return '/';
      }

      if (!isLoggedIn && isLoading) {
        return '/login';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const DiscoveryPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/vendor/:vendorId',
        builder: (context, state) => VendorPage(
          vendorId: state.pathParameters['vendorId']!,
        ),
      ),
      GoRoute(
        path: '/orders/:orderId',
        builder: (context, state) => OrderPage(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/chat/:orderId',
        builder: (context, state) => ChatPage(
          orderId: state.pathParameters['orderId']!,
        ),
      ),
      GoRoute(
        path: '/vendor-center',
        builder: (context, state) => const VendorDashboardPage(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminPage(),
      ),
    ],
  );
});
