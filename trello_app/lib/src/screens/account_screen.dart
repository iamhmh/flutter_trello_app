import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trello_app/src/screens/home_screen.dart';

class AccountScreen extends StatelessWidget {
  final storage = FlutterSecureStorage();

  void logout(BuildContext context) async {
    await storage.delete(key: 'authToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xfff57b51), 
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                        "assets/images/utilisateur.png"),
                    backgroundColor: Colors.transparent,
                ),
                SizedBox(height: 10),
                Text('Nom d\'utilisateur', style: TextStyle(fontSize: 20, color: Colors.white)),
                Text('email@example.com', style: TextStyle(fontSize: 15, color: Colors.white70)),
              ],
            ),
          ),
          // Liste d'onglets
          Text('Compte', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
          SizedBox(height: 5),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Déconnexion'),
            onTap: () => logout(context),
          ),
        ],
      ),
    );
  }
}