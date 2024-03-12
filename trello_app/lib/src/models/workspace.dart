class Workspace {
  final String id;
  final String name;
  final List<String> boardIds;

  Workspace({required this.id, required this.name, required this.boardIds});

  factory Workspace.fromJson(Map<String, dynamic> json) {
    return Workspace(
      id: json['id'],
      name: json['name'],
      boardIds: json['idBoards']?.cast<String>() ?? [], // Handle potential null value
    );
  }
}
