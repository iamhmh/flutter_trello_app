import 'package:flutter/material.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:trello_app/src/screens/dashboard_screen.dart';

class TrelloAuthService {
  final String callbackUrlScheme = 'trello-auth-flutter';
  final String authorizeUrl = "https://trello.com/1/authorize";
  final String apiKey = 'c8065529ba56e9faab113d66aa08f125';

  Future<void> authenticate(BuildContext context) async {
    final String callbackUrl = '$callbackUrlScheme://callback';

    try {
      final String authUrl = "$authorizeUrl?expiration=never&name=VotreAppName&scope=read,write&response_type=token&key=$apiKey&callback_method=fragment&return_url=$callbackUrl";
      final result = await FlutterWebAuth.authenticate(url: authUrl, callbackUrlScheme: callbackUrlScheme);
      final token = Uri.parse(result).queryParameters['token'] ?? Uri.parse(result).fragment.split("=")[1];
    
      if (token.isNotEmpty) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
      } else {
        _showError(context, 'Aucun token reçu');
      }
    } catch (e) {
      _showError(context, ' $e');
    }
  }

  void _showError(BuildContext context, String errorMessage) {
    final snackBar = SnackBar(content: Text('Erreur d\'authentification: $errorMessage'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}