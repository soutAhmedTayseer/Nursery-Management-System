import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the nursery's max on-site capacity — no backend `/admin/settings`
/// endpoint yet (see root AGENTS.md API contract, `NurserySettings.capacity`),
/// so this is in-memory admin-editable state the Dashboard's occupancy
/// card reads against, same pattern as PlansCubit.
class NurserySettingsCubit extends Cubit<int> {
  NurserySettingsCubit([int seed = 50]) : super(seed);

  void setCapacity(int capacity) {
    if (capacity > 0) emit(capacity);
  }
}
