import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/widgets/responsive_scaffold.dart';
import 'package:gsn_control_de_proyectos/screens/dashboard_screen.dart';
import 'package:gsn_control_de_proyectos/screens/projects_screen.dart';
import 'package:gsn_control_de_proyectos/screens/inventory_screen.dart';
import 'package:gsn_control_de_proyectos/screens/login_screen.dart';
import 'package:gsn_control_de_proyectos/screens/project_detail_screen.dart';
import 'package:gsn_control_de_proyectos/screens/users_screen.dart';
import 'package:gsn_control_de_proyectos/screens/client_portal_screen.dart';
import 'package:gsn_control_de_proyectos/screens/portfolio_screen.dart';
import 'package:gsn_control_de_proyectos/screens/client_quotes_screen.dart';
import 'package:gsn_control_de_proyectos/screens/admin_quotes_screen.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState != null;
      final isLoginRoute = state.uri.toString() == '/login';
      final isPortfolioRoute = state.uri.toString() == '/portfolio';

      // Not logged in -> can only go to login or portfolio
      if (!isLoggedIn && !isLoginRoute && !isPortfolioRoute) {
        return '/login';
      }

      // Logged in user redirection
      if (isLoggedIn) {
        if (authState.role == 'client') {
          // Clients are restricted to the client portal
          if (!state.uri.toString().startsWith('/client-portal')) {
            return '/client-portal';
          }
        } else {
          // Admin / Staff restrict from login and client-portal (optional but good idea)
          if (state.uri.toString().startsWith('/client-portal') ||
              isLoginRoute) {
            return '/';
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/portfolio',
        builder: (context, state) => const PortfolioScreen(),
      ),
      GoRoute(
        path: '/client-portal',
        builder: (context, state) => const ClientPortalScreen(),
        routes: [
          GoRoute(
            path: 'projects/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Detalle de Proyecto",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  backgroundColor: AppColors.gsnDarkBlue,
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: AppColors.gsnBlue.withValues(alpha: 0.3),
                ),
                backgroundColor: AppColors.background,
                body: ProjectDetailScreen(projectId: id),
              );
            },
          ),
          GoRoute(
            path: 'quotes',
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text(
                    "Solicitudes de Cotización",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  centerTitle: true,
                  backgroundColor: AppColors.gsnDarkBlue,
                  foregroundColor: Colors.white,
                  elevation: 10,
                  shadowColor: AppColors.gsnBlue.withValues(alpha: 0.3),
                ),
                backgroundColor: AppColors.background,
                body: const ClientQuotesScreen(),
              );
            },
          ),
        ],
      ),
      ShellRoute(
        builder: (context, state, child) {
          // Determine title based on location
          String title = "Dashboard";
          final location = state.uri.toString();
          if (location.startsWith('/projects')) title = "Proyectos";
          if (location.startsWith('/inventory')) title = "Inventario";
          if (location.startsWith('/users')) title = "Usuarios";
          if (location.startsWith('/quotes')) title = "Cotizaciones";

          return ResponsiveScaffold(title: title, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/quotes',
            builder: (context, state) => const AdminQuotesScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text("Configuración"))),
          ),
        ],
      ),
    ],
  );
});
