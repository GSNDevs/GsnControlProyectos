import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../utils/app_colors.dart';

class AdminQuotesScreen extends ConsumerWidget {
  const AdminQuotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quotesAsync = ref.watch(allQuotesProvider);

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
                    'Administración de Cotizaciones',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Revisa las solicitudes de cotización agrupadas por cliente.',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 32),
                  quotesAsync.when(
                    data: (quotes) {
                      if (quotes.isEmpty) {
                        return const Center(child: Text("No hay solicitudes."));
                      }

                      // Agrupar por cliente
                      final grouped = <String, List<Quote>>{};
                      for (var quote in quotes) {
                        if (!grouped.containsKey(quote.clientId)) {
                          grouped[quote.clientId] = [];
                        }
                        grouped[quote.clientId]!.add(quote);
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: grouped.keys.length,
                        itemBuilder: (context, index) {
                          final clientId = grouped.keys.elementAt(index);
                          final clientQuotes = grouped[clientId]!;

                          // Buscamos el Profile de supabase
                          final profileAsync = ref.watch(profilesProvider);

                          return profileAsync.when(
                            data: (profiles) {
                              final profile = profiles.firstWhere(
                                (p) => p.id == clientId,
                                orElse: () => Profile(
                                  id: clientId,
                                  fullName: 'Cliente Desconocido',
                                  email: 'N/A',
                                  createdAt: DateTime.now(),
                                ),
                              );

                              return _buildClientGroup(
                                context,
                                ref,
                                profile,
                                clientQuotes,
                              );
                            },
                            loading: () => const LinearProgressIndicator(),
                            error: (e, _) => Text('Error al cargar perfil: $e'),
                          );
                        },
                      );
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
    );
  }

  Widget _buildClientGroup(
    BuildContext context,
    WidgetRef ref,
    Profile profile,
    List<Quote> quotes,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [...AppColors.mediumShadow],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.gsnBlue.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.gsnBlue),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '${quotes.length} solicitudes activas',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          children: quotes
              .map((quote) => _buildQuoteCard(context, ref, quote))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildQuoteCard(BuildContext context, WidgetRef ref, Quote quote) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
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
                  quote.serviceType,
                  style: TextStyle(
                    color: _getServiceTypeColor(quote.serviceType),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Status Dropdown
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: DropdownButton<String>(
                  value: quote.status,
                  icon: const Icon(Icons.arrow_drop_down, size: 20),
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'recibida',
                      child: Text('Nueva / Recibida'),
                    ),
                    DropdownMenuItem(
                      value: 'en_revision',
                      child: Text('En Revisión'),
                    ),
                    DropdownMenuItem(
                      value: 'pendiente',
                      child: Text('Pendiente'),
                    ),
                    DropdownMenuItem(
                      value: 'aceptada',
                      child: Text('Aceptada'),
                    ),
                    DropdownMenuItem(
                      value: 'rechazada',
                      child: Text('Rechazada'),
                    ),
                    DropdownMenuItem(
                      value: 'expirada',
                      child: Text('Expirada'),
                    ),
                  ],
                  onChanged: (newStatus) {
                    if (newStatus != null && newStatus != quote.status) {
                      ref
                          .read(quotesControllerProvider)
                          .updateQuoteStatus(
                            quote.id,
                            newStatus,
                            quote.clientId,
                          );
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (quote.description != null)
            Text(
              quote.description!,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: [
              if (quote.urgency != null)
                _buildDetailItem(Icons.timelapse, 'Urgencia', quote.urgency!),
              if (quote.hasCurrentSystem != null)
                _buildDetailItem(
                  Icons.computer,
                  'Sistema Actual',
                  quote.hasCurrentSystem!,
                ),
              if (quote.isReplacement != null)
                _buildDetailItem(
                  Icons.swap_horiz,
                  'Reemplazo',
                  quote.isReplacement!,
                ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Whatsapp Button
              ElevatedButton.icon(
                onPressed: () => _openWhatsApp(quote.phone),
                icon: const Icon(Icons.chat, color: Colors.white),
                label: const Text(
                  'Responder por WhatsApp',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),

              // Evidences
              if (quote.documentsUrls.isNotEmpty)
                TextButton.icon(
                  onPressed: () =>
                      _showDocumentsDialog(context, quote.documentsUrls),
                  icon: const Icon(Icons.folder, color: AppColors.gsnBlue),
                  label: Text('Ver Documentos (${quote.documentsUrls.length})'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ],
    );
  }

  void _openWhatsApp(String phone) async {
    // Limpiar el número de espacios, guiones o signos + extraños
    String cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    // Asumir código 56 chileno si no lo tiene y comienza con 9
    if (cleanPhone.startsWith('9') && cleanPhone.length == 9) {
      cleanPhone = '56$cleanPhone';
    } else if (cleanPhone.startsWith('569')) {
      // ya está bien
    }

    final url = Uri.parse('https://wa.me/$cleanPhone');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showDocumentsDialog(BuildContext context, List<String> urls) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Documentos Adjuntos'),
        content: SizedBox(
          width: 500,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: urls.length,
            itemBuilder: (context, index) {
              final url = urls[index];
              final ext = url.split('.').last.toLowerCase().split('?').first;
              final isImage = [
                'jpg',
                'jpeg',
                'png',
                'webp',
                'gif',
              ].contains(ext);

              if (isImage) {
                return InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InteractiveViewer(
                              child: Image.network(url, fit: BoxFit.contain),
                            ),
                            Positioned(
                              top: 16,
                              right: 16,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Image.network(url, fit: BoxFit.cover),
                  ),
                );
              }

              // Non-image rendering
              IconData iconData = Icons.insert_drive_file;
              if (ext == 'pdf')
                iconData = Icons.picture_as_pdf;
              else if (['doc', 'docx'].contains(ext))
                iconData = Icons.description;

              return InkWell(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) await launchUrl(uri);
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(iconData, size: 48, color: AppColors.gsnBlue),
                      const SizedBox(height: 8),
                      Text(
                        'Doc ${index + 1} ($ext)',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
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
}
