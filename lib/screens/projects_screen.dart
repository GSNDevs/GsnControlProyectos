import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:intl/intl.dart';
// Reusing helpers from dashboard for now

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

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
        child: Text('Error: $err', style: const TextStyle(color: Colors.red)),
      ),
      data: (projects) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Toolbar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Todos los Proyectos",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Gestiona y monitorea todos los proyectos",
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: AppColors.softShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showCreateProjectDialog(context, ref),
                          icon: const Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                          ),
                          label: isMobile
                              ? const SizedBox.shrink()
                              : const Text(
                                  "Nuevo Proyecto",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 24,
                              vertical: isMobile ? 12 : 18,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Grid
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400,
                        childAspectRatio: isMobile ? 1.0 : 1.25,
                        crossAxisSpacing: isMobile ? 16 : 24,
                        mainAxisSpacing: isMobile ? 16 : 24,
                      ),
                      itemCount: projects.length,
                      itemBuilder: (context, index) {
                        final project = projects[index];
                        return InkWell(
                          onTap: () => context.go('/projects/${project.id}'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: AppColors.softShadow,
                            ),
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _getTypeColor(
                                          project.type,
                                        ).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            _getTypeIcon(project.type),
                                            size: 14,
                                            color: _getTypeColor(
                                              project.type,
                                            ).withValues(alpha: 0.8),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            project.type.name.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: _getTypeColor(
                                                project.type,
                                              ).withValues(alpha: 0.8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      icon: const Icon(
                                        Icons.more_horiz_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                      itemBuilder: (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 20),
                                              SizedBox(width: 8),
                                              Text("Editar Proyecto"),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditProjectDialog(
                                            context,
                                            ref,
                                            project,
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  project.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: AppColors.textPrimary,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  getClientName(project.clientId),
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Progreso",
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      "${project.progress}%",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gsnBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: project.progress / 100,
                                    minHeight: 8,
                                    color: _getStatusColor(project.status),
                                    backgroundColor: AppColors.divider,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.background,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getStatusLabel(project.status),
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _getStatusColor(
                                            project.status,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const CircleAvatar(
                                      radius: 14,
                                      backgroundColor: AppColors.background,
                                      child: Icon(
                                        Icons.group_rounded,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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

  void _showCreateProjectDialog(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final budgetCtrl = TextEditingController();
    final locationUrlCtrl = TextEditingController();
    ProjectType selectedType = ProjectType.physical;
    String? selectedClientId;
    String? selectedTemplateId;
    DateTime? selectedTentativeEndDate;

    showDialog(
      context: context,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final clientsAsync = ref.watch(clientsProvider);
          final projectsAsync = ref.watch(projectsProvider);

          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: const Text(
                  "Nuevo Proyecto",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                content: Container(
                  width: double.maxFinite,
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: nameCtrl,
                          decoration: InputDecoration(
                            labelText: "Nombre del Proyecto",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Client Dropdown
                        clientsAsync.when(
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (err, stack) => Text(
                            'Error cargando clientes: $err',
                            style: const TextStyle(color: Colors.red),
                          ),
                          data: (clients) {
                            return DropdownButtonFormField<String>(
                              initialValue: selectedClientId,
                              decoration: InputDecoration(
                                labelText: "Cliente",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: clients.map((client) {
                                return DropdownMenuItem(
                                  value: client.id,
                                  child: Text(
                                    client.fullName ??
                                        client.email ??
                                        'Sin Nombre',
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() => selectedClientId = val);
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ProjectType>(
                          initialValue: selectedType,
                          decoration: InputDecoration(
                            labelText: "Tipo de Proyecto",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          items: ProjectType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name.toUpperCase()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => selectedType = val);
                          },
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: budgetCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: "Presupuesto Total",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate:
                                  selectedTentativeEndDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2050),
                            );
                            if (date != null) {
                              setState(() => selectedTentativeEndDate = date);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade400),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  selectedTentativeEndDate == null
                                      ? "Fecha estimada de fin (Opcional)"
                                      : "Fin estimado: ${DateFormat('dd/MM/yyyy').format(selectedTentativeEndDate!)}",
                                  style: TextStyle(
                                    color: selectedTentativeEndDate == null
                                        ? Colors.grey.shade700
                                        : AppColors.textPrimary,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(
                                  Icons.calendar_today,
                                  color: AppColors.gsnBlue,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: locationUrlCtrl,
                          decoration: InputDecoration(
                            labelText: "Enlace de Ubicación (Google Maps)",
                            hintText:
                                "Opcional. Ej: https://maps.app.goo.gl/...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Existing Projects Template Dropdown
                        projectsAsync.when(
                          loading: () => const SizedBox(),
                          error: (err, stack) => const SizedBox(),
                          data: (projects) {
                            if (projects.isEmpty) return const SizedBox();
                            return DropdownButtonFormField<String>(
                              initialValue: selectedTemplateId,
                              decoration: InputDecoration(
                                labelText:
                                    "Clonar estructura desde... (Opcional)",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                helperText:
                                    "Copia las fases y tareas del proyecto seleccionado.",
                                helperMaxLines: 2,
                              ),
                              items: [
                                const DropdownMenuItem<String>(
                                  value: null,
                                  child: Text("Ninguno (Proyecto en blanco)"),
                                ),
                                ...projects.map((proj) {
                                  return DropdownMenuItem(
                                    value: proj.id,
                                    child: Text(
                                      proj.name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }),
                              ],
                              onChanged: (val) {
                                setState(() => selectedTemplateId = val);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        if (nameCtrl.text.isEmpty) return;

                        final newProject = {
                          'name': nameCtrl.text,
                          'client_id': selectedClientId,
                          'type': selectedType.name,
                          'status': ProjectStatus.planning.name,
                          'budget_total': double.tryParse(budgetCtrl.text) ?? 0,
                          'progress': 0,
                          'location_url': locationUrlCtrl.text.trim().isEmpty
                              ? null
                              : locationUrlCtrl.text.trim(),
                          'tentative_end_date': selectedTentativeEndDate
                              ?.toIso8601String(),
                          'created_at': DateTime.now().toIso8601String(),
                        };

                        if (selectedTemplateId != null) {
                          ref
                              .read(projectsControllerProvider)
                              .cloneProject(newProject, selectedTemplateId!);
                        } else {
                          ref
                              .read(projectsControllerProvider)
                              .createProject(newProject);
                        }

                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Crear Proyecto",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showEditProjectDialog(
    BuildContext context,
    WidgetRef ref,
    Project project,
  ) {
    final nameCtrl = TextEditingController(text: project.name);
    final budgetCtrl = TextEditingController(
      text: project.budgetTotal.toString(),
    );
    final locationUrlCtrl = TextEditingController(
      text: project.locationUrl ?? '',
    );
    DateTime? selectedTentativeEndDate = project.tentativeEndDate;
    ProjectStatus selectedStatus = project.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "Editar Proyecto",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Container(
              width: double.maxFinite,
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: "Nombre del Proyecto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProjectStatus>(
                      initialValue: selectedStatus,
                      decoration: InputDecoration(
                        labelText: "Estado del Proyecto",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: ProjectStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(_getStatusLabel(status)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedStatus = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate:
                              selectedTentativeEndDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2050),
                        );
                        if (date != null) {
                          setState(() => selectedTentativeEndDate = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedTentativeEndDate == null
                                  ? "Fecha estimada de fin (Opcional)"
                                  : "Fin estimado: ${DateFormat('dd/MM/yyyy').format(selectedTentativeEndDate!)}",
                              style: TextStyle(
                                color: selectedTentativeEndDate == null
                                    ? Colors.grey.shade700
                                    : AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.gsnBlue,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: budgetCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Presupuesto Total",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: locationUrlCtrl,
                      decoration: InputDecoration(
                        labelText: "Enlace de Ubicación (Google Maps)",
                        hintText: "Opcional",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: AppColors.softShadow,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;

                    final updates = {
                      'name': nameCtrl.text,
                      'status': selectedStatus.name,
                      'budget_total': double.tryParse(budgetCtrl.text) ?? 0,
                      'location_url': locationUrlCtrl.text.trim().isEmpty
                          ? null
                          : locationUrlCtrl.text.trim(),
                      'tentative_end_date': selectedTentativeEndDate
                          ?.toIso8601String(),
                      'updated_at': DateTime.now().toIso8601String(),
                    };

                    ref
                        .read(projectsControllerProvider)
                        .updateProject(project.id, updates);

                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Guardar Cambios",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
