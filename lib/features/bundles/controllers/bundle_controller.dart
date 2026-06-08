import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/bundle_model.dart';

// ─── State ────────────────────────────────────────────────────────────────────
class BundleListState {
  final List<Bundle> allBundles;
  final List<Bundle> filtered;
  final String searchQuery;
  final BundleCategory selectedCategory;
  final SortOption sortOption;
  final bool isLoading;
  final String? selectedExamFilter; // SSC, UPSC, etc. or null = all

  const BundleListState({
    required this.allBundles,
    required this.filtered,
    this.searchQuery = '',
    this.selectedCategory = BundleCategory.all,
    this.sortOption = SortOption.popular,
    this.isLoading = false,
    this.selectedExamFilter,
  });

  BundleListState copyWith({
    List<Bundle>? allBundles,
    List<Bundle>? filtered,
    String? searchQuery,
    BundleCategory? selectedCategory,
    SortOption? sortOption,
    bool? isLoading,
    Object? selectedExamFilter = _sentinel,
  }) =>
      BundleListState(
        allBundles: allBundles ?? this.allBundles,
        filtered: filtered ?? this.filtered,
        searchQuery: searchQuery ?? this.searchQuery,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        sortOption: sortOption ?? this.sortOption,
        isLoading: isLoading ?? this.isLoading,
        selectedExamFilter: selectedExamFilter == _sentinel
            ? this.selectedExamFilter
            : selectedExamFilter as String?,
      );

  static const _sentinel = Object();
}

// ─── Notifier ─────────────────────────────────────────────────────────────────
class BundleListNotifier extends Notifier<BundleListState> {
  @override
  BundleListState build() {
    final all = BundleData.all;
    return BundleListState(allBundles: all, filtered: all);
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  // ── Category filter ────────────────────────────────────────────────────────
  void setCategory(BundleCategory cat) {
    state = state.copyWith(selectedCategory: cat);
    _applyFilters();
  }

  // ── Exam filter (SSC, UPSC, etc.) ─────────────────────────────────────────
  void setExamFilter(String? exam) {
    state = state.copyWith(selectedExamFilter: exam);
    _applyFilters();
  }

  // ── Sort ───────────────────────────────────────────────────────────────────
  void setSort(SortOption sort) {
    state = state.copyWith(sortOption: sort);
    _applyFilters();
  }

  // ── Clear all filters ──────────────────────────────────────────────────────
  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      selectedCategory: BundleCategory.all,
      selectedExamFilter: null,
      sortOption: SortOption.popular,
      filtered: state.allBundles,
    );
  }

  // ── Core filter + sort logic ───────────────────────────────────────────────
  void _applyFilters() {
    var result = state.allBundles.toList();

    // Search
    final q = state.searchQuery.toLowerCase().trim();
    if (q.isNotEmpty) {
      result = result.where((b) =>
      b.title.toLowerCase().contains(q) ||
          b.subtitle.toLowerCase().contains(q) ||
          b.examTag.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q)).toList();
    }

    // Category
    if (state.selectedCategory != BundleCategory.all) {
      final catLabel = state.selectedCategory.label;
      result = result.where((b) => b.category == catLabel).toList();
    }

    // Exam filter
    if (state.selectedExamFilter != null) {
      result = result.where((b) => b.examTag == state.selectedExamFilter).toList();
    }

    // Sort
    switch (state.sortOption) {
      case SortOption.popular:
        result.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      case SortOption.priceLow:
        result.sort((a, b) => a.price.compareTo(b.price));
      case SortOption.priceHigh:
        result.sort((a, b) => b.price.compareTo(a.price));
      case SortOption.newest:
        result = result.where((b) => b.isNew).toList() +
            result.where((b) => !b.isNew).toList();
      case SortOption.rating:
        result.sort((a, b) => b.rating.compareTo(a.rating));
    }

    state = state.copyWith(filtered: result);
  }

  // ── Simulate purchase ──────────────────────────────────────────────────────
  void markPurchased(String bundleId) {
    final updated = state.allBundles.map((b) =>
    b.id == bundleId ? Bundle(
      id: b.id, title: b.title, subtitle: b.subtitle,
      examTag: b.examTag, category: b.category, price: b.price,
      originalPrice: b.originalPrice, isPurchased: true, isFree: b.isFree,
      imageAsset: b.imageAsset, questionCount: b.questionCount,
      pdfPageCount: b.pdfPageCount, rating: b.rating, reviewCount: b.reviewCount,
      duration: b.duration, isNew: b.isNew, isBestseller: b.isBestseller,
    ) : b).toList();
    state = state.copyWith(allBundles: updated);
    _applyFilters();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final bundleListProvider =
NotifierProvider<BundleListNotifier, BundleListState>(BundleListNotifier.new);

// Unique exam tags derived from data
final examTagsProvider = Provider<List<String>>((ref) {
  final all = BundleData.all;
  final tags = all.map((b) => b.examTag).toSet().toList();
  tags.sort();
  return tags;
});