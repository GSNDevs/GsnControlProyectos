import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

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
                            "Gestión de Usuarios",
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Administra permisos y accesos diferenciados",
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
                        onPressed: () => _showAddUserDialog(context, ref),
                        icon: const Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                        ),
                        label: isMobile
                            ? const SizedBox.shrink()
                            : const Text(
                                "Nuevo Usuario",
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
                      final profilesAsync = ref.watch(profilesProvider);

                      return profilesAsync.when(
                        data: (profiles) {
                          final activeProfiles = profiles
                              .where((p) => p.enabled)
                              .toList();
                          final admins = activeProfiles
                              .where((p) => p.role == 'admin')
                              .toList();
                          final staff = activeProfiles
                              .where((p) => p.role == 'staff')
                              .toList();
                          final clients = activeProfiles
                              .where((p) => p.role == 'client')
                              .toList();

                          if (isMobile) {
                            return DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  const TabBar(
                                    labelColor: AppColors.gsnBlue,
                                    unselectedLabelColor:
                                        AppColors.textSecondary,
                                    indicatorColor: AppColors.gsnBlue,
                                    tabs: [
                                      Tab(text: "Admin"),
                                      Tab(text: "Staff"),
                                      Tab(text: "Clientes"),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        _buildRoleColumn(
                                          context,
                                          ref,
                                          "Administradores",
                                          admins,
                                          AppColors.gsnBlue,
                                        ),
                                        _buildRoleColumn(
                                          context,
                                          ref,
                                          "Staff / Equipo",
                                          staff,
                                          Colors.amber,
                                        ),
                                        _buildRoleColumn(
                                          context,
                                          ref,
                                          "Clientes",
                                          clients,
                                          AppColors.success,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildRoleColumn(
                                  context,
                                  ref,
                                  "Administradores",
                                  admins,
                                  AppColors.gsnBlue,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildRoleColumn(
                                  context,
                                  ref,
                                  "Staff / Equipo",
                                  staff,
                                  Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: _buildRoleColumn(
                                  context,
                                  ref,
                                  "Clientes",
                                  clients,
                                  AppColors.success,
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, stack) =>
                            Center(child: Text('Error: $err')),
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

  Widget _buildRoleColumn(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Profile> profiles,
    Color themeColor,
  ) {
    return Container(
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
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
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
                  "${profiles.length}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          Expanded(
            child: profiles.isEmpty
                ? const Center(
                    child: Text(
                      "Sin usuarios",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (context, index) {
                      final profile = profiles[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: themeColor.withValues(
                                alpha: 0.1,
                              ),
                              child: Text(
                                (profile.fullName ?? profile.email ?? '?')[0]
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: themeColor,
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
                                    profile.fullName ?? 'Sin Nombre',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (profile.companyName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.companyName!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      profile.email ?? '',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_rounded,
                                    size: 18,
                                  ),
                                  color: AppColors.textSecondary,
                                  onPressed: () => _showEditUserDialog(
                                    context,
                                    ref,
                                    profile,
                                  ),
                                  tooltip: "Editar",
                                  splashRadius: 20,
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 18,
                                  ),
                                  color: AppColors.error,
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text(
                                          "Deshabilitar Usuario",
                                        ),
                                        content: const Text(
                                          "¿Estás seguro de deshabilitar este usuario? Perderá acceso a la plataforma.",
                                        ),
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
                                              "Deshabilitar",
                                              style: TextStyle(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      try {
                                        final service = ref.read(
                                          profilesServiceProvider,
                                        );
                                        await service.updateProfile(
                                          profile.id,
                                          {'enabled': false},
                                        );
                                        ref.invalidate(profilesProvider);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Usuario deshabilitado.",
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text("Error: $e"),
                                            ),
                                          );
                                        }
                                      }
                                    }
                                  },
                                  tooltip: "Eliminar (Deshabilitar)",
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context, WidgetRef ref) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final nameCtrl = TextEditingController(); // Contact Name
    final rutCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final fantasyCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Default to client, but allow changing
    String selectedRole = 'client';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Nuevo Usuario"),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Rol",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'client',
                            child: Text("Cliente"),
                          ),
                          DropdownMenuItem(
                            value: 'staff',
                            child: Text("Staff / Equipo"),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text("Administrador"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: emailCtrl,
                        decoration: const InputDecoration(
                          labelText: "Email (Login)",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty || !v.contains('@')
                            ? 'Email inválido'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: passCtrl,
                        decoration: const InputDecoration(
                          labelText: "Contraseña Temporal",
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) =>
                            v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Datos ${selectedRole == 'client' ? 'de la Empresa / Cliente' : 'Personales'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre Completo",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: rutCtrl,
                        decoration: const InputDecoration(
                          labelText: "RUT",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (selectedRole == 'client') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: companyCtrl,
                          decoration: const InputDecoration(
                            labelText: "Razón Social",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: fantasyCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nombre Fantasía (Opcional)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
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
                      final service = ref.read(profilesServiceProvider);
                      await service.createProfileWithAuth({
                        'email': emailCtrl.text,
                        'password': passCtrl.text,
                        'full_name': nameCtrl.text,
                        'rut': rutCtrl.text,
                        'company_name': selectedRole == 'client'
                            ? companyCtrl.text
                            : null,
                        'fantasy_name': selectedRole == 'client'
                            ? fantasyCtrl.text
                            : null,
                        'address': addressCtrl.text,
                      }, selectedRole);
                      ref.invalidate(profilesProvider);
                      // Invalidate clients provider too!
                      ref.invalidate(clientsProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Usuario creado exitosamente"),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  }
                },
                child: const Text("Crear Usuario"),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
  ) {
    final nameCtrl = TextEditingController(text: profile.fullName);
    final rutCtrl = TextEditingController(text: profile.rut);
    final companyCtrl = TextEditingController(text: profile.companyName);
    final fantasyCtrl = TextEditingController(text: profile.fantasyName);
    final addressCtrl = TextEditingController(text: profile.address);
    final formKey = GlobalKey<FormState>();

    String selectedRole = profile.role;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Editar Usuario"),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: const InputDecoration(
                          labelText: "Rol",
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'client',
                            child: Text("Cliente"),
                          ),
                          DropdownMenuItem(
                            value: 'staff',
                            child: Text("Staff / Equipo"),
                          ),
                          DropdownMenuItem(
                            value: 'admin',
                            child: Text("Administrador"),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedRole = val);
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        initialValue: profile.email,
                        readOnly:
                            true, // Email usually hard to change in simple edit
                        decoration: const InputDecoration(
                          labelText: "Email (No editable)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "Datos ${selectedRole == 'client' ? 'de la Empresa / Cliente' : 'Personales'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: "Nombre Completo",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: rutCtrl,
                        decoration: const InputDecoration(
                          labelText: "RUT",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                      ),
                      if (selectedRole == 'client') ...[
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: companyCtrl,
                          decoration: const InputDecoration(
                            labelText: "Razón Social",
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: fantasyCtrl,
                          decoration: const InputDecoration(
                            labelText: "Nombre Fantasía (Opcional)",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
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
                      final updates = {
                        'full_name': nameCtrl.text,
                        'rut': rutCtrl.text,
                        'company_name': selectedRole == 'client'
                            ? companyCtrl.text
                            : null,
                        'fantasy_name': selectedRole == 'client'
                            ? fantasyCtrl.text
                            : null,
                        'address': addressCtrl.text,
                        'role': selectedRole,
                        // Not updating email/password here
                      };

                      final service = ref.read(profilesServiceProvider);
                      await service.updateProfile(profile.id, updates);

                      ref.invalidate(profilesProvider);
                      // Invalidate clients too in case role changed
                      ref.invalidate(clientsProvider);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Usuario actualizado")),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text("Error: $e")));
                      }
                    }
                  }
                },
                child: const Text("Guardar Cambios"),
              ),
            ],
          );
        },
      ),
    );
  }
}
