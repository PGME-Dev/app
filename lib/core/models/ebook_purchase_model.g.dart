// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ebook_purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EbookPurchaseModel _$EbookPurchaseModelFromJson(Map<String, dynamic> json) =>
    EbookPurchaseModel(
      purchaseId: json['purchase_id'] as String,
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String?,
      description: json['description'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      ebookFileFormat: json['ebook_file_format'] as String?,
      ebookFileSizeMb: (json['ebook_file_size_mb'] as num?)?.toDouble(),
      pages: (json['pages'] as num?)?.toInt(),
      purchasedAt: json['purchased_at'] as String?,
    );

Map<String, dynamic> _$EbookPurchaseModelToJson(EbookPurchaseModel instance) =>
    <String, dynamic>{
      'purchase_id': instance.purchaseId,
      'book_id': instance.bookId,
      'title': instance.title,
      'author': instance.author,
      'description': instance.description,
      'thumbnail_url': instance.thumbnailUrl,
      'ebook_file_format': instance.ebookFileFormat,
      'ebook_file_size_mb': instance.ebookFileSizeMb,
      'pages': instance.pages,
      'purchased_at': instance.purchasedAt,
    };
