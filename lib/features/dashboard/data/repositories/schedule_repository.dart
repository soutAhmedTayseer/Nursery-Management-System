import 'package:flutter/material.dart';
import 'package:nursery_shared/nursery_shared.dart';

import '../../../../core/testing/fake_failure_switch.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/schedule_item.dart';

/// The nursery's shared daily routine (contract §4 "Schedule").
///
/// One timetable for the whole nursery, not one per admin — two admins looking
/// at the dashboard see the same thing.
abstract class ScheduleRepository {
  Future<List<ScheduleItemModel>> fetchSchedule();
  Future<ScheduleItemModel> createItem(ScheduleItemModel item);
  Future<ScheduleItemModel> updateItem(ScheduleItemModel item);
  Future<void> deleteItem(String id);
}

/// Icon and colour for an activity are design tokens, not server data — the
/// contract carries an `icon_key` and the client maps it, falling back to a
/// neutral default for a key it has never seen.
class ScheduleIcons {
  const ScheduleIcons._();

  static const _byKey = <String, (IconData, Color)>{
    'circle': (Icons.groups_outlined, AppColors.schedulePastelSage),
    'meal': (Icons.restaurant_outlined, AppColors.schedulePastelAmber),
    'nap': (Icons.bedtime_outlined, AppColors.schedulePastelPink),
    'play': (Icons.toys_outlined, AppColors.schedulePastelMint),
    'outdoor': (Icons.park_outlined, AppColors.schedulePastelGreen),
    'story': (Icons.menu_book_outlined, AppColors.schedulePastelPeach),
  };

  static (IconData, Color) resolve(String? key) =>
      _byKey[key] ?? (Icons.schedule_outlined, AppColors.schedulePastelSage);

  /// The key to send back for an icon the admin picked. Falls back to `circle`
  /// so a round-trip never loses the item.
  static String keyFor(IconData icon) {
    for (final entry in _byKey.entries) {
      if (entry.value.$1 == icon) return entry.key;
    }
    return 'circle';
  }
}

ScheduleItemModel _fromJson(Map<String, dynamic> json) {
  final (icon, color) = ScheduleIcons.resolve(json['icon_key'] as String?);
  return ScheduleItemModel(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    startMinutes: (json['start_minutes'] as num).toInt(),
    endMinutes: (json['end_minutes'] as num).toInt(),
    icon: icon,
    themeColor: color,
  );
}

Map<String, dynamic> _toJson(ScheduleItemModel item) => {
      'title': item.title,
      'description': item.description,
      'start_minutes': item.startMinutes,
      'end_minutes': item.endMinutes,
      'icon_key': ScheduleIcons.keyFor(item.icon),
    };

class ApiScheduleRepository implements ScheduleRepository {
  ApiScheduleRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<ScheduleItemModel>> fetchSchedule() async {
    final response =
        await _client.get<Map<String, dynamic>>('/admin/schedule');
    final items = response.data!['items'] as List<dynamic>? ?? const [];
    return [for (final item in items) _fromJson(item as Map<String, dynamic>)];
  }

  @override
  Future<ScheduleItemModel> createItem(ScheduleItemModel item) async {
    final response = await _client.post<Map<String, dynamic>>(
      '/admin/schedule',
      data: _toJson(item),
    );
    return _fromJson(response.data!);
  }

  @override
  Future<ScheduleItemModel> updateItem(ScheduleItemModel item) async {
    final response = await _client.patch<Map<String, dynamic>>(
      '/admin/schedule/${item.id}',
      data: _toJson(item),
    );
    return _fromJson(response.data!);
  }

  @override
  Future<void> deleteItem(String id) async {
    await _client.delete<void>('/admin/schedule/$id');
  }
}

/// Offline routine, seeded from [kInitialSchedule].
class FakeScheduleRepository implements ScheduleRepository {
  FakeScheduleRepository({
    required this.failureSwitch,
    this.latency = const Duration(milliseconds: 200),
  });

  final FakeFailureSwitch failureSwitch;
  final Duration latency;

  late final List<ScheduleItemModel> _items = List.of(kInitialSchedule);

  @override
  Future<List<ScheduleItemModel>> fetchSchedule() async {
    await _tick();
    return List.unmodifiable(_items);
  }

  @override
  Future<ScheduleItemModel> createItem(ScheduleItemModel item) async {
    await _tick();
    // Stands in for the server assigning the id.
    final created = item.id.isEmpty
        ? ScheduleItemModel(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            title: item.title,
            description: item.description,
            startMinutes: item.startMinutes,
            endMinutes: item.endMinutes,
            icon: item.icon,
            themeColor: item.themeColor,
          )
        : item;
    _items.add(created);
    return created;
  }

  @override
  Future<ScheduleItemModel> updateItem(ScheduleItemModel item) async {
    await _tick();
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) throw _notFound;
    _items[index] = item;
    return item;
  }

  @override
  Future<void> deleteItem(String id) async {
    await _tick();
    _items.removeWhere((i) => i.id == id);
  }

  Future<void> _tick() async {
    await Future<void>.delayed(latency);
    failureSwitch.maybeThrow();
  }

  static const _notFound = ApiException(
    code: 'SCHEDULE_ITEM_NOT_FOUND',
    message: 'Schedule item not found',
    statusCode: 404,
  );
}
