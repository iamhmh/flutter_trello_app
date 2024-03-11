import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trello_app/src/screens/dashboard_screen.dart';

class TrelloAuthService {
  final String apiKey = 'c8065529ba56e9faab113d66aa08f125';
  final String apiToken = 'ATTA6ef834aefb97099d26bad00726dc39988d63d5d925f2765d5a8a8a247f1bf4568951EBD6';

  Future<void> authenticate(BuildContext context) async {
    var url = Uri.parse('https://api.trello.com/1/members/me/boards?key=$apiKey&token=$apiToken');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      final snackBar = SnackBar(content: Text('Erreur d\'authentification'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}