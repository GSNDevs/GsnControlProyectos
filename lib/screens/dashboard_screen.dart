import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);
    final profilesAsync = ref.watch(profilesProvider);

    String getClientName(String? clientId) {
      if (clientId == null) return 'Sin Cliente Asociado';
      final profiles = profilesAsync.value ?? [];
      try {
        return profiles.firstWhere((p) => p.id == clientId).fullName ??
            'Sin Nombre';
      } catch (_) {
        return 'ID: ${clientId.substring(0, 6)}...';
      }
    }

    return projectsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(
          'Error al cargar proyectos: $err',
          style: const TextStyle(color: Colors.red),
        ),
      ),
      data: (projects) {
        // Calculate KPIs
        final totalProjects = projects.length;
        final totalBudget = projects.fold(0.0, (sum, p) => sum + p.budgetTotal);
        final totalBilled = projects.fold(
          0.0,
          (sum, p) => sum + p.billedAmount,
        );
        final totalPending = totalBudget - totalBilled;

        final currencyFormat = NumberFormat.currency(
          locale: 'es_CL',
          symbol: '\$',
          decimalDigits: 0,
        );

        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Resumen General",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Métricas clave de los proyectos actuales",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // KPI Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      final isMobile = constraints.maxWidth < 600;
                      return GridView.count(
                        crossAxisCount: isWide ? 4 : (isMobile ? 1 : 2),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        shrinkWrap: true,
                        childAspectRatio: isWide ? 1.9 : 1.3,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _KpiCard(
                            title: "Proyectos Activos",
                            value: totalProjects.toString(),
                            icon: Icons.folder_open_rounded,
                            color: AppColors.gsnBlue,
                            gradient: AppColors.secondaryGradient,
                          ),
                          _KpiCard(
                            title: "Presupuesto Total",
                            value: currencyFormat.format(totalBudget),
                            icon: Icons.monetization_on_rounded,
                            color: AppColors.textPrimary,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF64748B), Color(0xFF334155)],
                            ),
                            isMoney: true,
                          ),
                          _KpiCard(
                            title: "Total Facturado",
                            value: currencyFormat.format(totalBilled),
                            icon: Icons.check_circle_rounded,
                            color: AppColors.success,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF047857)],
                            ),
                            isMoney: true,
                          ),
                          _KpiCard(
                            title: "Pendiente Cobro",
                            value: currencyFormat.format(totalPending),
                            icon: Icons.pending_actions_rounded,
                            color: AppColors.warning,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
                            ),
                            isMoney: true,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 48),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Proyectos Recientes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => context.go('/projects'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: const Text("Ver todos"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Projects List (Premium Layout)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: projects.take(5).length, // Only top 5
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.divider),
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return InkWell(
                          onTap: () => context.go('/projects/${project.id}'),
                          borderRadius: index == 0
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(20),
                                )
                              : index == (projects.take(5).length - 1)
                              ? const BorderRadius.vertical(
                                  bottom: Radius.circular(20),
                                )
                              : BorderRadius.zero,
                          hoverColor: AppColors.background,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(
                                      project.type,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(project.type),
                                    color: _getTypeColor(project.type),
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        project.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              _getStatusLabel(project.status),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: _getStatusColor(
                                                  project.status,
                                                ),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          if (project.clientId != null)
                                            Text(
                                              getClientName(project.clientId),
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                        ],
                                      ),
                                      if (isMobile) const SizedBox(height: 12),
                                      if (isMobile)
                                        _buildProgressColumn(project),
                                    ],
                                  ),
                                ),
                                if (!isMobile) const SizedBox(width: 24),
                                // Progress Column
                                if (!isMobile)
                                  SizedBox(
                                    width: 150,
                                    child: _buildProgressColumn(project),
                                  ),
                                if (!isMobile) const SizedBox(width: 24),
                                if (!isMobile)
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 24,
                                    color: AppColors.textSecondary,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProgressColumn(Project project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${project.progress}% Completado",
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: project.progress / 100,
            minHeight: 8,
            backgroundColor: AppColors.divider,
            color: _getStatusColor(project.status),
          ),
        ),
      ],
    );
  }

  IconData _getTypeIcon(ProjectType type) {
    switch (type) {
      case ProjectType.physical:
        return Icons.hardware_rounded;
      case ProjectType.software:
        return Icons.code_rounded;
      case ProjectType.hybrid:
        return Icons.merge_type_rounded;
    }
  }

  Color _getTypeColor(ProjectType type) {
    switch (type) {
      case ProjectType.physical:
        return const Color(0xFFF97316); // Orange-500
      case ProjectType.software:
        return const Color(0xFFA855F7); // Purple-500
      case ProjectType.hybrid:
        return AppColors.gsnBlue;
    }
  }

  String _getStatusLabel(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return "Planificación";
      case ProjectStatus.in_progress:
        return "En Progreso";
      case ProjectStatus.blocked:
        return "Bloqueado";
      case ProjectStatus.completed:
        return "Completado";
    }
  }

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning:
        return const Color(0xFF64748B); // Slate-500
      case ProjectStatus.in_progress:
        return AppColors.gsnBlue;
      case ProjectStatus.blocked:
        return AppColors.error;
      case ProjectStatus.completed:
        return AppColors.success;
    }
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final LinearGradient gradient;
  final bool isMoney;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
    this.isMoney = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              if (isMoney)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.trending_up_rounded,
                        color: AppColors.success,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        "+2.4%",
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
