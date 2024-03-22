import 'package:trello_app/src/models/member.dart';

class Cards {
  final String id;
  final String name;
  final String? desc;

  Cards({required this.id, required this.name, this.desc});

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
    );
  }

  set members(List<Member> members) {}
}
