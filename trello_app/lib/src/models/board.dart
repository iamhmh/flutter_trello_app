class Board {
  final String id;
  final String name;
  int membersCount; 

  Board({required this.id, required this.name, this.membersCount = 0});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
      membersCount: json['members'] != null ? json['members'].length : 0,
    );
  }

  get members => null;
}