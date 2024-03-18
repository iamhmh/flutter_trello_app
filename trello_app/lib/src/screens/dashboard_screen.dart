import 'package:flutter/material.dart';
import 'package:trello_app/src/components/custom_navigation_bar.dart';
import 'package:trello_app/src/components/custom_app_bar.dart';
import 'package:trello_app/src/screens/account_screen.dart';
import 'package:trello_app/src/screens/boards_screen.dart';
import 'package:trello_app/src/screens/search_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  List<Widget> _widgetOptions() => [
        DashboardContent(),
        BoardScreen(),
        SearchScreen(),
        Center(child: Text('Notifications')),
        AccountScreen(),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final String userName =
      "<nom>"; // Adapte cette partie selon ton cas d'utilisation

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200], // Couleur de fond
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            backgroundImage: AssetImage(
                "assets/images/utilisateur.png"), // Adapte avec l'image de l'utilisateur
            radius: 50,
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 20),
          Text(
            "Bonjour, $userName",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Commencez par créer votre workspace et vos boards.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Implémente la logique de création de tableau ici
            },
            child: Text(
              "Créer votre premier workspace",
              style: TextStyle(fontSize: 12, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xfff57b51),
            ),
          ),
        ],
      ),
    );
  }
}
