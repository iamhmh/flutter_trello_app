import 'package:flutter/material.dart';
import 'package:trello_app/src/components/custom_navigation_bar.dart';
import 'package:trello_app/src/components/custom_app_bar.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    Center(child: Text('Page d\'accueil')),
    Center(child: Text('Mes tableaux')),
    Center(child: Text('Recherchez')),
    Center(child: Text('Notifications')),
    Center(child: Text('Compte')),
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
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}