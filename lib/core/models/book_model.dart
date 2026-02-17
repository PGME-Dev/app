import 'package:json_annotation/json_annotation.dart';

part 'book_model.g.dart';

@JsonSerializable()
class BookModel {
  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final String author;
  final String? description;
  final int price;

  @JsonKey(name: 'original_price')
  final int? originalPrice;

  @JsonKey(name: 'is_on_sale', defaultValue: false)
  final bool isOnSale;

  @JsonKey(name: 'sale_price')
  final int? salePrice;

  @JsonKey(name: 'effective_price')
  final int? effectivePrice;

  @JsonKey(name: 'discount_percentage')
  final int? discountPercentage;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  final List<String>? images;
  final String? category;

  @JsonKey(name: 'stock_quantity', defaultValue: 0)
  final int stockQuantity;

  @JsonKey(name: 'is_available', defaultValue: true)
  final bool isAvailable;

  @JsonKey(name: 'in_stock', defaultValue: true)
  final bool inStock;

  final String? isbn;

  @JsonKey(name: 'weight_grams')
  final int? weightGrams;

  final String? publisher;

  @JsonKey(name: 'publication_year')
  final int? publicationYear;

  final int? pages;

  final BookSubject? subject;

  @JsonKey(name: 'ebook', defaultValue: false)
  final bool ebook;

  @JsonKey(name: 'ebook_file_format')
  final String? ebookFileFormat;

  @JsonKey(name: 'ebook_file_size_mb')
  final double? ebookFileSizeMb;

  BookModel({
    required this.bookId,
    required this.title,
    required this.author,
    this.description,
    required this.price,
    this.originalPrice,
    this.isOnSale = false,
    this.salePrice,
    this.effectivePrice,
    this.discountPercentage,
    this.thumbnailUrl,
    this.images,
    this.category,
    this.stockQuantity = 0,
    this.isAvailable = true,
    this.inStock = true,
    this.isbn,
    this.weightGrams,
    this.publisher,
    this.publicationYear,
    this.pages,
    this.subject,
    this.ebook = false,
    this.ebookFileFormat,
    this.ebookFileSizeMb,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) =>
      _$BookModelFromJson(json);

  Map<String, dynamic> toJson() => _$BookModelToJson(this);

  /// Get the actual price to charge (sale price if on sale, otherwise regular price)
  int get actualPrice {
    if (effectivePrice != null) return effectivePrice!;
    if (isOnSale && salePrice != null) return salePrice!;
    return price;
  }

  /// Get discount percentage
  int get discount {
    if (discountPercentage != null) return discountPercentage!;
    if (originalPrice != null && originalPrice! > actualPrice) {
      return ((originalPrice! - actualPrice) * 100 / originalPrice!).round();
    }
    return 0;
  }

  /// Check if book has a discount
  bool get hasDiscount => discount > 0;

  BookModel copyWith({
    String? bookId,
    String? title,
    String? author,
    String? description,
    int? price,
    int? originalPrice,
    bool? isOnSale,
    int? salePrice,
    int? effectivePrice,
    int? discountPercentage,
    String? thumbnailUrl,
    List<String>? images,
    String? category,
    int? stockQuantity,
    bool? isAvailable,
    bool? inStock,
    String? isbn,
    int? weightGrams,
    String? publisher,
    int? publicationYear,
    int? pages,
    BookSubject? subject,
    bool? ebook,
    String? ebookFileFormat,
    double? ebookFileSizeMb,
  }) {
    return BookModel(
      bookId: bookId ?? this.bookId,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      isOnSale: isOnSale ?? this.isOnSale,
      salePrice: salePrice ?? this.salePrice,
      effectivePrice: effectivePrice ?? this.effectivePrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      images: images ?? this.images,
      category: category ?? this.category,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isAvailable: isAvailable ?? this.isAvailable,
      inStock: inStock ?? this.inStock,
      isbn: isbn ?? this.isbn,
      weightGrams: weightGrams ?? this.weightGrams,
      publisher: publisher ?? this.publisher,
      publicationYear: publicationYear ?? this.publicationYear,
      pages: pages ?? this.pages,
      subject: subject ?? this.subject,
      ebook: ebook ?? this.ebook,
      ebookFileFormat: ebookFileFormat ?? this.ebookFileFormat,
      ebookFileSizeMb: ebookFileSizeMb ?? this.ebookFileSizeMb,
    );
  }
}

@JsonSerializable()
class BookSubject {
  @JsonKey(name: 'subject_id')
  final String subjectId;

  final String name;

  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  BookSubject({
    required this.subjectId,
    required this.name,
    this.iconUrl,
  });

  factory BookSubject.fromJson(Map<String, dynamic> json) =>
      _$BookSubjectFromJson(json);

  Map<String, dynamic> toJson() => _$BookSubjectToJson(this);
}

@JsonSerializable()
class BooksResponse {
  final List<BookModel> books;
  final PaginationInfo pagination;

  BooksResponse({
    required this.books,
    required this.pagination,
  });

  factory BooksResponse.fromJson(Map<String, dynamic> json) =>
      _$BooksResponseFromJson(json);

  Map<String, dynamic> toJson() => _$BooksResponseToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  @JsonKey(name: 'current_page')
  final int currentPage;

  @JsonKey(name: 'total_pages')
  final int totalPages;

  @JsonKey(name: 'total_items')
  final int totalItems;

  @JsonKey(name: 'items_per_page')
  final int itemsPerPage;

  @JsonKey(name: 'has_next')
  final bool hasNext;

  @JsonKey(name: 'has_prev')
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);

  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}
