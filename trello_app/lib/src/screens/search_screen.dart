import 'package:flutter/material.dart';
import 'package:trello_app/src/screens/account_screen.dart';
import 'package:trello_app/src/screens/boards_screen.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Search Screen'),
      ),
    );
  }
}