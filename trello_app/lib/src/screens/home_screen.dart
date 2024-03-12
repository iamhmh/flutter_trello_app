import 'package:flutter/material.dart';
import 'package:trello_app/src/services/trello_auth_service.dart';

class HomeScreen extends StatelessWidget {
    final TrelloAuthService _authService = TrelloAuthService();

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          height: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Log in / Sign up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _authService.authenticate(context), // Utilise authenticate pour la connexion
                child: Text('Log in with email'),
              ),
              ElevatedButton(
                onPressed: () => _authService.authenticate(context), // Réutilise authenticate pour l'inscription
                child: Text('Log in with Google'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff57b51),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center, 
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: SizedBox(
              height: 400,
              width: 400,
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Text(
                    'Just manage your tasks.',
                    style: TextStyle(fontSize: 24, color: Color(0xfff8f3e5)),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => _showBottomSheet(context),
                      child: Text(
                        'Log in',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => _showBottomSheet(context),
                      child: Text(
                        'Sign up',
                        style: TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}