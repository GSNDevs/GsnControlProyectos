import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';

class ClientsScreen extends ConsumerWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 900;
          return Padding(
            padding: EdgeInsets.all(isMobile ? 16.0 : 32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Gestión de Clientes (Empresas)",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Administra las empresas mandantes y sus usuarios asociados",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isMobile) const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppColors.softShadow,
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => _showClientFormDialog(context, ref),
                        icon: const Icon(
                          Icons.domain_add_rounded,
                          color: Colors.white,
                        ),
                        label: isMobile
                            ? const SizedBox.shrink()
                            : const Text(
                                "Nueva Empresa",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
                const SizedBox(height: 24),
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final clientsAsync = ref.watch(clientCompaniesProvider);
                      final usersAsync = ref.watch(profilesProvider);

                      return clientsAsync.when(
                        data: (clients) {
                          if (clients.isEmpty) {
                            return const Center(
                              child: Text(
                                "No hay empresas registradas",
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            );
                          }

                          return GridView.builder(
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 1 : 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: isMobile ? 2.5 : 2.0,
                            ),
                            itemCount: clients.length,
                            itemBuilder: (context, index) {
                              final client = clients[index];
                              
                              // Encuentra usuarios asociados a la empresa
                              int usersCount = 0;
                              usersAsync.whenData((profiles) {
                                usersCount = profiles.where((p) => p.clientId == client.id && p.enabled).length;
                              });

                              return _buildClientCard(context, ref, client, usersCount);
                            },
                          );
                        },
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (err, stack) => Center(child: Text('Error: $err')),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, WidgetRef ref, ClientCompany client, int usersCount) {
    return InkWell(
      onTap: () => _showClientDetailsDialog(context, ref, client),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.softShadow,
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gsnBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: AppColors.gsnBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        client.rut ?? "Sin RUT",
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.people_alt_rounded,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      "$usersCount usuarios",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.gsnBlue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showClientFormDialog(BuildContext context, WidgetRef ref, {ClientCompany? client}) {
    final isEditing = client != null;
    final nameCtrl = TextEditingController(text: client?.name ?? '');
    final fantasyCtrl = TextEditingController(text: client?.fantasyName ?? '');
    final rutCtrl = TextEditingController(text: client?.rut ?? '');
    final addressCtrl = TextEditingController(text: client?.address ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? "Editar Empresa Cliente" : "Nueva Empresa Cliente"),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Razón Social *",
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rutCtrl,
                    decoration: const InputDecoration(
                      labelText: "RUT",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fantasyCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre Fantasía (Opcional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: addressCtrl,
                    decoration: const InputDecoration(
                      labelText: "Dirección",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final controller = ref.read(clientCompaniesControllerProvider);
                  final data = {
                    'name': nameCtrl.text,
                    'fantasy_name': fantasyCtrl.text.isEmpty ? null : fantasyCtrl.text,
                    'rut': rutCtrl.text.isEmpty ? null : rutCtrl.text,
                    'address': addressCtrl.text.isEmpty ? null : addressCtrl.text,
                  };
                  
                  if (isEditing) {
                    await controller.updateClient(client.id, data);
                  } else {
                    await controller.createClient(data);
                  }
                  
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isEditing ? "Empresa actualizada exitosamente" : "Empresa creada exitosamente")),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                }
              }
            },
            child: Text(isEditing ? "Guardar Cambios" : "Crear"),
          ),
        ],
      ),
    );
  }

  void _showClientDetailsDialog(BuildContext context, WidgetRef ref, ClientCompany client) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "RUT: ${client.rut ?? 'N/A'}",
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_rounded, color: AppColors.gsnBlue),
                        tooltip: "Editar Empresa",
                        onPressed: () {
                          Navigator.pop(context);
                          _showClientFormDialog(context, ref, client: client);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                        tooltip: "Eliminar Empresa",
                        onPressed: () => _confirmDeleteClient(context, ref, client),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Usuarios Asociados",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      _showAddClientUserDialog(context, ref, client);
                    },
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                    label: const Text("Añadir Usuario"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
              const Divider(height: 32),
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final usersAsync = ref.watch(profilesProvider);
                    return usersAsync.when(
                      data: (profiles) {
                        final clientUsers = profiles.where((p) => p.clientId == client.id && p.enabled).toList();
                        
                        if (clientUsers.isEmpty) {
                          return const Center(
                            child: Text(
                              "Esta empresa no tiene usuarios asociados.",
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          );
                        }
                        
                        return ListView.separated(
                          itemCount: clientUsers.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final u = clientUsers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.gsnBlue.withValues(alpha: 0.1),
                                child: Text(
                                  (u.fullName ?? u.email ?? '?')[0].toUpperCase(),
                                  style: const TextStyle(color: AppColors.gsnBlue, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(u.fullName ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(u.email ?? ''),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.textSecondary),
                                onPressed: () {
                                  // Can show the existing Edit user dialog or a sub-dialog
                                },
                              ),
                            );
                          },
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (err, _) => Center(child: Text("Error: $err")),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddClientUserDialog(BuildContext context, WidgetRef ref, ClientCompany client) {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Asignar Usuario a ${client.name}"),
        content: SizedBox(
          width: 500,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Consumer(
                builder: (context, ref, child) {
                  final usersAsync = ref.watch(profilesProvider);
                  return usersAsync.when(
                    data: (profiles) {
                      // Filtrar usuarios que tienen rol client y que no están ya asignados a esta empresa
                      var availableUsers = profiles.where((p) => p.role == 'client' && p.clientId != client.id).toList();
                      
                      if (searchQuery.isNotEmpty) {
                        final q = searchQuery.toLowerCase();
                        availableUsers = availableUsers.where((p) => 
                          (p.fullName?.toLowerCase().contains(q) ?? false) || 
                          (p.email?.toLowerCase().contains(q) ?? false)
                        ).toList();
                      }
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Selecciona un usuario de la lista vinculada a este sistema con rol 'Cliente'. Si el usuario ya estaba en otra empresa, será transferido a esta.",
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            decoration: InputDecoration(
                              labelText: "Buscar por nombre o correo",
                              prefixIcon: const Icon(Icons.search_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          if (profiles.where((p) => p.role == 'client' && p.clientId != client.id).isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  const Text("No hay usuarios con rol 'client' disponibles en el sistema."),
                                  const SizedBox(height: 16),
                                  OutlinedButton.icon(
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _showCreateClientUserSubDialog(context, ref, client);
                                    },
                                    icon: const Icon(Icons.person_add_alt_1_rounded),
                                    label: const Text("Crear nuevo usuario"),
                                  ),
                                ],
                              ),
                            )
                          else if (availableUsers.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text("No se encontraron usuarios coincidentes."),
                            )
                          else
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: ListView.separated(
                                shrinkWrap: true,
                                itemCount: availableUsers.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, index) {
                                  final user = availableUsers[index];
                                  return ListTile(
                                    title: Text(user.fullName ?? 'Sin Nombre'),
                                    subtitle: Text(user.email ?? ''),
                                    trailing: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          final service = ref.read(profilesServiceProvider);
                                          await service.updateProfile(user.id, {'client_id': client.id});
                                          ref.invalidate(profilesProvider);
                                          if (ctx.mounted) {
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(ctx).showSnackBar(
                                              const SnackBar(content: Text("Usuario asignado exitosamente.")),
                                            );
                                          }
                                        } catch (e) {
                                          if (ctx.mounted) {
                                            ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Error: $e")));
                                          }
                                        }
                                      },
                                      child: const Text("Asignar"),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text("Error: $err")),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteClient(BuildContext context, WidgetRef ref, ClientCompany client) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmar Eliminación"),
        content: Text(
          "¿Estás seguro de eliminar la empresa '${client.name}'?\n\nLos usuarios y proyectos vinculados quedarán sin empresa asignada (en nulo)."
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              try {
                // Primero cerramos ambos dialogs
                Navigator.pop(ctx); 
                Navigator.pop(context); // Cierra el detalle también
                
                final controller = ref.read(clientCompaniesControllerProvider);
                await controller.deleteClient(client.id);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Empresa eliminada exitosamente.")),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateClientUserSubDialog(BuildContext context, WidgetRef ref, ClientCompany client) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final rutCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Nuevo Usuario para ${client.name}"),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.gsnBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Se creará un usuario con rol Cliente vinculado automáticamente a esta empresa.",
                      style: TextStyle(color: AppColors.gsnBlue, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailCtrl,
                    decoration: const InputDecoration(labelText: "Email (Login)", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty || !v.contains('@') ? 'Email inválido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passCtrl,
                    decoration: const InputDecoration(labelText: "Contraseña Temporal", border: OutlineInputBorder()),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: "Nombre Completo", border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: rutCtrl,
                    decoration: const InputDecoration(labelText: "RUT Personal", border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final service = ref.read(profilesServiceProvider);
                  // 1. Create auth user and profile
                  await service.createProfileWithAuth({
                    'email': emailCtrl.text,
                    'password': passCtrl.text,
                    'full_name': nameCtrl.text,
                    'rut': rutCtrl.text,
                  }, 'client');
                  
                  // Now how to link? We need the user's ID.
                  // Since we don't have the user ID back from RPC, we fetch the profile by email
                  final allProfiles = await service.getProfiles();
                  final newProfile = allProfiles.firstWhere((p) => p['email'] == emailCtrl.text);
                  
                  // Link it
                  await service.updateProfile(newProfile['id'], {
                    'client_id': client.id
                  });

                  ref.invalidate(profilesProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Usuario creado y vinculado.")));
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              }
            },
            child: const Text("Crear"),
          ),
        ],
      ),
    );
  }
}
