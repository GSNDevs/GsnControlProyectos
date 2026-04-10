import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authProvider.notifier)
          .login(_emailController.text, _passwordController.text);
      // Router will handle redirect automatically based on generated Role
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll("Exception: ", "")),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 900;

    return Scaffold(
      body: Row(
        children: [
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.gsnDarkBlue, AppColors.gsnBlue],
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decoraciones de fondo
                    Positioned(
                      top: -150,
                      left: -100,
                      child: Container(
                        width: 500,
                        height: 500,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -100,
                      right: -150,
                      child: Container(
                        width: 600,
                        height: 600,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gsnRed.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    // Contenido branding
                    Padding(
                      padding: const EdgeInsets.all(80.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: const Text(
                              "GSN Plataforma Empresarial",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Gestiona, Monitorea y\nControla de forma\nInteligente.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "Sistema integral centralizado para la administración\nde recursos, usuarios y servicios.",
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 20,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            flex: 4,
            child: Container(
              decoration: isDesktop
                  ? const BoxDecoration(color: Colors.white)
                  : const BoxDecoration(gradient: AppColors.loginBackgroundGradient),
              child: Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: _buildFormCard(isDesktop),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(bool isDesktop) {
    final formContent = Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gsnBlue.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  size: 32,
                  color: AppColors.gsnBlue,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Bienvenido",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "Ingresa tus credenciales para continuar",
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          const Text("Correo Electrónico", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "ejemplo@empresa.com",
              prefixIcon: const Icon(Icons.email_outlined, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gsnBlue, width: 2),
              ),
              filled: true,
              fillColor: isDesktop ? Colors.grey[50] : Colors.white,
            ),
            validator: (v) => v!.isEmpty ? "Ingresa tu email" : null,
          ),
          const SizedBox(height: 24),
          const Text("Contraseña", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            style: const TextStyle(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: "••••••••",
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.divider),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.gsnBlue, width: 2),
              ),
              filled: true,
              fillColor: isDesktop ? Colors.grey[50] : Colors.white,
            ),
            validator: (v) => v!.isEmpty ? "Ingresa tu contraseña" : null,
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gsnBlue,
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
              child: const Text("¿Olvidaste tu contraseña?"),
            ),
          ),
          const SizedBox(height: 32),
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gsnRed.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      "INICIAR SESIÓN",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );

    if (isDesktop) {
      return formContent;
    } else {
      // Glassmorphism on mobile to blend with the background gradient
      return ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
              ),
              boxShadow: AppColors.mediumShadow,
            ),
            child: formContent,
          ),
        ),
      );
    }
  }
}
