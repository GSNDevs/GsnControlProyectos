import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

class ProjectMapViewer extends StatelessWidget {
  final String locationUrl;
  final double height;

  const ProjectMapViewer({
    super.key,
    required this.locationUrl,
    this.height = 300,
  });

  LatLng? _parseCoordinates(String input) {
    if (input.isEmpty) return null;

    // 1. Check if format is raw lat, lng -> "-33.456, -70.123"
    final rawRegex = RegExp(r'^([+-]?\d+\.?\d*)\s*,\s*([+-]?\d+\.?\d*)$');
    final rawMatch = rawRegex.firstMatch(input.trim());
    if (rawMatch != null) {
      return LatLng(
        double.parse(rawMatch.group(1)!),
        double.parse(rawMatch.group(2)!),
      );
    }

    // 2. Check if it's a google maps URL containing @lat,lng
    final urlRegex = RegExp(r'@([+-]?\d+\.\d+),([+-]?\d+\.\d+)');
    final urlMatch = urlRegex.firstMatch(input);
    if (urlMatch != null) {
      return LatLng(
        double.parse(urlMatch.group(1)!),
        double.parse(urlMatch.group(2)!),
      );
    }

    // If we can't parse coordinates, return null
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final coordinates = _parseCoordinates(locationUrl);

    if (coordinates == null) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text(
              'No se encontraron coordenadas válidas.\nFormato esperado: -33.45, -70.12',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final url = Uri.parse(
                  locationUrl.startsWith('http')
                      ? locationUrl
                      : 'https://$locationUrl',
                );
                await launchUrl(url, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_new),
              label: const Text('Abrir enlace de todos modos'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(initialCenter: coordinates, initialZoom: 15.0),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.gsn.controldeproyectos',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: coordinates,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
