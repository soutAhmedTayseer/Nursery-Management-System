import 'package:easy_localization/easy_localization.dart';
import 'package:nursery_shared/nursery_shared.dart';

/// Translation key for a backend error code.
///
/// `KID_NOT_FOUND` -> `error_kid_not_found`. Keys live in
/// `assets/translations/{en,ar}.json`; unknown codes fall back to
/// `error_generic` at render time.
String apiErrorKey(ApiException exception) {
  final code = exception.code.trim();
  if (code.isEmpty) return 'error_generic';
  return 'error_${code.toLowerCase()}';
}

/// Localized, user-facing text for [exception].
///
/// Never surfaces `exception.toString()` (root AGENTS.md §7).
String apiErrorMessage(ApiException exception) {
  final key = apiErrorKey(exception);
  final translated = key.tr();
  // easy_localization returns the key itself when it is missing.
  return translated == key ? 'error_generic'.tr() : translated;
}
