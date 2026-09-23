class StreamProfile {
  final String id;
  final String name;
  final String rtmpUrl;
  final String streamKey;
  final int targetBitrate; // kbps
  final int width;
  final int height;
  final int fps;
  final String? preferredCameraId; // null = auto
  final List<String> overlayPresetIds;

  const StreamProfile({
    required this.id,
    required this.name,
    required this.rtmpUrl,
    required this.streamKey,
    this.targetBitrate = 2500,
    this.width = 1280,
    this.height = 720,
    this.fps = 30,
    this.preferredCameraId,
    this.overlayPresetIds = const [],
  });

  String get fullUrl {
    if (rtmpUrl.endsWith('/')) {
      return '$rtmpUrl$streamKey';
    }
    return '$rtmpUrl/$streamKey';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'rtmpUrl': rtmpUrl,
        'streamKey': streamKey,
        'targetBitrate': targetBitrate,
        'width': width,
        'height': height,
        'fps': fps,
        'preferredCameraId': preferredCameraId,
        'overlayPresetIds': overlayPresetIds,
      };

  factory StreamProfile.fromJson(Map<String, dynamic> json) {
    return StreamProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      rtmpUrl: json['rtmpUrl'] as String,
      streamKey: json['streamKey'] as String,
      targetBitrate: json['targetBitrate'] as int? ?? 2500,
      width: json['width'] as int? ?? 1280,
      height: json['height'] as int? ?? 720,
      fps: json['fps'] as int? ?? 30,
      preferredCameraId: json['preferredCameraId'] as String?,
      overlayPresetIds: (json['overlayPresetIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  StreamProfile copyWith({
    String? name,
    String? rtmpUrl,
    String? streamKey,
    int? targetBitrate,
    int? width,
    int? height,
    int? fps,
    String? preferredCameraId,
    List<String>? overlayPresetIds,
  }) {
    return StreamProfile(
      id: id,
      name: name ?? this.name,
      rtmpUrl: rtmpUrl ?? this.rtmpUrl,
      streamKey: streamKey ?? this.streamKey,
      targetBitrate: targetBitrate ?? this.targetBitrate,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      preferredCameraId: preferredCameraId ?? this.preferredCameraId,
      overlayPresetIds: overlayPresetIds ?? this.overlayPresetIds,
    );
  }
}
