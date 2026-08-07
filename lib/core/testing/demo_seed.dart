import 'package:nursery_shared/nursery_shared.dart';

import '../../features/sessions/data/models/kid_session.dart';
import '../../features/subscriptions/data/models/plan_assignment.dart';
import '../../features/subscriptions/data/models/subscription_plan.dart';
import '../services/qr_code_service.dart';
import 'attendance_store.dart';
import 'demo_photo_store.dart';

/// One demo child: the kid record, their parent, the plan they're on, and
/// how long they've been checked in today (null = checked out).
///
/// Single source of truth for the app's no-backend demo data. Sessions
/// (roster/clock-in), Subscriptions (who's on what plan), and Finance
/// (payments/overtime, derived from plan assignments) all read from this
/// one list, so a child seen on the Sessions grid is the same child — same
/// id — that shows up in Add Invoice and the payments table. They used to
/// be two unrelated seed lists with different ids, which is why Finance
/// never showed anyone from Sessions.
class DemoChild {
  DemoChild({
    required this.id,
    required this.fullName,
    required this.dateOfBirth,
    required this.parentName,
    required this.parentPhone,
    required this.categoryId,
    required this.lineItemId,
    required this.joinedAt,
    this.allergies,
    this.medicalNotes,
    this.hoursCheckedIn,
  });

  final String id;
  final String fullName;
  final DateTime dateOfBirth;
  final String parentName;
  final String parentPhone;
  final String categoryId;
  final String lineItemId;
  final DateTime joinedAt;
  final String? allergies;
  final String? medicalNotes;
  final double? hoursCheckedIn;

  /// Local file path of a photo the admin picked in a previous run, restored
  /// by [restoreDemoPhotos] before the roster is first built.
  String? photoPath;

  Kid get kid => Kid(
        id: id,
        fullName: fullName,
        dateOfBirth: dateOfBirth,
        photoUrl: photoPath ?? '',
        status: KidStatus.active,
        allergies: allergies,
        medicalNotes: medicalNotes,
        emergencyContactName: parentName,
        emergencyContactPhone: parentPhone,
        createdBy: 'admin',
        createdAt: joinedAt,
        approvedAt: joinedAt.add(const Duration(days: 1)),
        approvedBy: 'admin-1',
        qrPayload: QrCodeService.signKidId(id),
      );

  PlanAssignment get assignment => PlanAssignment(
        kidId: id,
        kidName: fullName,
        parentName: parentName,
        parentPhone: parentPhone,
        categoryId: categoryId,
        lineItemId: lineItemId,
        assignedAt: joinedAt,
      );

  /// This child's line item in the real plan catalog, or null if the plan
  /// was deleted from the catalog since assignment.
  (PlanCategory, PlanLineItem)? get planLineItem {
    for (final category in kInitialPlanCategories) {
      if (category.id != categoryId) continue;
      for (final item in category.lineItems) {
        if (item.id == lineItemId) return (category, item);
      }
    }
    return null;
  }

  /// Contracted hours per day. Null = full-day plan, which has no hourly
  /// cap and therefore never accrues overtime.
  int? get allowedHoursPerDay => planLineItem?.$2.hoursPerDay;

  /// Display label for the Sessions card, resolved against the real plan
  /// catalog so it can't drift from the assignment above.
  String get planLabel {
    final resolved = planLineItem;
    return resolved == null ? 'Unassigned' : '${resolved.$1.name} · ${resolved.$2.label}';
  }

  KidSession toSession() => KidSession(
        kid: kid,
        planLabel: planLabel,
        activeSession: hoursCheckedIn == null
            ? null
            : Session(
                id: 'session-$id',
                kidId: id,
                requestedBy: 'guardian',
                requestedById: 'guardian-$id',
                status: SessionStatus.confirmed,
                checkedInAt: DateTime.now().subtract(Duration(minutes: (hoursCheckedIn! * 60).round())),
                confirmedBy: 'admin-1',
                checkedOutAt: null,
                checkedOutConfirmedBy: null,
                hoursDeducted: null,
                subscriptionId: 'sub-$id',
              ),
      );
}

/// Reapplies photos the admin picked in an earlier run. Must run before the
/// Sessions roster is first read, so the restored paths are baked into the
/// seed rather than needing a refresh.
Future<void> restoreDemoPhotos() async {
  final saved = await DemoPhotoStore.loadAll();
  if (saved.isEmpty) return;
  for (final child in kDemoChildren) {
    final path = saved[child.id];
    if (path != null) child.photoPath = path;
  }
}

/// Fabricates each demo child's attendance history and reopens today's
/// session for whoever is currently on site, so the Sessions grid, the
/// attendance calendar, and Finance's overtime all read the same ledger.
/// Called once at startup (see bootstrap.dart); safe to call again.
void seedDemoAttendance() {
  final store = AttendanceStore.instance;
  for (final child in kDemoChildren) {
    store.seedKid(child.id, child.allowedHoursPerDay);
    if (child.hoursCheckedIn != null && store.openRecord(child.id) == null) {
      store.checkIn(
        child.id,
        DateTime.now().subtract(Duration(minutes: (child.hoursCheckedIn! * 60).round())),
      );
    }
  }
}

