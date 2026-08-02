import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Signs/verifies the QR payload printed on a kid's attendance record and
/// scanned by admins (and later the parent app) to clock a kid in or out.
///
/// ponytail: HMAC key is a hardcoded app-local placeholder — there's no
/// backend yet to issue a real per-nursery signing key. Swap `_secret` for a
/// backend-issued key once one exists; payloads signed with the old key will
/// simply stop verifying, which is fine for re-issued QR codes.
class QrCodeService {
  const QrCodeService._();

  static const _secret = 'nursery-qr-dev-placeholder-secret';
  static const _separator = '.';

  /// Builds the signed payload to encode into a kid's QR code.
  static String signKidId(String kidId) {
    final signature = Hmac(sha256, utf8.encode(_secret)).convert(utf8.encode(kidId));
    return '$kidId$_separator${signature.toString()}';
  }

  /// Decodes a scanned payload, returning the kid id if the signature is
  /// valid, or null for a malformed/forged/tampered code.
  static String? verify(String payload) {
    final parts = payload.split(_separator);
    if (parts.length != 2) return null;
    final kidId = parts[0];
    final expected = Hmac(sha256, utf8.encode(_secret)).convert(utf8.encode(kidId)).toString();
    return expected == parts[1] ? kidId : null;
  }
}
