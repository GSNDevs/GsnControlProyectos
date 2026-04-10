import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientPortalScreen extends ConsumerStatefulWidget {
  const ClientPortalScreen({super.key});

  @override
  ConsumerState<ClientPortalScreen> createState() => _ClientPortalScreenState();
}

class _ClientPortalScreenState extends ConsumerState<ClientPortalScreen> {
  int _selectedNavIndex = 0; // 0 = Dashboard, 1 = Cotizaciones, 2 = Cambiar Contraseña

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final profilesAsync = ref.watch(profilesProvider);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    String clientName = 'Cliente';
    String? userClientId;
    if (user != null) {
      profilesAsync.whenData((profiles) {
        try {
          final p = profiles.firstWhere((p) => p.id == user.id);
          clientName = p.fullName ?? p.email ?? 'Cliente';
          userClientId = p.clientId;
        } catch (_) {
          clientName = user.email;
        }
      });
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Row(
        children: [
          // ─── SIDEBAR ────────────────────────────────────────────────────────
          if (isDesktop)
            _buildSidebar(context, user),

          // ─── MAIN CONTENT ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              children: [
                // Top bar / header
                _buildTopBar(context, isDesktop, user, clientName),

                // Content
                Expanded(
                  child: _buildContent(
                    context,
                    ref,
                    projectsAsync,
                    profilesAsync,
                    userClientId,
                    clientName,
                    isDesktop,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom nav for mobile
      bottomNavigationBar: isDesktop
          ? null
          : _buildBottomNav(context),
    );
  }

  Widget _buildSidebar(BuildContext context, dynamic user) {
    return Container(
      width: 256,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand header
          Container(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shield, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "GSN Control",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF001F3F),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  "PORTAL CLIENTES",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF94A3B8),
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Nav items
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _SidebarNavItem(
                  icon: Icons.dashboard_rounded,
                  label: "Dashboard",
                  isActive: _selectedNavIndex == 0,
                  onTap: () => setState(() => _selectedNavIndex = 0),
                ),
                _SidebarNavItem(
                  icon: Icons.request_quote_rounded,
                  label: "Cotizaciones",
                  isActive: _selectedNavIndex == 1,
                  onTap: () {
                    setState(() => _selectedNavIndex = 1);
                    context.go('/client-portal/quotes');
                  },
                ),
                _SidebarNavItem(
                  icon: Icons.lock_outline_rounded,
                  label: "Cambiar Contraseña",
                  isActive: _selectedNavIndex == 2,
                  onTap: () {
                    setState(() => _selectedNavIndex = 2);
                    _showChangePasswordDialog(context);
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // View Projects CTA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00658D), Color(0xFF00A0DC)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00658D).withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _selectedNavIndex = 0),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open_rounded, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          "Ver Proyectos",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Divider + logout
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 32),
            child: Column(
              children: [
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 8),
                _SidebarNavItem(
                  icon: Icons.logout_rounded,
                  label: "Cerrar Sesión",
                  isActive: false,
                  isDestructive: true,
                  onTap: () => ref.read(authProvider.notifier).logout(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, bool isDesktop, dynamic user, String clientName) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop) ...[
            // Mobile hamburger
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Color(0xFF64748B)),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Page title
          Text(
            _selectedNavIndex == 0 ? "Dashboard" : "Cotizaciones",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // User pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (clientName.isNotEmpty ? clientName[0] : 'C').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  clientName.split(' ').first,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<Project>> projectsAsync,
    AsyncValue<List<Profile>> profilesAsync,
    String? userClientId,
    String clientName,
    bool isDesktop,
  ) {
    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (allProjects) {
        // Load userClientId from profiles
        String? resolvedClientId = userClientId;
        profilesAsync.whenData((profiles) {
          final user = ref.read(authProvider);
          try {
            final p = profiles.firstWhere((p) => p.id == user?.id);
            resolvedClientId = p.clientId;
          } catch (_) {}
        });

        final myProjects = allProjects
            .where((p) => p.clientId == resolvedClientId && resolvedClientId != null)
            .toList();

        final totalProgress = myProjects.isEmpty
            ? 0
            : (myProjects.fold(0, (sum, p) => sum + p.progress) / myProjects.length).round();

        final inProgressCount = myProjects.where((p) => p.status == ProjectStatus.in_progress).length;

        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 40 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── HERO GREETING ─────────────────────────────────────────────
              Text(
                "Bienvenido, ${clientName.split(' ').first}",
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  letterSpacing: -1,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Monitorea el avance de tus proyectos en tiempo real.",
                style: TextStyle(
                  color: const Color(0xFF64748B),
                  fontSize: isDesktop ? 18 : 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // ─── BENTO SUMMARY CARDS ────────────────────────────────────────
              if (myProjects.isNotEmpty) ...[
                LayoutBuilder(builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 640;
                  return isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Proyectos Activos
                            Expanded(
                              flex: 1,
                              child: _BentoCard(
                                accentColor: const Color(0xFF00A0DC),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "PROYECTOS ACTIVOS",
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      myProjects.length.toString().padLeft(2, '0'),
                                      style: const TextStyle(
                                        fontSize: 64,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF00658D),
                                        letterSpacing: -3,
                                        height: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Progreso general
                            Expanded(
                              flex: 2,
                              child: _BentoCard(
                                accentColor: const Color(0xFFD7811B),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "PROGRESO GENERAL",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF94A3B8),
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        Text(
                                          "$totalProgress%",
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFD7811B),
                                            letterSpacing: -1,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: LinearProgressIndicator(
                                        value: totalProgress / 100,
                                        minHeight: 14,
                                        backgroundColor: const Color(0xFFE2E8F0),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A0DC)),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text("Iniciado", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                        Text("En Proceso", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                        Text("Cierre", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _BentoCard(
                              accentColor: const Color(0xFF00A0DC),
                              child: Row(
                                children: [
                                  Text(
                                    myProjects.length.toString().padLeft(2, '0'),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF00658D),
                                      letterSpacing: -2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text("Proyectos\nActivos", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.4)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _BentoCard(
                              accentColor: const Color(0xFFD7811B),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Progreso General", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                                      Text("$totalProgress%", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFFD7811B))),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: LinearProgressIndicator(
                                      value: totalProgress / 100,
                                      minHeight: 10,
                                      backgroundColor: const Color(0xFFE2E8F0),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00A0DC)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                }),
                const SizedBox(height: 48),
              ],

              // ─── PROJECTS SECTION ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tus Proyectos",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        "Estado actual de cada proyecto asignado.",
                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      ),
                    ],
                  ),
                  if (myProjects.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text("Ver todos"),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF00658D)),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              if (myProjects.isEmpty)
                _buildEmptyState()
              else
                LayoutBuilder(builder: (context, constraints) {
                  final twoCol = constraints.maxWidth > 700;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: twoCol ? 2 : 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      childAspectRatio: twoCol ? 1.35 : 1.6,
                    ),
                    itemCount: myProjects.length,
                    itemBuilder: (context, index) {
                      return _buildProjectCard(context, myProjects[index]);
                    },
                  );
                }),

              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectCard(BuildContext context, Project project) {
    final statusColor = _getStatusColor(project.status);
    final typeColor = _getTypeColor(project.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.go('/client-portal/projects/${project.id}'),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                // Accent top line
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [typeColor, typeColor.withValues(alpha: 0.4)],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge + type badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusColor.withValues(alpha: 0.25)),
                            ),
                            child: Text(
                              _getStatusLabel(project.status).toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Icon(_getTypeIcon(project.type), size: 10, color: typeColor),
                                const SizedBox(width: 4),
                                Text(
                                  project.type.name.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: typeColor,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Project name
                      Text(
                        project.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.3,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      if (project.tentativeEndDate != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                            const SizedBox(width: 5),
                            Text(
                              "Fin estimado: ${DateFormat('dd/MM/yyyy').format(project.tentativeEndDate!)}",
                              style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      ],

                      const Spacer(),

                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Avance del Hito",
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                          ),
                          Text(
                            "${project.progress}%",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF00658D)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: project.progress / 100,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            project.progress >= 80 ? AppColors.success : const Color(0xFF00A0DC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Bottom action
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => context.go('/client-portal/projects/${project.id}'),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  "Ver Detalles",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF00658D),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(64),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF00658D).withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.folder_open_rounded, size: 40, color: Color(0xFF00658D)),
          ),
          const SizedBox(height: 20),
          const Text(
            "Sin proyectos asignados",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "No tienes proyectos asignados actualmente.\nContacta a tu gestor de proyecto para más información.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _BottomNavItem(
              icon: Icons.dashboard_rounded,
              label: "Inicio",
              isActive: _selectedNavIndex == 0,
              onTap: () => setState(() => _selectedNavIndex = 0),
            ),
            _BottomNavItem(
              icon: Icons.request_quote_rounded,
              label: "Cotizaciones",
              isActive: _selectedNavIndex == 1,
              onTap: () {
                setState(() => _selectedNavIndex = 1);
                context.go('/client-portal/quotes');
              },
            ),
            _BottomNavItem(
              icon: Icons.lock_outline_rounded,
              label: "Contraseña",
              isActive: _selectedNavIndex == 2,
              onTap: () {
                setState(() => _selectedNavIndex = 2);
                _showChangePasswordDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────────────────────────

  IconData _getTypeIcon(ProjectType type) {
    switch (type) {
      case ProjectType.physical: return Icons.hardware_rounded;
      case ProjectType.software: return Icons.code_rounded;
      case ProjectType.hybrid: return Icons.merge_type_rounded;
    }
  }

  Color _getTypeColor(ProjectType type) {
    switch (type) {
      case ProjectType.physical: return const Color(0xFFF97316);
      case ProjectType.software: return const Color(0xFFA855F7);
      case ProjectType.hybrid: return const Color(0xFF00A0DC);
    }
  }

  String _getStatusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning: return "Planificación";
      case ProjectStatus.in_progress: return "En Progreso";
      case ProjectStatus.blocked: return "Bloqueado";
      case ProjectStatus.completed: return "Completado";
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning: return const Color(0xFF64748B);
      case ProjectStatus.in_progress: return const Color(0xFF00658D);
      case ProjectStatus.blocked: return AppColors.error;
      case ProjectStatus.completed: return AppColors.success;
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Cambiar Contraseña",
            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
          ),
          content: SizedBox(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Nueva Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) => v == null || v.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Confirmar Nueva Contraseña",
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (v) {
                      if (v != passCtrl.text) return 'Las contraseñas no coinciden';
                      if (v == null || v.isEmpty) return 'Requerido';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isLoading = true);
                          try {
                            await Supabase.instance.client.auth.updateUser(
                              UserAttributes(password: passCtrl.text),
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Contraseña actualizada exitosamente")),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al actualizar: $e"),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          } finally {
                            if (context.mounted) setState(() => isLoading = false);
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text("Actualizar"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMPONENTS ────────────────────────────────────────────────────────────────

class _BentoCard extends StatelessWidget {
  final Widget child;
  final Color accentColor;

  const _BentoCard({required this.child, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent bar
          Container(
            height: 4,
            width: 40,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF00658D);
    final textColor = isDestructive
        ? AppColors.error
        : isActive
            ? activeColor
            : const Color(0xFF475569);
    final bgColor = isActive ? activeColor.withValues(alpha: 0.08) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: textColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFF00658D);
    final color = isActive ? activeColor : const Color(0xFF94A3B8);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
