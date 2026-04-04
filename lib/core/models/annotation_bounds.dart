import 'dart:ui';

/// Platform-agnostic representation of a text line's bounds.
/// Used for serialization to/from the backend and shared between
/// Syncfusion and pdfrx PDF viewer implementations.
class AnnotationTextBounds {
  final double left;
  final double top;
  final double width;
  final double height;
  final String text;
  final int pageNumber;

  const AnnotationTextBounds({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
    required this.text,
    required this.pageNumber,
  });

  Rect toRect() => Rect.fromLTWH(left, top, width, height);

  Map<String, dynamic> toJson() => {
        'left': left,
        'top': top,
        'width': width,
        'height': height,
        'text': text,
        'page_number': pageNumber,
      };

  factory AnnotationTextBounds.fromJson(Map<String, dynamic> json) {
    return AnnotationTextBounds(
      left: (json['left'] as num).toDouble(),
      top: (json['top'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      text: json['text'] as String? ?? '',
      pageNumber: (json['page_number'] as num).toInt(),
    );
  }
}
