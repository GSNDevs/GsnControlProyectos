import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';

class ProjectDetailScreen extends ConsumerStatefulWidget {
  final String projectId;

  const ProjectDetailScreen({super.key, required this.projectId});

  @override
  ConsumerState<ProjectDetailScreen> createState() =>
      _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends ConsumerState<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectsProvider);
    final user = ref.watch(authProvider);
    final isClient = user?.role == 'client';

    return projectsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      data: (projects) {
        Project project;
        try {
          project = projects.firstWhere((p) => p.id == widget.projectId);
        } catch (e) {
          return const Scaffold(
            body: Center(child: Text("Proyecto no encontrado")),
          );
        }

        final tabs = isClient
            ? const [
                Tab(text: "Detalles"),
                Tab(text: "Hitos y Tareas"),
                Tab(text: "Notif. & Aprobaciones"),
                Tab(text: "Informes de Avance"),
              ]
            : const [
                Tab(text: "Detalles"),
                Tab(text: "Hitos y Tareas"),
                Tab(text: "Inventario Asignado"),
                Tab(text: "Archivos"),
                Tab(text: "Informes de Avance"),
                Tab(text: "Cobros"),
              ];

        final tabViews = isClient
            ? [
                _OverviewTab(project: project),
                _ClientMilestonesTab(project: project),
                _ClientNotificationsTab(project: project),
                _ReportsTab(project: project, isClient: true),
              ]
            : [
                _OverviewTab(project: project),
                _MilestonesTab(project: project),
                _InventoryTab(projectId: project.id),
                _DocumentsTab(project: project),
                _ReportsTab(project: project, isClient: false),
                _BillingTab(project: project),
              ];

        return DefaultTabController(
          length: tabs.length,
          child: Column(
            children: [
              // Header
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gsnBlue.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: AppColors.gsnBlue.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
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
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.arrow_back),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: project.type == ProjectType.physical
                                        ? Colors.orange.withValues(alpha: 0.1)
                                        : project.type == ProjectType.software
                                        ? Colors.purple.withValues(alpha: 0.1)
                                        : Colors.teal.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        project.type == ProjectType.physical
                                            ? Icons.construction
                                            : project.type ==
                                                  ProjectType.software
                                            ? Icons.code
                                            : Icons.layers,
                                        size: 14,
                                        color:
                                            project.type == ProjectType.physical
                                            ? Colors.orange
                                            : project.type ==
                                                  ProjectType.software
                                            ? Colors.purple
                                            : Colors.teal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        project.type.name.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              project.type ==
                                                  ProjectType.physical
                                              ? Colors.orange
                                              : project.type ==
                                                    ProjectType.software
                                              ? Colors.purple
                                              : Colors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
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
                                      color: _getStatusColor(project.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Consumer(
                              builder: (context, ref, _) {
                                final profilesAsync = ref.watch(
                                  profilesProvider,
                                );
                                if (project.clientId == null)
                                  return const SizedBox();
                                return profilesAsync.maybeWhen(
                                  data: (profiles) {
                                    try {
                                      final p = profiles.firstWhere(
                                        (p) => p.id == project.clientId,
                                      );
                                      final clientName =
                                          p.fullName ?? p.email ?? 'Sin Nombre';
                                      return Text(
                                        clientName,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      );
                                    } catch (_) {
                                      return Text(
                                        'ID: ${project.clientId!.substring(0, 6)}...',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                      );
                                    }
                                  },
                                  orElse: () =>
                                      const Text("Cargando cliente..."),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppColors.softShadow,
                ),
                child: TabBar(
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: isClient
                      ? AppColors.gsnDarkBlue
                      : AppColors.gsnBlue,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: isClient
                      ? AppColors.gsnDarkBlue
                      : AppColors.gsnBlue,
                  tabs: tabs,
                ),
              ),

              // Tab View
              Expanded(child: TabBarView(children: tabViews)),
            ],
          ),
        );
      },
    );
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
        return Colors.blueGrey;
      case ProjectStatus.in_progress:
        return AppColors.gsnBlue;
      case ProjectStatus.blocked:
        return AppColors.error;
      case ProjectStatus.completed:
        return AppColors.success;
    }
  }
}

class _OverviewTab extends ConsumerWidget {
  final Project project;

  const _OverviewTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(locale: 'es_CL', symbol: '\$');
    final profilesAsync = ref.watch(profilesProvider);
    final isClient = ref.watch(authProvider)?.role == 'client';

