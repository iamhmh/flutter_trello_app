import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:trello_app/src/screens/dashboard_screen.dart';
import 'package:trello_app/src/utils/constants.dart';

class TrelloAuthService {

  Future<void> authenticate(BuildContext context) async {
    var url = Uri.parse('https://api.trello.com/1/members/me/boards?key=${Constants.apiKey}&token=${Constants.apiToken}');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      final snackBar = SnackBar(content: Text('Erreur d\'authentification'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}