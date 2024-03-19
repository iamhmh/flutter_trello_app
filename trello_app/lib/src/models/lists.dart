import 'package:trello_app/src/models/card.dart';

class Lists {
  final String id;
  final String name;
  List<Cards> cards;

  Lists({required this.id, required this.name, List<Cards>? cards})
      : cards = cards ?? [];

  factory Lists.fromJson(Map<String, dynamic> json) {
    var cardsList = json['cards'] as List? ?? [];
    List<Cards> cards = cardsList.map((cardJson) => Cards.fromJson(cardJson)).toList();

    return Lists(
      id: json['id'],
      name: json['name'],
      cards: cards,
    );
  }
}