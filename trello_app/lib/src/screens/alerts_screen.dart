import 'package:flutter/material.dart';

class AlertsScreen extends StatefulWidget {
  @override
  _AlertsScreenState createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xfffceee7),
      child: Center(
        child: Text('Alerts Screen'),
      ),
    );
  }
}