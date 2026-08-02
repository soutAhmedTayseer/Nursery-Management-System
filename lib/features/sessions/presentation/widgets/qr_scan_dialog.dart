import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/qr_image_decoder.dart';
import '../../../../core/theme/app_colors.dart';

/// mobile_scanner has no Windows/Linux plugin implementation at all — those
/// platforms get an "upload a photo of the QR" flow instead of a live feed.
bool get _supportsLiveScanner => kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// QR scanner overlay — decodes a kid's clock-in/out QR and resolves with
/// the raw scanned payload, or null if the admin closes it unscanned.
class QrScanDialog extends StatefulWidget {
  const QrScanDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(context: context, builder: (_) => const QrScanDialog());
  }

  @override
  State<QrScanDialog> createState() => _QrScanDialogState();
}

class _QrScanDialogState extends State<QrScanDialog> {
  MobileScannerController? _controller;
  bool _handled = false;
  bool _decoding = false;
  bool _uploadFailed = false;

  @override
  void initState() {
    super.initState();
    if (_supportsLiveScanner) {
      _controller = MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null) return;
    _handled = true;
    Navigator.of(context).pop(value);
  }

  Future<void> _pickAndDecode() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    final path = result?.files.single.path;
    if (path == null || !mounted) return;
    setState(() {
      _decoding = true;
      _uploadFailed = false;
    });
    final payload = await decodeQrFromImageFile(path);
    if (!mounted) return;
    if (payload == null) {
      setState(() {
        _decoding = false;
        _uploadFailed = true;
      });
      return;
    }
    Navigator.of(context).pop(payload);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('session_scan_qr_title'.tr(), style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              _supportsLiveScanner ? 'session_scan_qr_hint'.tr() : 'session_scan_qr_upload_hint'.tr(),
              style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
            ),
            SizedBox(height: 16.h),
            if (_supportsLiveScanner)
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: SizedBox(width: 360.w, height: 360.w, child: MobileScanner(controller: _controller, onDetect: _onDetect)),
              )
            else
              _buildUploadArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadArea() {
    return SizedBox(
      width: 360.w,
      child: Column(
        children: [
          Container(
            width: 360.w,
            height: 220.w,
            decoration: BoxDecoration(color: AppColors.surfaceSand, borderRadius: BorderRadius.circular(24.r)),
            alignment: Alignment.center,
            child: _decoding
                ? const CircularProgressIndicator()
                : Icon(Icons.qr_code_2, size: 64.w, color: Colors.grey.shade400),
          ),
          if (_uploadFailed) ...[
            SizedBox(height: 12.h),
            Text('session_scan_qr_invalid'.tr(), style: TextStyle(fontSize: 12.sp, color: AppColors.errorRed)),
          ],
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: _decoding ? null : _pickAndDecode,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999))),
            icon: const Icon(Icons.upload_file, color: Colors.white),
            label: Text('session_scan_qr_upload_button'.tr(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
