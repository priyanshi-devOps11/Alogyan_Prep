/// Bundle domain model — only user-facing fields, no backend metadata.
class BundleModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String? thumbnailUrl;
  final int courseCount;
  final bool isPurchased;
  final bool isFree;
  final double? originalPrice;
  final String? category;
  final double rating;
  final int reviewCount;

  const BundleModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.thumbnailUrl,
    this.courseCount = 0,
    this.isPurchased = false,
    this.isFree = false,
    this.originalPrice,
    this.category,
    this.rating = 4.5,
    this.reviewCount = 0,
  });

  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price && price > 0;
  int get discountPercent =>
      hasDiscount ? ((1 - price / originalPrice!) * 100).round() : 0;

  /// Parse from API JSON response
  factory BundleModel.fromJson(Map<String, dynamic> json) => BundleModel(
    id: json['id']?.toString() ?? '',
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    price: (json['price'] ?? 0).toDouble(),
    thumbnailUrl: json['thumbnail'],
    courseCount: json['course_count'] ?? json['courseCount'] ?? 0,
    isPurchased: json['isPurchased'] ?? json['is_purchased'] ?? false,
    isFree: (json['price'] ?? 0) == 0,
    originalPrice: json['original_price'] != null
        ? (json['original_price']).toDouble()
        : null,
    category: json['category'],
    rating: (json['rating'] ?? 4.5).toDouble(),
    reviewCount: json['review_count'] ?? json['reviewCount'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price,
    'thumbnail': thumbnailUrl,
    'courseCount': courseCount,
    'isPurchased': isPurchased,
    'originalPrice': originalPrice,
    'category': category,
    'rating': rating,
    'reviewCount': reviewCount,
  };
}

/// Filter options for the bundle listing screen
enum BundleFilter { all, free, paid, purchased }

extension BundleFilterLabel on BundleFilter {
  String get label => switch (this) {
    BundleFilter.all       => 'All',
    BundleFilter.free      => 'Free',
    BundleFilter.paid      => 'Paid',
    BundleFilter.purchased => 'Purchased',
  };
}