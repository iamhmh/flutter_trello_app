class Board {
  final String id;
  final String name;

  Board({required this.id, required this.name});

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'],
      name: json['name'],
    );
  }
}