import '../models/bundle_model.dart';
import '../services/bundle_api_service.dart';

/// Repository — sits between controller and API service.
/// Handles error wrapping and local purchase state tracking.
class BundleRepository {
  BundleRepository({BundleApiService? apiService})
      : _api = apiService ?? BundleApiService();

  final BundleApiService _api;

  // Local purchased set — in production, persist via Firestore/SharedPreferences
  final Set<String> _localPurchased = {};

  Future<List<BundleModel>> getBundles() async {
    final bundles = await _api.fetchBundles();
    // Merge locally tracked purchases
    return bundles.map((b) {
      if (_localPurchased.contains(b.id)) {
        return BundleModel(
          id: b.id, name: b.name, description: b.description,
          price: b.price, thumbnailUrl: b.thumbnailUrl,
          courseCount: b.courseCount, isPurchased: true, isFree: b.isFree,
          originalPrice: b.originalPrice, category: b.category,
          rating: b.rating, reviewCount: b.reviewCount,
        );
      }
      return b;
    }).toList();
  }

  void markPurchased(String bundleId) => _localPurchased.add(bundleId);
}