/// Ten enrolled children spread across all three plan categories, with a
/// mix of hourly plans (which accrue overtime against the attendance log)
/// and full-day plans (which don't), so every Finance/Subscriptions feature
/// has realistic data to exercise.
final List<DemoChild> kDemoChildren = [
  DemoChild(
    id: 'kid-01',
    fullName: 'Leo Mitchell',
    dateOfBirth: DateTime(2021, 3, 14),
    parentName: 'Sarah Mitchell',
    parentPhone: '971501234567',
    categoryId: 'monthly_packages',
    lineItemId: 'mp_full_5d',
    joinedAt: DateTime(2025, 9, 2),
    allergies: 'Peanuts, Shellfish',
    medicalNotes: 'Carries an EpiPen in his backpack.',
    hoursCheckedIn: 3.7,
  ),
  DemoChild(
    id: 'kid-02',
    fullName: 'Amara Khan',
    dateOfBirth: DateTime(2020, 11, 8),
    parentName: 'James Khan',
    parentPhone: '971502345678',
    categoryId: 'monthly_packages',
    lineItemId: 'mp_8h_5d',
    joinedAt: DateTime(2025, 9, 15),
    allergies: 'Lactose',
    hoursCheckedIn: 5.2,
  ),
  DemoChild(
    id: 'kid-03',
    fullName: 'Noah Watson',
    dateOfBirth: DateTime(2021, 6, 30),
    parentName: 'Emma Watson',
    parentPhone: '971503456789',
    categoryId: 'daily_subscription',
    lineItemId: 'ds_full',
    joinedAt: DateTime(2025, 10, 1),
    medicalNotes: 'Mild asthma — inhaler kept with the nurse.',
    hoursCheckedIn: 1.25,
  ),
  DemoChild(
    id: 'kid-04',
    fullName: 'Sophie Larsen',
    dateOfBirth: DateTime(2022, 1, 22),
    parentName: 'Liam Larsen',
    parentPhone: '971504567890',
    categoryId: 'monthly_packages',
    lineItemId: 'mp_3h_5d',
    joinedAt: DateTime(2025, 10, 20),
    allergies: 'Eggs',
    hoursCheckedIn: 4.8,
  ),
  DemoChild(
    id: 'kid-05',
    fullName: 'Ethan Wright',
    dateOfBirth: DateTime(2020, 8, 5),
    parentName: 'Olivia Wright',
    parentPhone: '971505678901',
    categoryId: 'weekly_special_offers',
    lineItemId: 'wso_5d3h',
    joinedAt: DateTime(2025, 11, 3),
  ),
  DemoChild(
    id: 'kid-06',
    fullName: 'Maya Rose',
    dateOfBirth: DateTime(2021, 9, 17),
    parentName: 'Daniel Rose',
    parentPhone: '971506789012',
    categoryId: 'monthly_packages',
    lineItemId: 'mp_5h_5d',
    joinedAt: DateTime(2025, 11, 18),
    allergies: 'Tree nuts',
    hoursCheckedIn: 2.17,
  ),
  DemoChild(
    id: 'kid-07',
    fullName: 'Oliver Smith',
    dateOfBirth: DateTime(2022, 2, 11),
    parentName: 'Charlotte Smith',
    parentPhone: '971507890123',
    categoryId: 'daily_subscription',
    lineItemId: 'ds_4h',
    joinedAt: DateTime(2025, 12, 5),
    hoursCheckedIn: 1.0,
  ),
  DemoChild(
    id: 'kid-08',
    fullName: 'Emma Davis',
    dateOfBirth: DateTime(2021, 4, 27),
    parentName: 'Michael Davis',
    parentPhone: '971508901234',
    categoryId: 'weekly_special_offers',
    lineItemId: 'wso_15dfull',
    joinedAt: DateTime(2026, 1, 8),
    medicalNotes: 'Needs a nap after 13:00.',
  ),
  DemoChild(
    id: 'kid-09',
    fullName: 'Lucas Brown',
    dateOfBirth: DateTime(2020, 12, 19),
    parentName: 'Sophia Brown',
    parentPhone: '971509012345',
    categoryId: 'monthly_packages',
    lineItemId: 'mp_3h_3d',
    joinedAt: DateTime(2026, 2, 2),
    allergies: 'Gluten',
    hoursCheckedIn: 2.5,
  ),
  DemoChild(
    id: 'kid-10',
    fullName: 'Mia Wilson',
    dateOfBirth: DateTime(2021, 7, 9),
    parentName: 'Benjamin Wilson',
    parentPhone: '971510123456',
    categoryId: 'daily_subscription',
    lineItemId: 'ds_23h',
    joinedAt: DateTime(2026, 3, 16),
  ),
];
