// ─── Bundle model ─────────────────────────────────────────────────────────────
class Bundle {
  final String id;
  final String title;
  final String subtitle;
  final String examTag;       // SSC, UPSC, NEET etc.
  final String category;      // Mock Tests, PDF Notes, Live, etc.
  final double price;
  final double? originalPrice; // null = free
  final bool isPurchased;
  final bool isFree;
  final String imageAsset;
  final int questionCount;
  final int pdfPageCount;
  final double rating;
  final int reviewCount;
  final String duration;       // "3 months", "60 days" etc.
  final bool isNew;
  final bool isBestseller;

  const Bundle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.examTag,
    required this.category,
    required this.price,
    this.originalPrice,
    this.isPurchased = false,
    this.isFree = false,
    required this.imageAsset,
    this.questionCount = 0,
    this.pdfPageCount = 0,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.duration = '3 months',
    this.isNew = false,
    this.isBestseller = false,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;
  int get discountPercent => hasDiscount
      ? ((1 - price / originalPrice!) * 100).round()
      : 0;
}

// ─── Filter enums ─────────────────────────────────────────────────────────────
enum BundleCategory { all, mockTests, pdfNotes, liveSessions, studyPlan }

extension BundleCategoryExt on BundleCategory {
  String get label => switch (this) {
    BundleCategory.all          => 'All',
    BundleCategory.mockTests    => 'Mock Tests',
    BundleCategory.pdfNotes     => 'PDF Notes',
    BundleCategory.liveSessions => 'Live Sessions',
    BundleCategory.studyPlan    => 'Study Plan',
  };
  String get emoji => switch (this) {
    BundleCategory.all          => '🔥',
    BundleCategory.mockTests    => '📊',
    BundleCategory.pdfNotes     => '📄',
    BundleCategory.liveSessions => '📡',
    BundleCategory.studyPlan    => '📅',
  };
}

enum SortOption { popular, priceLow, priceHigh, newest, rating }

extension SortOptionExt on SortOption {
  String get label => switch (this) {
    SortOption.popular   => 'Most Popular',
    SortOption.priceLow  => 'Price: Low to High',
    SortOption.priceHigh => 'Price: High to Low',
    SortOption.newest    => 'Newest First',
    SortOption.rating    => 'Top Rated',
  };
}

// ─── Static bundle data (replace with Firestore fetch in production) ──────────
abstract class BundleData {
  static final List<Bundle> all = [
    const Bundle(
      id: 'ssc_mega_2024',
      title: 'SSC CGL Mega Bundle 2024',
      subtitle: 'Complete preparation package with 5000+ questions',
      examTag: 'SSC',
      category: 'Mock Tests',
      price: 499,
      originalPrice: 1299,
      imageAsset: 'assets/images/bundle_ssc.png',
      questionCount: 5000,
      duration: '6 months',
      rating: 4.8,
      reviewCount: 2341,
      isBestseller: true,
    ),
    const Bundle(
      id: 'upsc_prelims',
      title: 'UPSC Prelims GS Paper I',
      subtitle: 'Chapter-wise notes + 2000 MCQs',
      examTag: 'UPSC',
      category: 'PDF Notes',
      price: 799,
      originalPrice: 1999,
      imageAsset: 'assets/images/bundle_upsc.png',
      pdfPageCount: 480,
      questionCount: 2000,
      duration: '12 months',
      rating: 4.9,
      reviewCount: 1876,
      isBestseller: true,
    ),
    const Bundle(
      id: 'banking_po_free',
      title: 'Banking PO Free Starter',
      subtitle: 'Free demo — 100 questions + 5 mock tests',
      examTag: 'Banking',
      category: 'Mock Tests',
      price: 0,
      imageAsset: 'assets/images/bundle_banking.png',
      questionCount: 100,
      isFree: true,
      rating: 4.3,
      reviewCount: 4200,
      isNew: false,
    ),
    const Bundle(
      id: 'railway_ntpc',
      title: 'Railway NTPC Complete 2024',
      subtitle: 'Topic-wise tests + Previous Year Papers',
      examTag: 'Railway',
      category: 'Mock Tests',
      price: 299,
      originalPrice: 799,
      imageAsset: 'assets/images/bundle_railway.png',
      questionCount: 3500,
      duration: '4 months',
      rating: 4.6,
      reviewCount: 3102,
      isNew: true,
    ),
    const Bundle(
      id: 'neet_biology',
      title: 'NEET Biology Master Notes',
      subtitle: 'Complete NCERT + Extra questions',
      examTag: 'NEET',
      category: 'PDF Notes',
      price: 599,
      originalPrice: 1199,
      imageAsset: 'assets/images/bundle_neet.png',
      pdfPageCount: 620,
      duration: '12 months',
      rating: 4.7,
      reviewCount: 988,
      isPurchased: true,
    ),
    const Bundle(
      id: 'ssc_live',
      title: 'SSC CGL Live Batch 2024',
      subtitle: 'Live classes with India\'s top educators',
      examTag: 'SSC',
      category: 'Live Sessions',
      price: 1999,
      originalPrice: 4999,
      imageAsset: 'assets/images/bundle_live.png',
      duration: '6 months',
      rating: 4.9,
      reviewCount: 567,
      isNew: true,
    ),
    const Bundle(
      id: 'upsc_current',
      title: 'UPSC Current Affairs 2024',
      subtitle: 'Monthly magazine + MCQs + Mind Maps',
      examTag: 'UPSC',
      category: 'PDF Notes',
      price: 199,
      imageAsset: 'assets/images/bundle_current.png',
      pdfPageCount: 240,
      rating: 4.5,
      reviewCount: 721,
    ),
    const Bundle(
      id: 'jee_maths',
      title: 'JEE Maths Formula Book',
      subtitle: 'All formulas + 1500 problems with solutions',
      examTag: 'JEE',
      category: 'PDF Notes',
      price: 349,
      originalPrice: 699,
      imageAsset: 'assets/images/bundle_jee.png',
      pdfPageCount: 380,
      questionCount: 1500,
      duration: '12 months',
      rating: 4.6,
      reviewCount: 445,
      isNew: true,
    ),
  ];
}