    String getClientName(String? clientId) {
      if (clientId == null) return 'N/A';
      final profiles = profilesAsync.value ?? [];
      try {
        return profiles.firstWhere((p) => p.id == clientId).fullName ??
            'Sin Nombre';
      } catch (_) {
        return 'ID: ${clientId.substring(0, 6)}...';
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        final leftColumn = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Información General",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _DetailRow(
                  label: "Cliente",
                  value: getClientName(project.clientId),
                ),
                _DetailRow(
                  label: "Tipo",
                  value: project.type.name.toUpperCase(),
                ),
                if (project.type == ProjectType.physical ||
                    project.type == ProjectType.hybrid)
                  _DetailRow(
                    label: "Dirección",
                    value: project.detailsPhysical?.address ?? 'N/A',
                  ),
                if (project.type == ProjectType.software ||
                    project.type == ProjectType.hybrid)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 120,
                          child: Text(
                            "Repositorio",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child:
                              (project.detailsSoftware?.repoUrl != null &&
                                  project.detailsSoftware!.repoUrl!.isNotEmpty)
                              ? InkWell(
                                  onTap: () async {
                                    final urlStr =
                                        project.detailsSoftware!.repoUrl!;
                                    final url = Uri.parse(
                                      urlStr.startsWith('http')
                                          ? urlStr
                                          : 'https://\$urlStr',
                                    );
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(
                                        url,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Text(
                                    "En la nube (Ver Enlace)",
                                    style: const TextStyle(
                                      color: AppColors.gsnBlue,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                )
                              : const Text(
                                  "On Premise",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),

                const Divider(height: 32),
                const Text(
                  "Descripción",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
                ),
              ],
            ),
          ),
        );

        final rightColumn = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Finanzas",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _MoneyRow(
                  label: "Presupuesto",
                  value: project.budgetTotal,
                  format: currencyFormat,
                ),
                _MoneyRow(
                  label: "Facturado",
                  value: project.billedAmount,
                  format: currencyFormat,
                  color: AppColors.success,
                ),
                const Divider(),
                _MoneyRow(
                  label: "Pendiente",
                  value: project.pendingAmount,
                  format: currencyFormat,
                  color: AppColors.warning,
                ),
              ],
            ),
          ),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          child: isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    leftColumn,
                    if (!isClient) const SizedBox(height: 24),
                    if (!isClient) rightColumn,
                  ],
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: leftColumn),
                    if (!isClient) const SizedBox(width: 24),
                    if (!isClient) Expanded(flex: 1, child: rightColumn),
                  ],
                ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyRow extends StatelessWidget {
  final String label;
  final double value;
  final NumberFormat format;
  final Color? color;

  const _MoneyRow({
    required this.label,
    required this.value,
    required this.format,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.textSecondary)),
          Text(
            format.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestonesTab extends ConsumerWidget {
  final Project project;
  const _MilestonesTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String projectId = project.id;
    final iterationsAsync = ref.watch(iterationsProvider(projectId));

    return iterationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (iterations) {
        if (iterations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.timeline,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text("No hay fases/sprints definidos."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showCreateIterationDialog(context, ref, projectId);
                  },
                  child: const Text("Crear Primera Fase"),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _showCreateIterationDialog(context, ref, projectId),
            icon: const Icon(Icons.add),
            label: const Text("Añadir Fase"),
            backgroundColor: AppColors.gsnBlue,
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: iterations.length,
            itemBuilder: (context, index) {
              final iteration = iterations[index];
              final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gsnBlue.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: AppColors.gsnBlue,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  iteration.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${iteration.startDate != null ? dateFormat.format(iteration.startDate!) : 'N/A'} - ${iteration.endDate != null ? dateFormat.format(iteration.endDate!) : 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.approved)
                            const Chip(
                              label: Text("Aprobado Cliente"),
                              backgroundColor: Color(0xFFD1FAE5),
                              labelStyle: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 12,
                              ),
                            )
                          else if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.rejected)
                            const Chip(
                              label: Text("Rechazado Cliente"),
                              backgroundColor: Color(0xFFFEE2E2),
                              labelStyle: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                              ),
                            )
                          else if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.pending)
                            OutlinedButton.icon(
                              onPressed: () {
                                if (project.clientId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No hay cliente asignado al proyecto',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                ref
                                    .read(iterationsControllerProvider)
                                    .requestClientApproval(
                                      project.id,
                                      iteration.id,
                                      iteration.name,
                                      project.clientId!,
                                    );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Solicitud enviada al cliente',
                                    ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check, size: 16),
                              label: const Text("Solicitar Aprobación"),
                            ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) async {
                              if (value == 'edit') {
                                _showEditIterationDialog(
                                  context,
                                  ref,
                                  projectId,
                                  iteration,
                                );
                              } else if (value == 'delete') {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Eliminar Fase"),
                                    content: const Text(
                                      "¿Estás seguro de que deseas eliminar esta fase? Esto no se puede deshacer.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: const Text("Cancelar"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text(
                                          "Eliminar",
                                          style: TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  ref
                                      .read(iterationsControllerProvider)
                                      .deleteIteration(projectId, iteration.id);
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18),
                                    SizedBox(width: 8),
                                    Text('Editar Fase'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      color: AppColors.error,
                                      size: 18,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Eliminar Fase',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Tasks List for this iteration
                    _TasksList(iterationId: iteration.id),

                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextButton.icon(
                        onPressed: () =>
                            _showCreateTaskDialog(context, ref, iteration.id),
                        icon: const Icon(Icons.add),
                        label: const Text("Agregar Tarea"),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TasksList extends ConsumerWidget {
  final String iterationId;
  const _TasksList({required this.iterationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(iterationId));

    return tasksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error al cargar tareas: $err'),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No hay tareas en esta fase."),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final task = tasks[i];
            return InkWell(
              onTap: () =>
                  _showTaskDetailDialog(context, ref, task, iterationId),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PopupMenuButton<TaskStatus>(
                      initialValue: task.status,
                      tooltip: "Cambiar estado",
                      onSelected: (newStatus) {
                        ref
                            .read(tasksControllerProvider)
                            .updateTaskStatus(iterationId, task.id, newStatus);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: TaskStatus.todo,
                          child: Text("Por hacer"),
                        ),
                        const PopupMenuItem(
                          value: TaskStatus.doing,
                          child: Text("En progreso"),
                        ),
                        const PopupMenuItem(
                          value: TaskStatus.done,
                          child: Text("Completado"),
                        ),
                      ],
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Icon(
                          task.status == TaskStatus.done
                              ? Icons.check_circle
                              : task.status == TaskStatus.doing
                              ? Icons.timelapse
                              : Icons.radio_button_unchecked,
                          color: task.status == TaskStatus.done
                              ? AppColors.success
                              : task.status == TaskStatus.doing
                              ? AppColors.warning
                              : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              decoration: task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.status == TaskStatus.done
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (task.assignedTo.isNotEmpty)
                            Consumer(
                              builder: (context, ref, _) {
                                final profilesAsync = ref.watch(
                                  profilesProvider,
                                );
                                return profilesAsync.maybeWhen(
                                  data: (profiles) {
                                    final names = task.assignedTo
                                        .map((id) {
                                          try {
                                            final p = profiles.firstWhere(
                                              (profile) => profile.id == id,
                                            );
                                            return p.fullName ?? p.email ?? id;
                                          } catch (e) {
                                            return id;
                                          }
                                        })
                                        .join(', ');
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 8.0,
                                      ),
                                      child: Text(
                                        "Asignado a: $names",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    );
                                  },
                                  orElse: () =>
                                      const Text("Cargando Asignados..."),
                                );
                              },
                            ),
                          Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.group_add,
                                  color: AppColors.gsnBlue,
                                ),
                                tooltip: "Editar participantes",
                                onPressed: () => _showEditTaskAssigneesDialog(
                                  context,
                                  ref,
                                  iterationId,
                                  task,
                                ),
                              ),
                              if (task.evidenceUrl != null) ...[
                                IconButton(
                                  icon: const Icon(
                                    Icons.image,
                                    color: AppColors.gsnBlue,
                                  ),
                                  tooltip: "Ver evidencia",
                                  onPressed: () async {
                                    final uri = Uri.parse(task.evidenceUrl!);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  tooltip: "Eliminar evidencia",
                                  onPressed: () {
                                    ref
                                        .read(tasksControllerProvider)
                                        .deleteTaskEvidence(
                                          iterationId,
                                          task.id,
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Evidencia eliminada'),
                                      ),
                                    );
                                  },
                                ),
                              ],
                              IconButton(
                                icon: const Icon(Icons.upload_file),
                                onPressed: () async {
                                  final result = await FilePicker.platform
                                      .pickFiles(
                                        type: FileType.any,
                                        withData: true,
                                      );
                                  if (result != null &&
                                      result.files.isNotEmpty) {
                                    final file = result.files.first;
                                    if (file.bytes != null) {
                                      ref
                                          .read(tasksControllerProvider)
                                          .uploadEvidence(
                                            iterationId,
                                            task.id,
                                            file.bytes!,
                                            file.name,
                                          );
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Evidencia subida"),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _InventoryTab extends ConsumerWidget {
  final String projectId;
  const _InventoryTab({required this.projectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectInventoryAsync = ref.watch(
      projectInventoryProvider(projectId),
    );
    final allProductsAsync = ref.watch(inventoryProvider);
    final categoriesAsync = ref.watch(productCategoriesProvider);

    return projectInventoryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) =>
          Center(child: Text('Error al cargar inventario: $err')),
      data: (projectInventory) {
        if (projectInventory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text("No hay inventario asignado a este proyecto."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _showAssignProductDialog(
                      context,
                      ref,
                      projectId,
                      allProductsAsync.value ?? [],
                      categoriesAsync.value ?? [],
                    );
                  },
                  child: const Text("Asignar Productos"),
                ),
              ],
            ),
          );
        }

        return allProductsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              const SizedBox(), // Don't break if catalog fails
          data: (allProducts) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0).copyWith(bottom: 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showAssignProductDialog(
                          context,
                          ref,
                          projectId,
                          allProducts,
                          categoriesAsync.value ?? [],
                        ),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text("Asignar Insumos"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gsnBlue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: projectInventory.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = projectInventory[index];
                      final product = allProducts.firstWhere(
                        (p) => p.id == item.productId,
                        orElse: () => const Product(
                          id: '?',
                          name: 'Unknown',
                          sku: '?',
                          category: '?',
                          defaultPrice: 0,
                          stockCount: 0,
                        ),
                      );

                      return ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.devices, color: Colors.grey),
                        ),
                        title: Text(
                          product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "SKU: ${product.sku} • Asignado: ${item.createdAt != null ? DateFormat('dd/MM/yyyy').format(item.createdAt!) : 'N/A'}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Chip(
                              label: Text("Cant: ${item.quantity}"),
                              backgroundColor: AppColors.gsnBlue.withValues(
                                alpha: 0.1,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.gsnBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 18),
                                      SizedBox(width: 8),
                                      Text("Editar Cantidad"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'return',
                                  child: Row(
                                    children: [
                                      Icon(Icons.assignment_return, size: 18),
                                      SizedBox(width: 8),
                                      Text("Devolver"),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'report',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.report_problem,
                                        size: 18,
                                        color: AppColors.error,
                                      ),
                                      SizedBox(width: 8),
                                      Text("Reportar Daño"),
                                    ],
                                  ),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditQuantityDialog(
                                    context,
                                    ref,
                                    projectId,
                                    item,
                                    product,
                                  );
                                } else if (value == 'return') {
                                  ref
                                      .read(projectInventoryControllerProvider)
                                      .returnProduct(
                                        projectId,
                                        item.id,
                                        item.quantity,
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Producto devuelto a bodega central",
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

void _showAssignProductDialog(
  BuildContext context,
  WidgetRef ref,
  String projectId,
  List<Product> allProducts,
  List<ProductCategory> allCategories,
) {
  ProductCategory? selectedCategory;
  Product? selectedProduct;
  final quantityCtrl = TextEditingController(text: '1');

  // Lista de items a asignar en esta tanda. (Producto, Cantidad)
  List<Map<String, dynamic>> pendingAssignments = [];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        final availableProducts = selectedCategory == null
            ? allProducts
            : allProducts
                  .where((p) => p.categoryId == selectedCategory!.id)
                  .toList();

        return AlertDialog(
          title: const Text(
            "Asignar Productos al Proyecto",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: 600,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Formularios de Selección
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<ProductCategory>(
                            width: constraints.maxWidth,
                            label: const Text("Buscar Categoría"),
                            enableFilter: true,
                            enableSearch: true,
                            dropdownMenuEntries: allCategories
                                .map(
                                  (c) => DropdownMenuEntry(
                                    value: c,
                                    label: c.name,
                                  ),
                                )
                                .toList(),
                            onSelected: (cat) {
                              setState(() {
                                selectedCategory = cat;
                                selectedProduct = null;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return DropdownMenu<Product>(
                            width: constraints.maxWidth,
                            label: const Text("Buscar Producto"),
                            enableFilter: true,
                            enableSearch: true,
                            dropdownMenuEntries: availableProducts
                                .map(
                                  (p) => DropdownMenuEntry(
                                    value: p,
                                    label: "${p.name} (Stock: ${p.stockCount})",
                                  ),
                                )
                                .toList(),
                            onSelected: (prod) {
                              setState(() {
                                selectedProduct = prod;
                              });
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: quantityCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: "Cantidad",
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              if (selectedProduct == null) return;
                              final qty = int.tryParse(quantityCtrl.text) ?? 1;

                              if (qty <= 0) return;
                              if (qty > selectedProduct!.stockCount) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Stock insuficiente de ${selectedProduct!.name}. Disponible: ${selectedProduct!.stockCount}",
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                pendingAssignments.add({
                                  'product': selectedProduct,
                                  'quantity': qty,
                                });
                                // Reset fields for next
                                selectedProduct = null;
                                quantityCtrl.text = '1';
                              });
                            },
                            icon: const Icon(Icons.add_shopping_cart, size: 18),
                            label: const Text("Añadir a la lista"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gsnBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 18,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Lista de Productos a Asignar",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Divider(),
                // Lista de Pendientes
                pendingAssignments.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: Text(
                            "No has añadido productos aún.",
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: pendingAssignments.length,
                          itemBuilder: (context, index) {
                            final item = pendingAssignments[index];
                            final Product prod = item['product'];
                            final int qty = item['quantity'];

                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.gsnBlue.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.inventory_2,
                                  color: AppColors.gsnBlue,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                prod.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Cantidad a asignar: $qty"),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: AppColors.error,
                                ),
                                onPressed: () {
                                  setState(() {
                                    pendingAssignments.removeAt(index);
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: pendingAssignments.isEmpty
                  ? null
                  : () async {
                      final service = ref.read(
                        projectInventoryControllerProvider,
                      );
                      for (final item in pendingAssignments) {
                        final Product prod = item['product'];
                        final int qty = item['quantity'];

                        await service.assignProduct(projectId, {
                          'project_id': projectId,
                          'product_id': prod.id,
                          'quantity': qty,
                          'status': 'assigned',
                        });
                      }

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Productos asignados exitosamente."),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Asignar Todo el Lote",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    ),
  );
}

void _showEditQuantityDialog(
  BuildContext context,
  WidgetRef ref,
  String projectId,
  ProjectInventory item,
  Product product,
) {
  final quantityCtrl = TextEditingController(text: item.quantity.toString());

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Editar Cantidad Asignada"),
      content: TextField(
        controller: quantityCtrl,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: "Nueva Cantidad",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        ElevatedButton(
          onPressed: () {
            final qty = int.tryParse(quantityCtrl.text) ?? item.quantity;
            if (qty > product.stockCount) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Stock insuficiente. Disponible en inventario global: ${product.stockCount}",
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
              return;
            }
            ref
                .read(projectInventoryControllerProvider)
                .updateQuantity(projectId, item.id, qty);
            Navigator.pop(context);
          },
          child: const Text("Guardar"),
        ),
      ],
    ),
  );
}

void _showCreateIterationDialog(
  BuildContext context,
  WidgetRef ref,
  String projectId,
) {
  final nameCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Nueva Fase / Sprint",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nombre (Ej: Fase 1, Sprint 2)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Descripción de la Fase",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    title: Text(
                      startDate == null
                          ? "Fecha Inicio"
                          : DateFormat('dd/MM/yyyy').format(startDate!),
                      style: TextStyle(
                        color: startDate == null
                            ? Colors.grey[700]
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.gsnBlue,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.gsnBlue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    title: Text(
                      endDate == null
                          ? "Fecha Fin"
                          : DateFormat('dd/MM/yyyy').format(endDate!),
                      style: TextStyle(
                        color: endDate == null
                            ? Colors.grey[700]
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.gsnBlue,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.gsnBlue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                ),
              ],
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
                  ref
                      .read(iterationsControllerProvider)
                      .createIterationForProject(projectId, {
                        'project_id': projectId,
                        'name': nameCtrl.text,
                        'description': descCtrl.text,
                        'start_date': startDate?.toIso8601String(),
                        'end_date': endDate?.toIso8601String(),
                        'client_approval_status': 'pending',
                      });
                  Navigator.pop(context);
                },
                child: const Text(
                  "Crear Fase",
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

void _showEditIterationDialog(
  BuildContext context,
  WidgetRef ref,
  String projectId,
  Iteration iteration,
) {
  final nameCtrl = TextEditingController(text: iteration.name);
  final descCtrl = TextEditingController(text: iteration.description ?? '');
  DateTime? startDate = iteration.startDate;
  DateTime? endDate = iteration.endDate;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Editar Fase / Sprint",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: "Nombre (Ej: Fase 1, Sprint 2)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Descripción de la Fase",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    title: Text(
                      startDate == null
                          ? "Fecha Inicio"
                          : DateFormat('dd/MM/yyyy').format(startDate!),
                      style: TextStyle(
                        color: startDate == null
                            ? Colors.grey[700]
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.gsnBlue,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.gsnBlue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => startDate = picked);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!),
                    color: Colors.grey[50],
                  ),
                  child: ListTile(
                    title: Text(
                      endDate == null
                          ? "Fecha Fin"
                          : DateFormat('dd/MM/yyyy').format(endDate!),
                      style: TextStyle(
                        color: endDate == null
                            ? Colors.grey[700]
                            : AppColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.calendar_today,
                      color: AppColors.gsnBlue,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate ?? startDate ?? DateTime.now(),
                        firstDate: startDate ?? DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.gsnBlue,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => endDate = picked);
                    },
                  ),
                ),
              ],
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
                  ref
                      .read(iterationsControllerProvider)
                      .updateIterationDetails(projectId, iteration.id, {
                        'name': nameCtrl.text,
                        'description': descCtrl.text,
                        'start_date': startDate?.toIso8601String(),
                        'end_date': endDate?.toIso8601String(),
                      });
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

void _showEditTaskAssigneesDialog(
  BuildContext context,
  WidgetRef ref,
  String iterationId,
  Task task,
) {
  List<String> selectedAssignees = List.from(task.assignedTo);

  showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final profilesAsync = ref.watch(profilesProvider);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Editar Participantes",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "Selecciona a los asignados:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    profilesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Text("Error al cargar usuarios: $err"),
                      data: (profiles) {
                        final staffUsers = profiles
                            .where(
                              (p) => p.role == 'admin' || p.role == 'staff',
                            )
                            .toList();

                        if (staffUsers.isEmpty) {
                          return const Text(
                            "No hay usuarios staff/admin disponibles.",
                          );
                        }

                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: staffUsers.map((user) {
                            final isSelected = selectedAssignees.contains(
                              user.id,
                            );
                            return FilterChip(
                              label: Text(
                                user.fullName ?? user.email ?? 'Sin Nombre',
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedAssignees.add(user.id);
                                  } else {
                                    selectedAssignees.remove(user.id);
                                  }
                                });
                              },
                              selectedColor: AppColors.gsnBlue.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppColors.gsnBlue,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
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
                      ref
                          .read(tasksControllerProvider)
                          .updateTaskAssignees(
                            iterationId,
                            task.id,
                            selectedAssignees,
                          );
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
        );
      },
    ),
  );
}

void _showCreateTaskDialog(
  BuildContext context,
  WidgetRef ref,
  String iterationId,
) {
  final titleCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  List<String> selectedAssignees = [];

  showDialog(
    context: context,
    builder: (context) => Consumer(
      builder: (context, ref, _) {
        final profilesAsync = ref.watch(profilesProvider);

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Nueva Tarea",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: "Título de la Tarea",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descCtrl,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Descripción (Opcional)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Asignar a (Opcional):",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    profilesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Text("Error al cargar usuarios: $err"),
                      data: (profiles) {
                        final staffUsers = profiles
                            .where(
                              (p) => p.role == 'admin' || p.role == 'staff',
                            )
                            .toList();

                        if (staffUsers.isEmpty) {
                          return const Text(
                            "No hay usuarios staff/admin disponibles.",
                          );
                        }

                        return Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: staffUsers.map((user) {
                            final isSelected = selectedAssignees.contains(
                              user.id,
                            );
                            return FilterChip(
                              label: Text(
                                user.fullName ?? user.email ?? 'Sin Nombre',
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    selectedAssignees.add(user.id);
                                  } else {
                                    selectedAssignees.remove(user.id);
                                  }
                                });
                              },
                              selectedColor: AppColors.gsnBlue.withValues(
                                alpha: 0.2,
                              ),
                              checkmarkColor: AppColors.gsnBlue,
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
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
                      if (titleCtrl.text.isEmpty) return;

                      ref
                          .read(tasksControllerProvider)
                          .createTask(iterationId, {
                            'iteration_id': iterationId,
                            'title': titleCtrl.text,
                            'description': descCtrl.text,
                            'status': TaskStatus.todo.name,
                            'assigned_to': selectedAssignees,
                          });
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Crear Tarea",
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

class _DocumentsTab extends ConsumerWidget {
  final Project project;
  const _DocumentsTab({required this.project});

  void _showLinkDriveDialog(BuildContext context, WidgetRef ref) {
    final urlCtrl = TextEditingController(text: project.driveFolderUrl ?? '');
    String selectedType = 'project'; // 'project' or 'reports'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Vincular Carpeta de Google Drive"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: "Tipo de Carpeta",
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'project',
                      child: Text("Archivos del Proyecto"),
                    ),
                    DropdownMenuItem(
                      value: 'reports',
                      child: Text("Informes de Avance"),
                    ),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        selectedType = val;
                        // Pre-fill corresponding existing URL if it exists
                        if (selectedType == 'project') {
                          urlCtrl.text = project.driveFolderUrl ?? '';
                        } else {
                          urlCtrl.text = project.reportsDriveUrl ?? '';
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: urlCtrl,
                  decoration: const InputDecoration(
                    labelText: "URL de la carpeta",
                    border: OutlineInputBorder(),
                    hintText: "https://drive.google.com/drive/folders/...",
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final url = urlCtrl.text.trim();
                  if (url.isNotEmpty) {
                    // Decide which field to update
                    final field = selectedType == 'project'
                        ? 'drive_folder_url'
                        : 'reports_drive_url';

                    ref.read(projectsControllerProvider).updateProject(
                      project.id,
                      {field: url},
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedType == 'project'
                              ? 'Carpeta del proyecto vinculada correctamente.'
                              : 'Carpeta de informes vinculada correctamente.',
                        ),
                      ),
                    );
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasDriveLink =
        project.driveFolderUrl != null && project.driveFolderUrl!.isNotEmpty;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.add_to_drive,
              size: 80,
              color: hasDriveLink ? AppColors.gsnBlue : AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              hasDriveLink
                  ? "Carpeta de Proyecto Vinculada"
                  : "Gestión de Documentos",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              hasDriveLink
                  ? "Los documentos de este proyecto están almacenados y gestionados desde Google Drive."
                  : "Por favor vincula una carpeta de Google Drive donde se almacenarán los documentos del proyecto.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            if (hasDriveLink) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final urlStr = project.driveFolderUrl!.trim();
                    final uri = Uri.parse(
                      urlStr.startsWith('http') ? urlStr : 'https://$urlStr',
                    );
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al abrir URL: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_browser, size: 24),
                label: const Text(
                  "Abrir Carpeta en Google Drive",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => _showLinkDriveDialog(context, ref),
                icon: const Icon(Icons.edit),
                label: const Text("Editar URL de Carpeta"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: () => _showLinkDriveDialog(context, ref),
                icon: const Icon(Icons.link, size: 24),
                label: const Text(
                  "Vincular Carpeta de Drive",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gsnBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportsTab extends ConsumerWidget {
  final Project project;
  final bool isClient;
  const _ReportsTab({required this.project, this.isClient = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasReportsLink =
        project.reportsDriveUrl != null && project.reportsDriveUrl!.isNotEmpty;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: hasReportsLink
                  ? AppColors.gsnBlue
                  : AppColors.textSecondary,
            ),
            const SizedBox(height: 24),
            Text(
              hasReportsLink
                  ? "Informes de Avance"
                  : (isClient
                        ? "Aún no hay informes disponibles"
                        : "Gestión de Informes"),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              hasReportsLink
                  ? "Revisa los informes de avance de este proyecto almacenados en Google Drive."
                  : (isClient
                        ? "Tu ejecutivo subirá los informes de avance aquí pronto."
                        : "Debes vincular la carpeta correspondiente de Informes desde la pestaña de Archivos para que el cliente pueda verlos."),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            if (hasReportsLink) ...[
              ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final urlStr = project.reportsDriveUrl!.trim();
                    final uri = Uri.parse(
                      urlStr.startsWith('http') ? urlStr : 'https://$urlStr',
                    );
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al abrir URL: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.open_in_browser, size: 24),
                label: const Text(
                  "Visualizar Informes (Drive)",
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BillingTab extends ConsumerStatefulWidget {
  final Project project;
  const _BillingTab({required this.project});

  @override
  ConsumerState<_BillingTab> createState() => _BillingTabState();
}

class _BillingTabState extends ConsumerState<_BillingTab> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'es_CL',
    symbol: '\$',
    decimalDigits: 0,
  );

  void _showAddPaymentDialog(BuildContext context, WidgetRef ref) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'unico'; // 'unico', 'suscripcion', 'adicional'

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Registrar Nuevo Cobro"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Monto",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Tipo de Cobro",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'unico',
                        child: Text("Pago Único"),
                      ),
                      DropdownMenuItem(
                        value: 'suscripcion',
                        child: Text("Suscripción (Mensualidad)"),
                      ),
                      DropdownMenuItem(
                        value: 'adicional',
                        child: Text("Cobro por Cambio Adicional"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Descripción o Mes Pagado",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;

                  ref
                      .read(projectPaymentsControllerProvider)
                      .addPayment(widget.project.id, {
                        'project_id': widget.project.id,
                        'amount': amount,
                        'payment_type': selectedType,
                        'description': descCtrl.text,
                      });

                  // Update global billed state in project
                  final newBilled = widget.project.billedAmount + amount;
                  final newPending = widget.project.budgetTotal - newBilled;
                  ref
                      .read(projectsControllerProvider)
                      .updateProject(widget.project.id, {
                        'billed_amount': newBilled,
                        'pending_amount': newPending < 0 ? 0 : newPending,
                      });

                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    ProjectPayment payment,
  ) {
    final amountCtrl = TextEditingController(
      text: payment.amount.toInt().toString(),
    );
    final descCtrl = TextEditingController(text: payment.description ?? "");
    String selectedType = payment.paymentType;
    final oldAmount = payment.amount;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Editar Cobro"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Monto",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.monetization_on),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(
                      labelText: "Tipo de Cobro",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'unico',
                        child: Text("Pago Único"),
                      ),
                      DropdownMenuItem(
                        value: 'suscripcion',
                        child: Text("Suscripción (Mensualidad)"),
                      ),
                      DropdownMenuItem(
                        value: 'adicional',
                        child: Text("Cobro por Cambio Adicional"),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedType = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Descripción",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;

                  ref
                      .read(projectPaymentsControllerProvider)
                      .updatePayment(widget.project.id, payment.id, {
                        'amount': amount,
                        'payment_type': selectedType,
                        'description': descCtrl.text,
                      });

                  final amountDiff = amount - oldAmount;
                  final newBilled = widget.project.billedAmount + amountDiff;
                  final newPending = widget.project.budgetTotal - newBilled;

                  ref
                      .read(projectsControllerProvider)
                      .updateProject(widget.project.id, {
                        'billed_amount': newBilled,
                        'pending_amount': newPending < 0 ? 0 : newPending,
                      });

                  Navigator.pop(context);
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(projectPaymentsProvider(widget.project.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 800;

          final resumenWidget = Container(
            padding: const EdgeInsets.all(32),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Resumen de Pagos",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Presupuesto Total:",
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      _currencyFormat.format(widget.project.budgetTotal),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Cobrado:",
                      style: TextStyle(fontSize: 16, color: AppColors.success),
                    ),
                    Text(
                      _currencyFormat.format(widget.project.billedAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Saldo Pendiente:",
                      style: TextStyle(fontSize: 16, color: AppColors.warning),
                    ),
                    Text(
                      _currencyFormat.format(widget.project.pendingAmount),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gsnBlue,
                    padding: const EdgeInsets.all(16),
                  ),
                  onPressed: () => _showAddPaymentDialog(context, ref),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    "Registrar Nuevo Cobro",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );

          // Right: Historial de Pagos
          final historialWidget = Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Historial de Movimientos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: paymentsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, s) => Center(child: Text("Error: $err")),
                    data: (payments) {
                      if (payments.isEmpty) {
                        return const Center(
                          child: Text(
                            "No hay cobros registrados.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: payments.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, i) {
                          final p = payments[i];
                          IconData tIcon;
                          switch (p.paymentType) {
                            case 'suscripcion':
                              tIcon = Icons.autorenew;
                              break;
                            case 'adicional':
                              tIcon = Icons.add_circle_outline;
                              break;
                            default:
                              tIcon = Icons.monetization_on;
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.gsnBlue.withValues(
                                alpha: 0.1,
                              ),
                              child: Icon(tIcon, color: AppColors.gsnBlue),
                            ),
                            title: Text(
                              _currencyFormat.format(p.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tipo: ${p.paymentType.toUpperCase()}"),
                                if (p.description != null &&
                                    p.description!.isNotEmpty)
                                  Text("Detalle: ${p.description}"),
                                Text(
                                  "Fecha: ${DateFormat('dd/MM/yyyy HH:mm').format(p.paymentDate)}",
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () =>
                                      _showEditPaymentDialog(context, ref, p),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.error,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text("¿Eliminar Cobro?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, false),
                                            child: const Text("Cancelar"),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(c, true),
                                            child: const Text(
                                              "Eliminar",
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      ref
                                          .read(
                                            projectPaymentsControllerProvider,
                                          )
                                          .deletePayment(
                                            widget.project.id,
                                            p.id,
                                          );
                                      // Update project amounts
                                      final newBilled =
                                          widget.project.billedAmount -
                                          p.amount;
                                      final newPending =
                                          widget.project.budgetTotal -
                                          newBilled;
                                      ref
                                          .read(projectsControllerProvider)
                                          .updateProject(widget.project.id, {
                                            'billed_amount': newBilled < 0
                                                ? 0
                                                : newBilled,
                                            'pending_amount': newPending,
                                          });
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );

          if (isMobile) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  resumenWidget,
                  const SizedBox(height: 24),
                  SizedBox(height: 500, child: historialWidget),
                ],
              ),
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 1, child: resumenWidget),
              Expanded(flex: 2, child: historialWidget),
            ],
          );
        },
      ),
    );
  }
}

void _showEditTaskDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
  String iterationId,
) {
  final titleCtrl = TextEditingController(text: task.title);
  final descCtrl = TextEditingController(text: task.description ?? '');

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Editar Tarea",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleCtrl,
                  decoration: InputDecoration(
                    labelText: "Título de la Tarea",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Descripción (Opcional)",
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
                  if (titleCtrl.text.isEmpty) return;

                  ref.read(tasksControllerProvider).updateTaskDetails(
                    iterationId,
                    task.id,
                    {'title': titleCtrl.text, 'description': descCtrl.text},
                  );
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

void _showTaskDetailDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
  String iterationId,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  Navigator.pop(context);
                  _showEditTaskDialog(context, ref, task, iterationId);
                },
                tooltip: "Editar Tarea",
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Eliminar Tarea"),
                      content: const Text(
                        "¿Estás seguro de que deseas eliminar esta tarea?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text("Cancelar"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text(
                            "Eliminar",
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref
                        .read(tasksControllerProvider)
                        .deleteTask(iterationId, task.id);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                tooltip: "Eliminar Tarea",
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty) ...[
                const Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(task.description!),
                const SizedBox(height: 16),
              ],
              if (task.evidenceUrl != null) ...[
                const Text(
                  "Evidencia Principal:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(task.evidenceUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gsnBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gsnBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.image, color: AppColors.gsnBlue),
                        const SizedBox(width: 12),
                        const Text(
                          "Ver Evidencia",
                          style: TextStyle(
                            color: AppColors.gsnBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.open_in_new,
                          color: AppColors.gsnBlue,
                          size: 16,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.error,
                            size: 20,
                          ),
                          tooltip: "Eliminar evidencia",
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text("Eliminar Evidencia"),
                                content: const Text(
                                  "¿Deseas desenlazar esta evidencia de la tarea?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text("Cancelar"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text(
                                      "Eliminar",
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              ref
                                  .read(tasksControllerProvider)
                                  .deleteTaskEvidence(iterationId, task.id);
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Documentos de la Tarea:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gsnBlue,
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        withData: true,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        final file = result.files.first;
                        if (file.bytes != null) {
                          ref
                              .read(taskDocumentsControllerProvider)
                              .uploadDocument(task.id, file.bytes!, file.name);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Documento subido")),
                            );
                          }
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.upload_file,
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text(
                      "Subir",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: Consumer(
                  builder: (context, ref, _) {
                    final taskDocsAsync = ref.watch(
                      taskDocumentsProvider(task.id),
                    );
                    return taskDocsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text("Error: $e")),
                      data: (docs) {
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text("No hay documentos subidos."),
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            final crossAxisCount = isMobile ? 2 : 3;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: docs.length,
                              itemBuilder: (context, i) {
                                final doc = docs[i];
                                final ext = doc.fileName.toLowerCase();
                                final isImage =
                                    ext.endsWith('.jpg') ||
                                    ext.endsWith('.jpeg') ||
                                    ext.endsWith('.png') ||
                                    ext.endsWith('.gif') ||
                                    ext.endsWith('.webp');

                                return InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(doc.fileUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.gsnBlue.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (isImage)
                                          Image.network(
                                            doc.fileUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 32,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Error",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          )
                                        else
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.insert_drive_file,
                                                color: AppColors.gsnBlue,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                child: Text(
                                                  doc.fileName,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: InkWell(
                                            onTap: () {
                                              ref
                                                  .read(
                                                    taskDocumentsControllerProvider,
                                                  )
                                                  .deleteDocument(
                                                    task.id,
                                                    doc.id,
                                                    doc.fileUrl,
                                                  );
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(
                                                  alpha: 0.9,
                                                ),
                                                shape: BoxShape.circle,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black
                                                        .withValues(alpha: 0.1),
                                                    blurRadius: 4,
                                                  ),
                                                ],
                                              ),
                                              child: const Icon(
                                                Icons.delete,
                                                color: AppColors.error,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    ),
  );
}

class _ClientMilestonesTab extends ConsumerWidget {
  final Project project;
  const _ClientMilestonesTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String projectId = project.id;
    final iterationsAsync = ref.watch(iterationsProvider(projectId));

    return iterationsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
      data: (iterations) {
        if (iterations.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timeline, size: 48, color: AppColors.textSecondary),
                SizedBox(height: 16),
                Text("No hay fases/sprints definidos."),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: iterations.length,
            itemBuilder: (context, index) {
              final iteration = iterations[index];
              final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.gsnBlue.withOpacity(0.05),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        border: Border(
                          bottom: BorderSide(color: AppColors.divider),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.flag_outlined,
                            color: AppColors.gsnBlue,
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  iteration.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "${iteration.startDate != null ? dateFormat.format(iteration.startDate!) : 'N/A'} - ${iteration.endDate != null ? dateFormat.format(iteration.endDate!) : 'N/A'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.approved)
                            const Chip(
                              label: Text("Aprobado"),
                              backgroundColor: Color(0xFFD1FAE5),
                              labelStyle: TextStyle(
                                color: Color(0xFF047857),
                                fontSize: 12,
                              ),
                            )
                          else if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.rejected)
                            const Chip(
                              label: Text("Rechazado"),
                              backgroundColor: Color(0xFFFEE2E2),
                              labelStyle: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 12,
                              ),
                            )
                          else if (iteration.clientApprovalStatus ==
                              IterationApprovalStatus.pending)
                            const Chip(
                              label: Text("Pendiente de Aprobación"),
                              backgroundColor: Color(0xFFFEF3C7),
                              labelStyle: TextStyle(
                                color: Color(0xFFD97706),
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ),
                    _ClientTasksList(iterationId: iteration.id),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ClientTasksList extends ConsumerWidget {
  final String iterationId;
  const _ClientTasksList({required this.iterationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider(iterationId));

    return tasksAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text('Error al cargar tareas: $err'),
      ),
      data: (tasks) {
        if (tasks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("No hay tareas en esta fase."),
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, i) {
            final task = tasks[i];
            return InkWell(
              onTap: () => _showClientTaskDetailDialog(context, ref, task),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      task.status == TaskStatus.done
                          ? Icons.check_circle
                          : task.status == TaskStatus.doing
                          ? Icons.timelapse
                          : Icons.radio_button_unchecked,
                      color: task.status == TaskStatus.done
                          ? AppColors.success
                          : task.status == TaskStatus.doing
                          ? AppColors.warning
                          : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              decoration: task.status == TaskStatus.done
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task.status == TaskStatus.done
                                  ? AppColors.textSecondary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          if (task.description != null &&
                              task.description!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                task.description!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (task.evidenceUrl != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gsnBlue.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.photo_camera,
                                        color: AppColors.gsnBlue,
                                        size: 14,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        "Fotografía adjunta",
                                        style: TextStyle(
                                          color: AppColors.gsnBlue,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.open_in_new,
                                    color: AppColors.textSecondary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "Toca para detalles",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ClientNotificationsTab extends ConsumerWidget {
  final Project project;
  const _ClientNotificationsTab({required this.project});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iterationsAsync = ref.watch(iterationsProvider(project.id));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: iterationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (iterations) {
          final pendingApprovals = iterations
              .where(
                (i) =>
                    i.clientApprovalStatus == IterationApprovalStatus.pending,
              )
              .toList();

          if (pendingApprovals.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(height: 16),
                  Text("No tienes notificaciones o solicitudes pendientes."),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: pendingApprovals.length,
            itemBuilder: (context, index) {
              final iteration = pendingApprovals[index];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFFFEF3C7),
                            child: Icon(
                              Icons.assignment,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Solicitud de Aprobación: ${iteration.name}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "Se requiere aprobación para esta fase.",
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(iterationsControllerProvider)
                                    .respondClientApproval(
                                      project.id,
                                      iteration.id,
                                      iteration.name,
                                      '',
                                      false,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fase rechazada'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text("Rechazar"),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await ref
                                    .read(iterationsControllerProvider)
                                    .respondClientApproval(
                                      project.id,
                                      iteration.id,
                                      iteration.name,
                                      '',
                                      true,
                                    );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Fase aprobada'),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text("Aprobar"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void _showClientTaskDetailDialog(
  BuildContext context,
  WidgetRef ref,
  Task task,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        task.title,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null && task.description!.isNotEmpty) ...[
                const Text(
                  "Descripción:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(task.description!),
                const SizedBox(height: 16),
              ],
              if (task.evidenceUrl != null) ...[
                const Text(
                  "Evidencia Principal:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final uri = Uri.parse(task.evidenceUrl!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(
                        uri,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gsnBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gsnBlue.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.image, color: AppColors.gsnBlue),
                        SizedBox(width: 12),
                        Text(
                          "Ver Evidencia Adjunta",
                          style: TextStyle(
                            color: AppColors.gsnBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.open_in_new,
                          color: AppColors.gsnBlue,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Divider(),
              const Text(
                "Documentos de la Tarea:",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: Consumer(
                  builder: (context, ref, _) {
                    final taskDocsAsync = ref.watch(
                      taskDocumentsProvider(task.id),
                    );
                    return taskDocsAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Center(child: Text("Error: $e")),
                      data: (docs) {
                        if (docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No hay documentos adicionales.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final isMobile = constraints.maxWidth < 600;
                            final crossAxisCount = isMobile ? 2 : 3;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: docs.length,
                              itemBuilder: (context, i) {
                                final doc = docs[i];
                                final ext = doc.fileName.toLowerCase();
                                final isImage =
                                    ext.endsWith('.jpg') ||
                                    ext.endsWith('.jpeg') ||
                                    ext.endsWith('.png') ||
                                    ext.endsWith('.gif') ||
                                    ext.endsWith('.webp');

                                return InkWell(
                                  onTap: () async {
                                    final uri = Uri.parse(doc.fileUrl);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(
                                        uri,
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppColors.gsnBlue.withValues(
                                          alpha: 0.2,
                                        ),
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        if (isImage)
                                          Image.network(
                                            doc.fileUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.broken_image,
                                                      color: Colors.grey,
                                                      size: 32,
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      "Error",
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          )
                                        else
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.insert_drive_file,
                                                color: AppColors.gsnBlue,
                                                size: 32,
                                              ),
                                              const SizedBox(height: 8),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                    ),
                                                child: Text(
                                                  doc.fileName,
                                                  textAlign: TextAlign.center,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        Positioned(
                                          top: 4,
                                          right: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(
                                                alpha: 0.9,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.download,
                                              color: AppColors.gsnBlue,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cerrar"),
        ),
      ],
    ),
  );
}
