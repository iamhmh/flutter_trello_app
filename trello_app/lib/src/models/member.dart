class Member {
  final String id;
  final String fullName;
  final String username;
  final String? email;
  String avatarUrl;

  Member({
    required this.id,
    required this.fullName,
    required this.username,
    this.email,
    required this.avatarUrl,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'],
      fullName: json['fullName'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatarUrl'] ?? "",
    );
  }

  get avatarHash => null;
}
