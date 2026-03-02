import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';

class ClientPortalScreen extends ConsumerWidget {
  const ClientPortalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final profilesAsync = ref.watch(profilesProvider);

    String clientName = 'Cliente';
    if (user != null) {
      clientName = profilesAsync.maybeWhen(
        data: (profiles) {
          try {
            final p = profiles.firstWhere((p) => p.id == user.id);
            return p.fullName ?? p.email ?? 'Cliente';
          } catch (_) {
            return user.email;
          }
        },
        orElse: () => user.email,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Portal - GSN",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.gsnDarkBlue,
        foregroundColor: Colors.white,
        elevation: 10,
        shadowColor: AppColors.gsnBlue.withValues(alpha: 0.3),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.go('/client-portal/quotes');
            },
            icon: const Icon(Icons.request_quote, color: Colors.white),
            label: const Text("Cotizar", style: TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
        ),
        data: (allProjects) {
          final myProjects = allProjects
              .where((p) => p.clientId == user?.id)
              .toList();

          if (myProjects.isEmpty) {
            return const Center(
              child: Text(
                "No tienes proyectos asignados actualmente.",
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 600;
              return Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      clientName,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Bienvenido a tu portal. Aquí puedes monitorear el avance de tus proyectos de forma transparente.",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 400,
                          childAspectRatio: isMobile ? 1.0 : 1.25,
                          crossAxisSpacing: isMobile ? 16 : 24,
                          mainAxisSpacing: isMobile ? 16 : 24,
                        ),
                        itemCount: myProjects.length,
                        itemBuilder: (context, index) {
                          final project = myProjects[index];
                          return InkWell(
                            onTap: () => context.go(
                              '/client-portal/projects/${project.id}',
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.gsnBlue.withValues(
                                      alpha: 0.08,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                                border: Border.all(
                                  color: AppColors.gsnBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Stack(
                                  children: [
                                    // Gradient Top Border
                                    Positioned(
                                      top: 0,
                                      left: 0,
                                      right: 0,
                                      height: 6,
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(28.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getTypeColor(
                                                    project.type,
                                                  ).withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      _getTypeIcon(
                                                        project.type,
                                                      ),
                                                      size: 14,
                                                      color: _getTypeColor(
                                                        project.type,
                                                      ).withValues(alpha: 0.8),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      project.type.name
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            _getTypeColor(
                                                              project.type,
                                                            ).withValues(
                                                              alpha: 0.8,
                                                            ),
                                                        letterSpacing: 0.5,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right,
                                                color: AppColors.textSecondary
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 24),
                                          Text(
                                            project.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 20,
                                              color: AppColors.textPrimary,
                                              height: 1.3,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (project.tentativeEndDate !=
                                              null) ...[
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.calendar_today,
                                                  size: 14,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  "Fin estimado: ${DateFormat('dd/MM/yyyy').format(project.tentativeEndDate!)}",
                                                  style: const TextStyle(
                                                    color:
                                                        AppColors.textSecondary,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          const Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Progreso",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                              Text(
                                                "${project.progress}%",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.gsnBlue,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: project.progress / 100,
                                              minHeight: 8,
                                              color: AppColors.gsnBlue,
                                              backgroundColor: AppColors.gsnBlue
                                                  .withValues(alpha: 0.1),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    project.status,
                                                  ).withValues(alpha: 0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: _getStatusColor(
                                                      project.status,
                                                    ).withValues(alpha: 0.2),
                                                  ),
                                                ),
                                                child: Text(
                                                  _getStatusLabel(
                                                    project.status,
                                                  ),
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                    color: _getStatusColor(
                                                      project.status,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
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
        return const Color(0xFFF97316);
      case ProjectType.software:
        return const Color(0xFFA855F7);
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
        return const Color(0xFF64748B);
      case ProjectStatus.in_progress:
        return AppColors.gsnBlue;
      case ProjectStatus.blocked:
        return AppColors.error;
      case ProjectStatus.completed:
        return AppColors.success;
    }
  }
}
