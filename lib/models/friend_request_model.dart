class FriendRequest {
  final String fromId;
  final String toId;
  final String status;

  FriendRequest({
    required this.fromId,
    required this.toId,
    this.status = 'pending',
  });

  Map<String, dynamic> toJson() => {
    'fromId': fromId,
    'toId': toId,
    'status': status,
  };

  static FriendRequest fromJson(Map<String, dynamic> json) => FriendRequest(
    fromId: json['fromId'],
    toId: json['toId'],
    status: json['status'],
  );
}
