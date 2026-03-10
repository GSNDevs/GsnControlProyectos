
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gsn_control_de_proyectos/models/models.dart';
import 'package:gsn_control_de_proyectos/providers/providers.dart';
import 'package:gsn_control_de_proyectos/services/user_documents_service.dart';
import 'package:gsn_control_de_proyectos/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gsn_control_de_proyectos/providers/auth_provider.dart';

class UserDocumentsDialog extends ConsumerStatefulWidget {
  final Profile profile;
  final Project project;
  final bool isClientView;

  const UserDocumentsDialog({
    super.key,
    required this.profile,
    required this.project,
    this.isClientView = false,
  });

  @override
  ConsumerState<UserDocumentsDialog> createState() => _UserDocumentsDialogState();
}

class _UserDocumentsDialogState extends ConsumerState<UserDocumentsDialog> {
  final List<String> _reqDocumentTypes = [
    'RIOHS',
    'DAS',
    'Entrega EPP',
    'Protocolo Alcohol y Drogas',
    'Exámenes de altura'
  ];

  @override
  Widget build(BuildContext context) {
    final docsAsync = widget.isClientView 
        ? ref.watch(projectVisibleDocumentsProvider(widget.project.id))
        : ref.watch(userDocumentsProvider(widget.profile.id));

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Documentos de Seguridad"),
          const SizedBox(height: 4),
          Text(
            widget.profile.fullName ?? widget.profile.email ?? '',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),
        ],
      ),
      content: SizedBox(
        width: 600,
        height: 500,
        child: docsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text("Error: $err")),
          data: (documents) {
            // Un cliente solo ve los documentos del usuario filtrados que sean isVisibleToClient.
            // La query de projectVisibleDocumentsProvider ya debe retornar todo lo del proyecto, 
            // pero debemos filtrarlo de nuevo por el profile de este modal.
            final userDocs = widget.isClientView
              ? documents.where((d) => d.profileId == widget.profile.id).toList()
              : documents;

            return ListView.separated(
              itemCount: _reqDocumentTypes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
              itemBuilder: (context, index) {
                final docType = _reqDocumentTypes[index];
                // Check if doc exists
                final doc = userDocs.where((d) => d.documentType == docType).firstOrNull;

                if (widget.isClientView && doc == null) {
                  // Si es cliente y no existe/no es visible, retorna vacío
                  return const SizedBox.shrink();
                }

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: doc != null 
                        ? AppColors.success.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    child: Icon(
                      doc != null ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                      color: doc != null ? AppColors.success : Colors.orange,
                    ),
                  ),
                  title: Text(docType, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: doc != null
                      ? Text(
                          "Validez: ${doc.validUntil != null ? DateFormat('dd/MM/yyyy').format(doc.validUntil!) : 'Permanente'}",
                          style: TextStyle(
                            color: (doc.validUntil != null && doc.validUntil!.isBefore(DateTime.now()))
                                ? AppColors.error
                                : AppColors.textSecondary,
                          ),
                        )
                      : const Text("Documento no cargado", style: TextStyle(color: AppColors.textSecondary)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (doc != null)
                        IconButton(
                          icon: const Icon(Icons.download_rounded, color: AppColors.gsnBlue),
                          tooltip: "Descargar",
                          onPressed: () => _launchURL(doc.fileUrl),
                        ),
                      if (!widget.isClientView && doc != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
                            const Text("Visible para cliente", style: TextStyle(fontSize: 10)),
                            Switch(
                              value: doc.isVisibleToClient,
                              activeColor: AppColors.gsnBlue,
                              onChanged: (val) async {
                                await ref
                                  .read(userDocumentsControllerProvider)
                                  .updateDocument(widget.profile.id, doc.id, {'is_visible_to_client': val});
                              },
                            ),
                          ],
                        ),
                      if (!widget.isClientView)
                        IconButton(
                          icon: Icon(
                            doc != null ? Icons.edit_rounded : Icons.upload_file_rounded,
                            color: doc != null ? AppColors.textSecondary : AppColors.gsnBlue,
                          ),
                          tooltip: doc != null ? "Editar Documento" : "Subir Documento",
                          onPressed: () => _showUploadDialog(context, docType, doc),
                        ),
                      if (!widget.isClientView && doc != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          tooltip: "Eliminar Documento",
                          onPressed: () => _confirmDelete(context, doc),
                        ),
                    ],
                  ),
                );
              },
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
  }

  void _showUploadDialog(BuildContext context, String docType, UserDocument? existingDoc) {
    DateTime? selectedDate = existingDoc?.validUntil;
    bool isVisible = existingDoc?.isVisibleToClient ?? false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(existingDoc == null ? "Subir $docType" : "Editar $docType"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text("Fecha de Validez"),
                  subtitle: Text(
                    selectedDate == null 
                        ? "Permanente" 
                        : DateFormat('dd/MM/yyyy').format(selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_month_rounded),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) {
                      setState(() => selectedDate = d);
                    }
                  },
                ),
                SwitchListTile(
                  title: const Text("Visible para Cliente"),
                  value: isVisible,
                  activeColor: AppColors.gsnBlue,
                  onChanged: (val) => setState(() => isVisible = val),
                ),
                const SizedBox(height: 16),
                if (existingDoc == null)
                  const Text("Se le pedirá seleccionar un archivo PDF en el siguiente paso.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
                else
                  const Text("Si selecciona 'Guardar', se mantendrá el documento actual. Puede usar 'Reemplazar Archivo' para subir uno nuevo.", style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancelar"),
              ),
              if (existingDoc != null)
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _handleUpload(docType, selectedDate, isVisible, existingDoc: existingDoc, replaceFile: true);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white),
                  child: const Text("Reemplazar Archivo"),
                ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (existingDoc != null) {
                    // Just update metadata
                    try {
                      await ref.read(userDocumentsControllerProvider).updateDocument(
                        widget.profile.id,
                        existingDoc.id,
                        {
                          'valid_until': selectedDate?.toIso8601String(),
                          'is_visible_to_client': isVisible,
                        }
                      );
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Documento actualizado")));
                    } catch (e) {
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
                    }
                  } else {
                    // Upload new
                    await _handleUpload(docType, selectedDate, isVisible);
                  }
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        }
      ),
    );
  }

  Future<void> _handleUpload(String docType, DateTime? validUntil, bool isVisible, {UserDocument? existingDoc, bool replaceFile = false}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (result != null && result.files.single.bytes != null) {
        final bytes = result.files.single.bytes!;
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Subiendo documento...")));
        
        final service = ref.read(userDocumentsServiceProvider);
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final extension = result.files.single.extension ?? 'pdf';
        
        // Structure: safety_documents / profileId / docType_timestamp.pdf
        final sanitizedDocType = _sanitizeFilename(docType);
        final path = '${widget.profile.id}/${sanitizedDocType}_$timestamp.$extension';
        
        final url = await service.uploadDocument(bytes, path);

        if (existingDoc != null && replaceFile) {
          // Edit existing entry
          await ref.read(userDocumentsControllerProvider).updateDocument(
            widget.profile.id,
            existingDoc.id,
            {
              'file_url': url,
              'valid_until': validUntil?.toIso8601String(),
              'is_visible_to_client': isVisible,
            }
          );
          // Try to delete old file
          await service.deleteStorageDocument(existingDoc.fileUrl);
        } else {
          // Insert new entry
          await ref.read(userDocumentsControllerProvider).createDocument(
            widget.profile.id,
            {
              'profile_id': widget.profile.id,
              'document_type': docType,
              'file_url': url,
              'valid_until': validUntil?.toIso8601String(),
              'is_visible_to_client': isVisible,
            }
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Documento guardado exitosamente.")));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al subir archivo: $e")));
      }
    }
  }

  void _confirmDelete(BuildContext context, UserDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Eliminar Documento"),
        content: const Text("¿Estás seguro de que deseas eliminar este documento? Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(userDocumentsControllerProvider).deleteDocument(
                  widget.profile.id, 
                  doc.id, 
                  fileUrl: doc.fileUrl
                );
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Documento eliminado")));
              } catch(e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
              }
            },
            child: const Text("Eliminar", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  String _sanitizeFilename(String text) {
    const withDia = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
    const withoutDia = 'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeeCcDIIIIiiiiUUUUuuuuNnSsYyyZz';
    
    String str = text;
    for (int i = 0; i < withDia.length; i++) {
        str = str.replaceAll(withDia[i], withoutDia[i]);
    }
    
    // Replace spaces and ensure only alphanumeric and underscores
    return str.replaceAll(' ', '_').replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
  }
}
