import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bundle_model.dart';
import '../repository/bundle_repository.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class BundleState {
  final List<BundleModel> all;
  final List<BundleModel> filtered;
  final String query;
  final BundleFilter activeFilter;
  final bool isLoading;
  final String? error;

  const BundleState({
    this.all = const [],
    this.filtered = const [],
    this.query = '',
    this.activeFilter = BundleFilter.all,
    this.isLoading = false,
    this.error,
  });

  BundleState copyWith({
    List<BundleModel>? all,
    List<BundleModel>? filtered,
    String? query,
    BundleFilter? activeFilter,
    bool? isLoading,
    String? error,
  }) =>
      BundleState(
        all: all ?? this.all,
        filtered: filtered ?? this.filtered,
        query: query ?? this.query,
        activeFilter: activeFilter ?? this.activeFilter,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class BundleController extends Notifier<BundleState> {
  late final BundleRepository _repo;

  @override
  BundleState build() {
    _repo = BundleRepository();
    // Auto-load on first access
    Future.microtask(loadBundles);
    return const BundleState(isLoading: true);
  }

  Future<void> loadBundles() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bundles = await _repo.getBundles();
      state = state.copyWith(all: bundles, isLoading: false);
      _applyFilters();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to load bundles.');
    }
  }

  void search(String query) {
    state = state.copyWith(query: query);
    _applyFilters();
  }

  void setFilter(BundleFilter filter) {
    state = state.copyWith(activeFilter: filter);
    _applyFilters();
  }

  void clearAll() {
    state = state.copyWith(query: '', activeFilter: BundleFilter.all);
    _applyFilters();
  }

  void markPurchased(String bundleId) {
    _repo.markPurchased(bundleId);
    final updated = state.all.map((b) {
      if (b.id != bundleId) return b;
      return BundleModel(
        id: b.id, name: b.name, description: b.description,
        price: b.price, thumbnailUrl: b.thumbnailUrl,
        courseCount: b.courseCount, isPurchased: true, isFree: b.isFree,
        originalPrice: b.originalPrice, category: b.category,
        rating: b.rating, reviewCount: b.reviewCount,
      );
    }).toList();
    state = state.copyWith(all: updated);
    _applyFilters();
  }

  void _applyFilters() {
    var result = state.all.toList();

    // Search — name + description
    final q = state.query.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result.where((b) =>
      b.name.toLowerCase().contains(q) ||
          b.description.toLowerCase().contains(q) ||
          (b.category?.toLowerCase().contains(q) ?? false)).toList();
    }

    // Filter tab
    result = switch (state.activeFilter) {
      BundleFilter.all       => result,
      BundleFilter.free      => result.where((b) => b.isFree || b.price == 0).toList(),
      BundleFilter.paid      => result.where((b) => !b.isFree && b.price > 0).toList(),
      BundleFilter.purchased => result.where((b) => b.isPurchased).toList(),
    };

    state = state.copyWith(filtered: result);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final bundleProvider =
NotifierProvider<BundleController, BundleState>(BundleController.new);