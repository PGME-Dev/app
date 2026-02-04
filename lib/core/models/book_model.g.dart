// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookModel _$BookModelFromJson(Map<String, dynamic> json) => BookModel(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      description: json['description'] as String?,
      price: (json['price'] as num).toInt(),
      originalPrice: (json['original_price'] as num?)?.toInt(),
      isOnSale: json['is_on_sale'] as bool? ?? false,
      salePrice: (json['sale_price'] as num?)?.toInt(),
      effectivePrice: (json['effective_price'] as num?)?.toInt(),
      discountPercentage: (json['discount_percentage'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      images:
          (json['images'] as List<dynamic>?)?.map((e) => e as String).toList(),
      category: json['category'] as String?,
      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
      isAvailable: json['is_available'] as bool? ?? true,
      inStock: json['in_stock'] as bool? ?? true,
      isbn: json['isbn'] as String?,
      weightGrams: (json['weight_grams'] as num?)?.toInt(),
      publisher: json['publisher'] as String?,
      publicationYear: (json['publication_year'] as num?)?.toInt(),
      pages: (json['pages'] as num?)?.toInt(),
      subject: json['subject'] == null
          ? null
          : BookSubject.fromJson(json['subject'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BookModelToJson(BookModel instance) => <String, dynamic>{
      'book_id': instance.bookId,
      'title': instance.title,
      'author': instance.author,
      'description': instance.description,
      'price': instance.price,
      'original_price': instance.originalPrice,
      'is_on_sale': instance.isOnSale,
      'sale_price': instance.salePrice,
      'effective_price': instance.effectivePrice,
      'discount_percentage': instance.discountPercentage,
      'thumbnail_url': instance.thumbnailUrl,
      'images': instance.images,
      'category': instance.category,
      'stock_quantity': instance.stockQuantity,
      'is_available': instance.isAvailable,
      'in_stock': instance.inStock,
      'isbn': instance.isbn,
      'weight_grams': instance.weightGrams,
      'publisher': instance.publisher,
      'publication_year': instance.publicationYear,
      'pages': instance.pages,
      'subject': instance.subject,
    };

BookSubject _$BookSubjectFromJson(Map<String, dynamic> json) => BookSubject(
      subjectId: json['subject_id'] as String,
      name: json['name'] as String,
      iconUrl: json['icon_url'] as String?,
    );

Map<String, dynamic> _$BookSubjectToJson(BookSubject instance) =>
    <String, dynamic>{
      'subject_id': instance.subjectId,
      'name': instance.name,
      'icon_url': instance.iconUrl,
    };

BooksResponse _$BooksResponseFromJson(Map<String, dynamic> json) =>
    BooksResponse(
      books: (json['books'] as List<dynamic>)
          .map((e) => BookModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          PaginationInfo.fromJson(json['pagination'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$BooksResponseToJson(BooksResponse instance) =>
    <String, dynamic>{
      'books': instance.books,
      'pagination': instance.pagination,
    };

PaginationInfo _$PaginationInfoFromJson(Map<String, dynamic> json) =>
    PaginationInfo(
      currentPage: (json['current_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalItems: (json['total_items'] as num).toInt(),
      itemsPerPage: (json['items_per_page'] as num).toInt(),
      hasNext: json['has_next'] as bool,
      hasPrev: json['has_prev'] as bool,
    );

Map<String, dynamic> _$PaginationInfoToJson(PaginationInfo instance) =>
    <String, dynamic>{
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'total_items': instance.totalItems,
      'items_per_page': instance.itemsPerPage,
      'has_next': instance.hasNext,
      'has_prev': instance.hasPrev,
    };
