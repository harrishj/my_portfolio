class ProjectData {
  final String id;
  final String title;
  final String description;
  final List<String> techUsed;
  final List<String> platforms;
  final String githubUrl;
  final String? demoUrl;
  final String? imageUrl;
  final String? videoUrl;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final int? orderIndex;

  const ProjectData({
    required this.id,
    required this.title,
    required this.description,
    required this.techUsed,
    required this.platforms,
    required this.githubUrl,
    this.demoUrl,
    this.imageUrl,
    this.videoUrl,
    this.playStoreUrl,
    this.appStoreUrl,
    this.orderIndex,
  });

  factory ProjectData.fromJson(Map<String, dynamic> json) {
    return ProjectData(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      techUsed: List<String>.from(json['tech_used'] ?? json['techUsed'] ?? []),
      platforms: List<String>.from(json['platforms'] ?? []),
      githubUrl: json['github_url'] ?? json['githubUrl'] ?? '',
      demoUrl: json['demo_url'] ?? json['demoUrl'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      videoUrl: json['video_url'] ?? json['videoUrl'],
      playStoreUrl: json['play_store_url'] ?? json['playStoreUrl'],
      appStoreUrl: json['app_store_url'] ?? json['appStoreUrl'],
      orderIndex: json['order_index'] is int
          ? json['order_index']
          : (json['orderIndex'] is int ? json['orderIndex'] : int.tryParse(json['order_index']?.toString() ?? '')),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'title': title,
      'description': description,
      'tech_used': techUsed,
      'platforms': platforms,
      'github_url': githubUrl,
      'demo_url': demoUrl,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'play_store_url': playStoreUrl,
      'app_store_url': appStoreUrl,
    };
    if (orderIndex != null) {
      map['order_index'] = orderIndex;
    }
    return map;
  }

  ProjectData copyWith({
    String? title,
    String? description,
    List<String>? techUsed,
    List<String>? platforms,
    String? githubUrl,
    String? demoUrl,
    String? imageUrl,
    String? videoUrl,
    String? playStoreUrl,
    String? appStoreUrl,
    int? orderIndex,
  }) {
    return ProjectData(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      techUsed: techUsed ?? this.techUsed,
      platforms: platforms ?? this.platforms,
      githubUrl: githubUrl ?? this.githubUrl,
      demoUrl: demoUrl ?? this.demoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      playStoreUrl: playStoreUrl ?? this.playStoreUrl,
      appStoreUrl: appStoreUrl ?? this.appStoreUrl,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }
}
