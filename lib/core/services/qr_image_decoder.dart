import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:qr_code_vision/qr_code_vision.dart';

/// Decodes a QR code from an image file using a pure-Dart reader — the
/// fallback path for platforms mobile_scanner has no plugin for (Windows,
/// Linux), where "scan" means "pick a photo of the code" instead of a live
/// camera feed.
Future<String?> decodeQrFromImageFile(String path) async {
  final bytes = await File(path).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final rgba = decoded.getBytes(order: img.ChannelOrder.rgba);
  final qrCode = QrCode();
  qrCode.scanRgbaBytes(rgba, decoded.width, decoded.height);
  return qrCode.content?.text;
}
