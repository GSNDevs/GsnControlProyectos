import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';

class ResponsiveScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String title;

  const ResponsiveScaffold({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  ConsumerState<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends ConsumerState<ResponsiveScaffold> {
  bool _isSidebarOpen = true;

  void _toggleSidebar() {
    setState(() {
      _isSidebarOpen = !_isSidebarOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final user = ref.watch(authProvider);

    if (!isDesktop) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.title,
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: AppColors.gsnDarkBlue,
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        drawer: _buildDrawerContent(context, user),
        body: widget.child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Premium Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _isSidebarOpen ? 260 : 80,
            decoration: BoxDecoration(
              color: AppColors.gsnDarkBlue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(4, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildSidebarHeader(),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    children: [
                      _SidebarItem(
                        icon: Icons.dashboard_rounded,
                        label: "Dashboard",
                        isOpen: _isSidebarOpen,
                        route: '/',
                      ),
                      _SidebarItem(
                        icon: Icons.folder_rounded,
                        label: "Proyectos",
                        isOpen: _isSidebarOpen,
                        route: '/projects',
                      ),
                      _SidebarItem(
                        icon: Icons.inventory_2_rounded,
                        label: "Inventario",
                        isOpen: _isSidebarOpen,
                        route: '/inventory',
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8,
                        ),
                        child: Text(
                          _isSidebarOpen ? "ADMINISTRACIÓN" : "...",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      _SidebarItem(
                        icon: Icons.people_alt_rounded,
                        label: "Usuarios",
                        isOpen: _isSidebarOpen,
                        route: '/users',
                      ),
                      _SidebarItem(
                        icon: Icons.request_quote_rounded,
                        label: "Cotizaciones",
                        isOpen: _isSidebarOpen,
                        route: '/quotes',
                      ),
                      _SidebarItem(
                        icon: Icons.settings_rounded,
                        label: "Configuración",
                        isOpen: _isSidebarOpen,
                        route: '/settings',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                  ),
                  child: _isSidebarOpen
                      ? Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppColors.gsnRed,
                              radius: 18,
                              child: Text(
                                "AD",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.email ?? "Usuario",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    user?.role.toUpperCase() ?? "STAFF",
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.5,
                                      ),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.logout_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                              onPressed: () =>
                                  ref.read(authProvider.notifier).logout(),
                              tooltip: "Cerrar sesión",
                            ),
                          ],
                        )
                      : IconButton(
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: Colors.white70,
                          ),
                          onPressed: () =>
                              ref.read(authProvider.notifier).logout(),
                        ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Icon(
                            _isSidebarOpen
                                ? Icons.menu_open_rounded
                                : Icons.menu_rounded,
                            key: ValueKey(_isSidebarOpen),
                          ),
                        ),
                        onPressed: _toggleSidebar,
                        color: AppColors.textSecondary,
                        splashRadius: 24,
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const Spacer(),
                      // Optional: Notifications icon
                      IconButton(
                        icon: const Icon(Icons.notifications_none_rounded),
                        color: AppColors.textSecondary,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
                // Child
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      height: 70,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.only(left: _isSidebarOpen ? 24 : 0),
      child: _isSidebarOpen
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  "GSN Control",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            )
          : Center(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 22),
              ),
            ),
    );
  }

  Widget _buildDrawerContent(BuildContext context, User? user) {
    return Drawer(
      backgroundColor: AppColors.gsnDarkBlue,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.gsnDarkBlue),
            accountName: Text(user?.role.toUpperCase() ?? "STAFF"),
            accountEmail: Text(user?.email ?? "Usuario"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: AppColors.gsnRed,
              child: Text("GSN", style: TextStyle(color: Colors.white)),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded, color: Colors.white70),
            title: const Text(
              "Dashboard",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => context.go('/'),
          ),
          ListTile(
            leading: const Icon(Icons.folder_rounded, color: Colors.white70),
            title: const Text(
              "Proyectos",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => context.go('/projects'),
          ),
          ListTile(
            leading: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white70,
            ),
            title: const Text(
              "Inventario",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => context.go('/inventory'),
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: Colors.white70),
            title: const Text(
              "Cerrar Sesión",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => ref.read(authProvider.notifier).logout(),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isOpen;
  final String route;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isOpen,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected =
        GoRouterState.of(context).uri.toString() == route ||
        (route != '/' &&
            GoRouterState.of(context).uri.toString().startsWith(route));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.gsnBlue.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.gsnBlue.withValues(alpha: 0.3)
                  : Colors.transparent,
              style: BorderStyle.solid,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: isOpen
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              if (isOpen) const SizedBox(width: 16),
              Icon(
                icon,
                color: isSelected
                    ? AppColors.gsnBlue
                    : Colors.white.withValues(alpha: 0.6),
                size: 24,
              ),
              if (isOpen) ...[
                const SizedBox(width: 16),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.7),
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
