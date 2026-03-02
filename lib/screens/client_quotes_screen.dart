import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_colors.dart';
import '../utils/image_helper.dart';

class ClientQuotesScreen extends ConsumerStatefulWidget {
  const ClientQuotesScreen({super.key});

  @override
  ConsumerState<ClientQuotesScreen> createState() => _ClientQuotesScreenState();
}

class _ClientQuotesScreenState extends ConsumerState<ClientQuotesScreen> {
  final _supabase = Supabase.instance.client;

  void _showNewQuoteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const _NewQuoteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) return const Center(child: Text("Cargando..."));

    final quotesAsync = ref.watch(clientQuotesProvider(currentUser.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mis Cotizaciones',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revisa el estado de tus solicitudes o pide nuevas cotizaciones.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  quotesAsync.when(
                    data: (quotes) {
                      if (quotes.isEmpty) {
                        return _buildEmptyState();
                      }
                      return _buildQuotesList(quotes);
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => Center(child: Text('Error: $error')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewQuoteDialog,
        backgroundColor: AppColors.gsnBlue,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nueva Solicitud",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [...AppColors.mediumShadow],
      ),
      child: Column(
        children: [
          Icon(
            Icons.request_quote_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          const Text(
            'No tienes solicitudes de cotización',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Presiona el botón "Nueva Solicitud" para empezar.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesList(List<Quote> quotes) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quotes.length,
      itemBuilder: (context, index) {
        final quote = quotes[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [...AppColors.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      quote.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getServiceTypeColor(
                            quote.serviceType,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getServiceTypeName(quote.serviceType),
                          style: TextStyle(
                            color: _getServiceTypeColor(quote.serviceType),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _getStatusBadge(quote.status),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (quote.description != null && quote.description!.isNotEmpty)
                Text(
                  quote.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enviada el ${_formatDate(quote.createdAt)}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  if (quote.documentsUrls.isNotEmpty)
                    Row(
                      children: [
                        const Icon(
                          Icons.attach_file,
                          size: 16,
                          color: AppColors.gsnBlue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${quote.documentsUrls.length} adjuntos',
                          style: const TextStyle(
                            color: AppColors.gsnBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Color _getServiceTypeColor(String type) {
    switch (type) {
      case 'Software':
        return AppColors.gsnBlue;
      case 'Hardware':
        return Colors.orange;
      case 'Hybrid':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _getServiceTypeName(String type) {
    switch (type) {
      case 'Software':
        return 'Desarrollo de Software';
      case 'Hardware':
        return 'Instalación Física';
      case 'Hybrid':
        return 'Proyecto Híbrido';
      default:
        return type;
    }
  }

  Widget _getStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case 'recibida':
        color = Colors.blueGrey;
        label = 'Recibida';
        break;
      case 'en_revision':
        color = Colors.amber.shade800;
        label = 'En Revisión';
        break;
      case 'pendiente':
        color = const Color(0xFFF97316); // Orange
        label = 'Pendiente Cliente';
        break;
      case 'aceptada':
        color = AppColors.success;
        label = 'Aceptada';
        break;
      case 'rechazada':
        color = AppColors.error;
        label = 'Rechazada';
        break;
      case 'expirada':
        color = Colors.grey.shade600;
        label = 'Expirada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

// ==========================================
// NEW QUOTE DIALOG
// ==========================================

class _NewQuoteDialog extends ConsumerStatefulWidget {
  const _NewQuoteDialog();

  @override
  ConsumerState<_NewQuoteDialog> createState() => _NewQuoteDialogState();
}

class _NewQuoteDialogState extends ConsumerState<_NewQuoteDialog> {
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String _serviceType = 'Hardware';
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Dynamic fields
  String _urgency = 'En los próximos 3 meses';
  String _hasSystem = 'No';
  String _isReplacement = 'No';

  final List<PlatformFile> _selectedFiles = [];

  final List<String> _serviceOptions = ['Hardware', 'Software', 'Hybrid'];
  final List<String> _urgencyOptions = [
    'Lo antes posible',
    'En 1 mes',
    'En los próximos 3 meses',
    'Aún planificando',
  ];
  final List<String> _yesNoOptions = ['Sí', 'No'];

  Future<void> _pickFiles() async {
    if (_selectedFiles.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 3 archivos permitidos.')),
      );
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );

    if (result != null) {
      setState(() {
        final newFiles = result.files;
        if (_selectedFiles.length + newFiles.length > 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Solo se pueden agregar hasta 3 archivos en total.',
              ),
            ),
          );
          return;
        }
        _selectedFiles.addAll(newFiles);
      });
    }
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _submitQuote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) throw Exception('No session');

      final controller = ref.read(quotesControllerProvider);
      final List<String> uploadedUrls = [];

      // 1. Upload files if any
      for (var file in _selectedFiles) {
        if (file.bytes == null) continue;

        // Use ImageHelper compression if image
        final isImage =
            file.extension?.toLowerCase() == 'jpg' ||
            file.extension?.toLowerCase() == 'jpeg' ||
            file.extension?.toLowerCase() == 'png';

        var finalBytes = file.bytes!;
        if (isImage) {
          final compressed = await ImageHelper.compressImage(finalBytes);
          if (compressed != null) {
            finalBytes = compressed;
          }
        }

        final url = await controller.uploadDocument(
          currentUser.id,
          finalBytes,
          file.name,
        );
        uploadedUrls.add(url);
      }

      // 2. Submit record
      await controller.createQuote({
        'client_id': currentUser.id,
        'service_type': _serviceType,
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'urgency': _urgency,
        'has_current_system':
            (_serviceType == 'Software' || _serviceType == 'Hybrid')
            ? _hasSystem
            : null,
        'is_replacement':
            (_serviceType == 'Hardware' || _serviceType == 'Hybrid')
            ? _isReplacement
            : null,
        'status': 'recibida',
        'documents_urls': uploadedUrls,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cotización enviada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: 600,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solicitar Cotización',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Datos Contacto
                      const Text(
                        'Datos de Contacto',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              decoration: _inputDecoration(
                                'Teléfono Móvil (+569...)',
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (v) => v!.isEmpty ? 'Requerido' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: _inputDecoration(
                                'Correo Electrónico',
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) => v!.isEmpty || !v.contains('@')
                                  ? 'Correo ínvalido'
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 2. Requerimiento Central
                      const Text(
                        'Requerimiento Central',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _serviceType,
                        decoration: _inputDecoration('Tipo de Servicio'),
                        items: _serviceOptions
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e == 'Software'
                                      ? 'Desarrollo de Software'
                                      : e == 'Hardware'
                                      ? 'Instalación Física'
                                      : 'Proyecto Híbrido',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _serviceType = val!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _titleController,
                        decoration: _inputDecoration(
                          'Título breve (Ej: Instalación de 10 Cámaras)',
                        ),
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: _inputDecoration(
                          'Descripción detallada de la necesidad',
                        ),
                        maxLines: 4,
                        validator: (v) => v!.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 24),

                      // 3. Preguntas Dinámicas
                      const Text(
                        'Cuestionario Adicional',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _urgency,
                        decoration: _inputDecoration(
                          '¿Para cuándo esperarías arrancar este proyecto?',
                        ),
                        items: _urgencyOptions
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (val) => setState(() => _urgency = val!),
                      ),

                      if (_serviceType == 'Software' ||
                          _serviceType == 'Hybrid') ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _hasSystem,
                          decoration: _inputDecoration(
                            '¿Tienes algún sistema operando actualmente?',
                          ),
                          items: _yesNoOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) => setState(() => _hasSystem = val!),
                        ),
                      ],
                      if (_serviceType == 'Hardware' ||
                          _serviceType == 'Hybrid') ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _isReplacement,
                          decoration: _inputDecoration(
                            '¿Necesitas reemplazar equipos existentes?',
                          ),
                          items: _yesNoOptions
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _isReplacement = val!),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // 4. Adjuntos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Archivos Adjuntos (Max 3)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: _selectedFiles.length >= 3
                                ? null
                                : _pickFiles,
                            icon: const Icon(Icons.attach_file),
                            label: const Text('Adjuntar Archivo'),
                          ),
                        ],
                      ),
                      if (_selectedFiles.isNotEmpty)
                        Column(
                          children: _selectedFiles.asMap().entries.map((entry) {
                            return ListTile(
                              leading: const Icon(Icons.file_present),
                              title: Text(entry.value.name),
                              subtitle: Text(
                                '${(entry.value.size / 1024).round()} KB',
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _removeFile(entry.key),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Footer Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitQuote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Enviar Solicitud',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey.shade600),
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.gsnBlue, width: 2),
      ),
    );
  }
}
