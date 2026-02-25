import 'dart:io';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class ImageHelper {
  static final ImageHelper _instance = ImageHelper._internal();
  factory ImageHelper() => _instance;
  ImageHelper._internal();

  final ImagePicker _picker = ImagePicker();

  /// Selecciona múltiples imágenes.
  /// Selecciona múltiples imágenes (Galería).
  Future<List<File>> pickMultipleImages({int quality = 70}) async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isEmpty) return [];

      final List<Future<File?>> tasks = pickedFiles.map((xFile) {
        return _compressImage(File(xFile.path), quality: quality);
      }).toList();

      final results = await Future.wait(tasks);

      return results.whereType<File>().toList();
    } catch (e) {
      debugPrint("Error seleccionando imágenes: $e");
      return [];
    }
  }

  /// Selecciona una sola imagen (Cámara por defecto).
  Future<File?> pickImage({
    ImageSource source = ImageSource.camera,
    int quality = 70,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);

      if (pickedFile == null) return null;

      return _compressImage(File(pickedFile.path), quality: quality);
    } catch (e) {
      debugPrint("Error capturand imagen: $e");
      return null;
    }
  }

  Future<File?> _compressImage(File file, {required int quality}) async {
    try {
      final dir = await getTemporaryDirectory();
      final name = p.basenameWithoutExtension(file.path);
      // Añadimos un identificador simple al nombre y cambiamos a webp
      final targetPath =
          '${dir.path}/${name}_c${DateTime.now().millisecondsSinceEpoch}.webp';

      // Configuración de compresión a WebP
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality, // 70 por defecto reduce peso significativamente
        format: CompressFormat.webp, // Convertimos a webp
      );

      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint("Error comprimiendo: $e");
      return null;
    }
  }

  /// Compress an image from bytes directly (useful for Web/FilePicker)
  static Future<Uint8List?> compressImage(Uint8List list) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        list,
        quality: 70,
        format: CompressFormat.webp,
      );
      return result;
    } catch (e) {
      debugPrint("Error comprimiendo bytes: $e");
      return null;
    }
  }
}
