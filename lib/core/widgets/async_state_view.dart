import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../l10n/api_error_messages.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'list_skeleton.dart';

/// Maps a cubit's async state onto loading / error / empty / data UI.
///
/// Precedence is error, then loading, then empty, then data — a failed refresh
/// must not hide behind a spinner.
class AsyncStateView extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.isEmpty,
    required this.onRetry,
    required this.emptyMessage,
    required this.builder,
  });

  final bool isLoading;
  final ApiException? error;
  final bool isEmpty;
  final VoidCallback onRetry;

  /// Already-translated text, e.g. `'sessions_empty'.tr()`.
  final String emptyMessage;

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final spacing = AppSpacing.of(context);

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.errorRed,
              size: AppSpacing.iconLg,
            ),
            SizedBox(height: spacing.md),
            Text(
              apiErrorMessage(error!),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: spacing.sm),
            TextButton(
              onPressed: onRetry,
              child: Text('state_error_retry'.tr()),
            ),
          ],
        ),
      );
    }

    if (isLoading) return const ListSkeleton();

    if (isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              color: AppColors.textTertiary,
              size: AppSpacing.iconLg,
            ),
            SizedBox(height: spacing.md),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return builder(context);
  }
}
