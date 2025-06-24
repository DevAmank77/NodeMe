class HangoutModel {
  final String id;
  final String name;
  final String createdBy;
  final List<String> members;

  HangoutModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.members,
  });

  factory HangoutModel.fromJson(String id, Map<String, dynamic> json) =>
      HangoutModel(
        id: id,
        name: json['name'],
        createdBy: json['createdBy'],
        members: List<String>.from(json['members'] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'name': name,
    'createdBy': createdBy,
    'members': members,
    'createdAt': DateTime.now(),
  };
}
