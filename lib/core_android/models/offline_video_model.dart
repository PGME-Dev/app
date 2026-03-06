class OfflineVideoModel {
  final String videoId;
  final String title;
  final String? thumbnailUrl;
  final String facultyName;
  final int durationSeconds;
  final double fileSizeMb;
  final DateTime downloadedAt;
  final String filePath;
  final String? moduleName;
  final String? seriesName;

  OfflineVideoModel({
    required this.videoId,
    required this.title,
    this.thumbnailUrl,
    this.facultyName = '',
    this.durationSeconds = 0,
    this.fileSizeMb = 0,
    required this.downloadedAt,
    required this.filePath,
    this.moduleName,
    this.seriesName,
  });

  String get fileName => 'video_$videoId.mp4';

  String get formattedDuration {
    final hours = durationSeconds ~/ 3600;
    final minutes = (durationSeconds % 3600) ~/ 60;
    final seconds = durationSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    }
    return '${seconds}s';
  }

  String get formattedFileSize {
    if (fileSizeMb >= 1024) {
      return '${(fileSizeMb / 1024).toStringAsFixed(1)} GB';
    }
    return '${fileSizeMb.toStringAsFixed(1)} MB';
  }

  Map<String, dynamic> toJson() => {
        'videoId': videoId,
        'title': title,
        'thumbnailUrl': thumbnailUrl,
        'facultyName': facultyName,
        'durationSeconds': durationSeconds,
        'fileSizeMb': fileSizeMb,
        'downloadedAt': downloadedAt.toIso8601String(),
        'filePath': filePath,
        'moduleName': moduleName,
        'seriesName': seriesName,
      };

  factory OfflineVideoModel.fromJson(Map<String, dynamic> json) =>
      OfflineVideoModel(
        videoId: json['videoId'] as String,
        title: json['title'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        facultyName: json['facultyName'] as String? ?? '',
        durationSeconds: json['durationSeconds'] as int? ?? 0,
        fileSizeMb: (json['fileSizeMb'] as num?)?.toDouble() ?? 0,
        downloadedAt: DateTime.parse(json['downloadedAt'] as String),
        filePath: json['filePath'] as String,
        moduleName: json['moduleName'] as String?,
        seriesName: json['seriesName'] as String?,
      );
}
