class UserModel {
  final String uid;
  final String name;
  final String username;
  final String bio;
  final String profilePicUrl;
  final int friends;
  final List<String> interests;

  UserModel({
    required this.uid,
    required this.name,
    required this.username,
    required this.bio,
    required this.profilePicUrl,
    this.friends = 0,
    required this.interests,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      name: json['name'] ?? '',
      username: json['username'] ?? '',
      bio: json['bio'] ?? '',
      profilePicUrl: json['profilePicUrl'],
      friends: json['friends'] ?? 0,
      interests: List<String>.from(json['interests'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'username': username,
      'bio': bio,
      'profilePicUrl': profilePicUrl,
      'friends': friends,
      'following': friends,
      'interests': interests,
    };
  }
}
