import 'package:flutter/material.dart';

/// Parses a hex color string (e.g. "#4CAF50", "4CAF50", "#FF4CAF50") into a [Color].
/// Handles both 6-char (RGB) and 8-char (ARGB) hex strings.
/// Returns [fallback] if the string is null, empty, or invalid.
Color parseHexColor(String? hex, {Color fallback = Colors.transparent}) {
  if (hex == null || hex.isEmpty) return fallback;
  String cleaned = hex.replaceAll('#', '');
  if (cleaned.length == 6) {
    cleaned = 'FF$cleaned'; // Add full opacity
  }
  if (cleaned.length != 8) return fallback;
  final value = int.tryParse(cleaned, radix: 16);
  if (value == null) return fallback;
  return Color(value);
}
