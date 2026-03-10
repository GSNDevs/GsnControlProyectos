import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';

import 'user_documents_dialog.dart';

class ProjectTeamTab extends ConsumerStatefulWidget {
  final Project project;
  final bool isClient;

  const ProjectTeamTab({
    super.key,
    required this.project,
    required this.isClient,
  });

  @override
  ConsumerState<ProjectTeamTab> createState() => _ProjectTeamTabState();
}

class _ProjectTeamTabState extends ConsumerState<ProjectTeamTab> {
  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(projectMembersProvider(widget.project.id));
    final profilesAsync = ref.watch(profilesProvider);
    final user = ref.watch(authProvider);

    if (membersAsync.isLoading || profilesAsync.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (membersAsync.hasError) {
      return Center(child: Text("Error: ${membersAsync.error}"));
    }

    final members = membersAsync.value ?? [];
    final activeMembers = members.where((m) => m.isActive).toList();
    final profiles = profilesAsync.value ?? [];

    final canManageMembers = (user?.role == 'admin' || user?.role == 'supervisor') && !widget.isClient;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Equipo del Proyecto",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              if (canManageMembers)
                ElevatedButton.icon(
                  onPressed: () => _showAddMemberDialog(context, activeMembers, profiles),
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text("Asignar Usuario"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gsnBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (activeMembers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.group_off_rounded, size: 60, color: AppColors.textSecondary.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    const Text(
                      "No hay usuarios asignados a este proyecto.",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: activeMembers.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.divider),
                itemBuilder: (context, index) {
                  final member = activeMembers[index];
                  final profile = profiles.firstWhere(
                    (p) => p.id == member.profileId,
                    orElse: () => Profile(
                      id: member.profileId,
                      role: 'staff',
                      createdAt: DateTime.now(),
                      fullName: 'Usuario Eliminado',
                    ),
                  );

                  return _buildMemberCard(context, member, profile, user);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, ProjectMember member, Profile profile, User? currentUser) {
    final canManageMembers = (currentUser?.role == 'admin' || currentUser?.role == 'supervisor') && !widget.isClient;
    final canViewDocs = canManageMembers || widget.isClient;
    
    // Only show "Ver Documentos" if the user has a relevant role. 
    // Usually only staff, developer, supervisor have safety documents.
    final needsDocuments = ['staff', 'supervisor', 'developer'].contains(profile.role);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.gsnBlue.withValues(alpha: 0.1),
            child: Text(
              (profile.fullName ?? profile.email ?? '?')[0].toUpperCase(),
              style: const TextStyle(
                color: AppColors.gsnBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName ?? profile.email ?? 'Desconocido',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    profile.role.toUpperCase(),
                    style: const TextStyle(fontSize: 10, color: AppColors.gsnBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          if (needsDocuments && canViewDocs)
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => UserDocumentsDialog(
                    profile: profile,
                    project: widget.project,
                    isClientView: widget.isClient,
                  ),
                );
              },
              icon: const Icon(Icons.assignment_ind_rounded, size: 18),
              label: const Text("Documentos"),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
              ),
            ),
          if (canManageMembers) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.person_remove_rounded, color: AppColors.error),
              tooltip: "Desactivar del proyecto",
              onPressed: () => _confirmRemoveMember(context, member),
            ),
          ]
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, List<ProjectMember> activeMembers, List<Profile> profiles) {
    // Only allow assigning staff, supervisors, and developers. No clients or public.
    final selectableRoles = ['staff', 'supervisor', 'developer'];
    
    // Filter profiles that are enabled and have a valid role
    final availableProfiles = profiles.where((p) {
      if (!p.enabled) return false;
      if (!selectableRoles.contains(p.role)) return false;
      // Also filter out already active members
      if (activeMembers.any((m) => m.profileId == p.id)) return false;
      return true;
    }).toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Asignar Usuario al Proyecto"),
          content: SizedBox(
            width: 400,
            child: availableProfiles.isEmpty
                ? const Text("No hay usuarios adicionales disponibles para asignar.")
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = availableProfiles[index];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            (profile.fullName ?? profile.email ?? '?')[0].toUpperCase(),
                          ),
                        ),
                        title: Text(profile.fullName ?? profile.email ?? 'Desconocido'),
                        subtitle: Text(profile.role.toUpperCase()),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Check if the member exists but is deactivated
                              final membersAsync = ref.read(projectMembersProvider(widget.project.id));
                              final allMembers = membersAsync.value ?? [];
                              final existingMember = allMembers.where((m) => m.profileId == profile.id).firstOrNull;

                              if (existingMember != null) {
                                // Reactivate
                                await ref.read(projectMembersControllerProvider).updateMemberStatus(
                                  widget.project.id, 
                                  existingMember.id, 
                                  true
                                );
                              } else {
                                // Add new
                                await ref.read(projectMembersControllerProvider).addMember(
                                  widget.project.id, 
                                  profile.id
                                );
                              }
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Usuario asignado correctamente.")),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Error al asignar: $e")),
                                );
                              }
                            }
                          },
                          child: const Text("Agregar"),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _confirmRemoveMember(BuildContext context, ProjectMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Desactivar Usuario del Proyecto"),
        content: const Text(
          "¿Estás seguro de desactivar a este usuario del proyecto? Mantendrá su historial en las tareas pero ya no podrá acceder a él."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(projectMembersControllerProvider).updateMemberStatus(
                  widget.project.id, 
                  member.id, 
                  false
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Usuario desactivado del proyecto.")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error al desactivar: $e")),
                  );
                }
              }
            },
            child: const Text("Desactivar", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
