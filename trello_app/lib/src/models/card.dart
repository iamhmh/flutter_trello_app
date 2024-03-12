class Card {
  final String id;
  final String name;

  Card({required this.id, required this.name});

  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      name: json['name'],
    );
  }
}