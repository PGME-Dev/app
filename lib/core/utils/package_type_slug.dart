/// Stable package-type identity.
///
/// `PackageType.name` on the server is free text an admin can rename at any
/// time, and the app used to compare it directly in a dozen places. Renaming
/// "Combo" to "Combos" in the admin panel silently hid every combo package —
/// no error, just an empty list.
///
/// The backend now serves `package_type_slug` alongside the display name.
/// Everything in the app should key off that, via this helper.
library;

class PackageTypeSlug {
  PackageTypeSlug._();

  static const String theory = 'theory';
  static const String practical = 'practical';
  static const String combo = 'combo';

  /// Mirrors the server's slugify: lowercase, non-alphanumerics to hyphens,
  /// and a trailing plural "s" dropped so "Combos" and "Combo" both give
  /// "combo".
  ///
  /// Used as a fallback when the backend predates `package_type_slug`, so the
  /// app behaves correctly against an older server too.
  static String? derive(String? name) {
    if (name == null) return null;
    final base = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (base.isEmpty) return null;
    final singular = base.replaceAll(RegExp(r's$'), '');
    return singular.isEmpty ? base : singular;
  }

  /// The slug to use for a package type, preferring the server's value and
  /// falling back to one derived from the display name.
  static String? resolve({String? slug, String? name}) {
    final s = slug?.trim().toLowerCase();
    if (s != null && s.isNotEmpty) return s;
    return derive(name);
  }

  /// Whether a package type is [expected], tolerating a missing server slug,
  /// casing, and singular/plural naming.
  static bool matches({
    String? slug,
    String? name,
    required String expected,
  }) {
    return resolve(slug: slug, name: name) == expected;
  }
}
