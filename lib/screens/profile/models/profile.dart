class Profile {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? bio;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.bio,
    this.updatedAt,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
