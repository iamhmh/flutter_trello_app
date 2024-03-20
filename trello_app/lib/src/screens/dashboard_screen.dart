import 'package:flutter/material.dart';
import 'package:trello_app/src/components/custom_navigation_bar.dart';
import 'package:trello_app/src/components/custom_app_bar.dart';
import 'package:trello_app/src/screens/account_screen.dart';
import 'package:trello_app/src/screens/alerts_screen.dart';
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
        AlertsScreen(),
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
      "<username>";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffceee7),
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
            "Hi, $userName",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Start by creating your workspace and boards.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/create-workspace');
            },
            child: Text(
              "Create your first workspace",
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
