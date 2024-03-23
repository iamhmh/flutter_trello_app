import 'package:trello_app/src/models/member.dart';

class Cards {
  final String id;
  final String name;
  final String? desc;
  List<Member> _members = []; 

  Cards({required this.id, required this.name, this.desc});

  List<Member> get members => _members;

  set members(List<Member> members) {
    _members = members;
  }

  factory Cards.fromJson(Map<String, dynamic> json) {
    return Cards(
      id: json['id'],
      name: json['name'],
      desc: json['desc'],
    );
  }
}