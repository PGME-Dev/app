import 'package:json_annotation/json_annotation.dart';

part 'ebook_access_model.g.dart';

@JsonSerializable()
class EbookAccessModel {
  @JsonKey(name: 'purchase_id')
  final String purchaseId;

  @JsonKey(name: 'book_id')
  final String bookId;

  final String title;
  final String? author;
  final String? description;

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;

  @JsonKey(name: 'ebook_file_format')
  final String? ebookFileFormat;

  @JsonKey(name: 'ebook_file_size_mb')
  final double? ebookFileSizeMb;

  final int? pages;

  @JsonKey(name: 'purchased_at')
  final String? purchasedAt;

  EbookAccessModel({
    required this.purchaseId,
    required this.bookId,
    required this.title,
    this.author,
    this.description,
    this.thumbnailUrl,
    this.ebookFileFormat,
    this.ebookFileSizeMb,
    this.pages,
    this.purchasedAt,
  });

  factory EbookAccessModel.fromJson(Map<String, dynamic> json) =>
      _$EbookAccessModelFromJson(json);

  Map<String, dynamic> toJson() => _$EbookAccessModelToJson(this);

  String get formattedFileSize {
    if (ebookFileSizeMb == null) return 'N/A';
    if (ebookFileSizeMb! < 1) {
      return '${(ebookFileSizeMb! * 1024).toStringAsFixed(0)} KB';
    }
    return '${ebookFileSizeMb!.toStringAsFixed(1)} MB';
  }

  String get fileExtension {
    return (ebookFileFormat ?? 'pdf').toUpperCase();
  }

  String get pageCountText {
    if (pages == null) return 'N/A';
    return '$pages ${pages == 1 ? 'Page' : 'Pages'}';
  }

  String get formattedPurchasedDate {
    if (purchasedAt == null) return '';
    try {
      final dateTime = DateTime.parse(purchasedAt!);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
    } catch (e) {
      return purchasedAt!;
    }
  }
}
