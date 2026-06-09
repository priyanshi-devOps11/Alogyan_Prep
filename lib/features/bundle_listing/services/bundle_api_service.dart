import '../models/bundle_model.dart';

/// Simulates API responses with realistic data.
/// Replace [fetchBundles] body with real HTTP call when backend is ready.
class BundleApiService {
  /// Simulated API call — replace with real endpoint later.
  /// e.g. GET /api/v1/bundles
  Future<List<BundleModel>> fetchBundles() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    // This is what a real API response looks like:
    // { "id": "1", "name": "...", "price": 999, "isPurchased": true, ... }
    final List<Map<String, dynamic>> mockResponse = [
      {
        'id': '1',
        'name': 'SSC CGL Complete Bundle 2024',
        'description': 'Complete SSC CGL preparation with 5000+ questions, mock tests & PDF notes.',
        'price': 499,
        'original_price': 1299,
        'thumbnail': null,
        'courseCount': 24,
        'isPurchased': false,
        'isFree': false,
        'category': 'SSC',
        'rating': 4.8,
        'reviewCount': 2341,
      },
      {
        'id': '2',
        'name': 'UPSC Prelims GS Paper I',
        'description': 'Chapter-wise notes, 2000 MCQs & mind maps for UPSC Prelims.',
        'price': 799,
        'original_price': 1999,
        'thumbnail': null,
        'courseCount': 18,
        'isPurchased': true,
        'isFree': false,
        'category': 'UPSC',
        'rating': 4.9,
        'reviewCount': 1876,
      },
      {
        'id': '3',
        'name': 'Banking PO Free Starter Kit',
        'description': 'Free demo bundle — 100 questions + 5 mock tests to kickstart prep.',
        'price': 0,
        'thumbnail': null,
        'courseCount': 5,
        'isPurchased': false,
        'isFree': true,
        'category': 'Banking',
        'rating': 4.3,
        'reviewCount': 4200,
      },
      {
        'id': '4',
        'name': 'Railway NTPC Complete 2024',
        'description': 'Topic-wise tests + Previous Year Papers for RRB NTPC.',
        'price': 299,
        'original_price': 799,
        'thumbnail': null,
        'courseCount': 15,
        'isPurchased': false,
        'isFree': false,
        'category': 'Railway',
        'rating': 4.6,
        'reviewCount': 3102,
      },
      {
        'id': '5',
        'name': 'NEET Biology Master Notes',
        'description': 'Complete NCERT + extra questions for NEET Biology preparation.',
        'price': 599,
        'original_price': 1199,
        'thumbnail': null,
        'courseCount': 12,
        'isPurchased': true,
        'isFree': false,
        'category': 'NEET',
        'rating': 4.7,
        'reviewCount': 988,
      },
      {
        'id': '6',
        'name': 'JEE Maths Formula Bundle',
        'description': 'All formulas + 1500 solved problems for JEE Maths.',
        'price': 349,
        'original_price': 699,
        'thumbnail': null,
        'courseCount': 10,
        'isPurchased': false,
        'isFree': false,
        'category': 'JEE',
        'rating': 4.6,
        'reviewCount': 445,
      },
      {
        'id': '7',
        'name': 'UPSC Current Affairs 2024',
        'description': 'Monthly current affairs magazine + MCQs for UPSC aspirants.',
        'price': 199,
        'thumbnail': null,
        'courseCount': 8,
        'isPurchased': false,
        'isFree': false,
        'category': 'UPSC',
        'rating': 4.5,
        'reviewCount': 721,
      },
      {
        'id': '8',
        'name': 'SSC Free Starter Pack',
        'description': 'Try before you buy — free SSC starter with 200 questions.',
        'price': 0,
        'thumbnail': null,
        'courseCount': 3,
        'isPurchased': false,
        'isFree': true,
        'category': 'SSC',
        'rating': 4.2,
        'reviewCount': 5630,
      },
    ];

    return mockResponse.map((json) => BundleModel.fromJson(json)).toList();
  }
}