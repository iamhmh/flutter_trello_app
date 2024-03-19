class Lists {
  final String id;
  final String name;

  Lists({required this.id, required this.name});

  factory Lists.fromJson(Map<String, dynamic> json) {
    return Lists(
      id: json['id'],
      name: json['name'],
    );
  }

  get cards => null;
}