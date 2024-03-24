import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:trello_app/src/components/custom_navigation_bar.dart';
import 'package:trello_app/src/components/custom_app_bar.dart';
import 'package:trello_app/src/screens/account_screen.dart';
import 'package:trello_app/src/screens/alerts_screen.dart';
import 'package:trello_app/src/screens/boards_screen.dart';
import 'package:trello_app/src/screens/search_screen.dart';
import 'package:trello_app/src/services/trello_api.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  Member? user;
  bool isLoading = true;

  List<Widget> _widgetOptions() => [
        DashboardContent(
          user: user, 
          onCreateWorkspacePressed: () => navigateToBoardScreen(),
        ),
        BoardScreen(),
        SearchScreen(),
        AlertsScreen(),
        AccountScreen(),
      ];

  void navigateToBoardScreen() {
    setState(() {
      _selectedIndex = 1;
    });
  }


  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

Future<void> _loadUserInfo() async {
    String token = Constants.apiToken;
    try {
      var userInfo = await TrelloApi().getMemberInfo(token);
      setState(() {
        user = userInfo;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user info: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: isLoading
        ? Center(child: CircularProgressIndicator())
        : _widgetOptions().elementAt(_selectedIndex),
      bottomNavigationBar: CustomNavigationBar(
        key: Key('customNavigationBar'),
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final Member? user;
  final VoidCallback onCreateWorkspacePressed;

  DashboardContent({this.user, required this.onCreateWorkspacePressed});

  @override
  Widget build(BuildContext context) {
    ImageProvider<Object> imageProvider;
    if (user?.avatarUrl != null && user!.avatarUrl.isNotEmpty) {
      String modifiedAvatarUrl = "${user!.avatarUrl}/50.png";
      imageProvider = NetworkImage(modifiedAvatarUrl);
    } else {
      imageProvider = AssetImage("assets/images/utilisateur.png");
    }

    return Container(
      color: Color(0xfffceee7),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundImage: imageProvider,
            backgroundColor: Colors.transparent,
            onBackgroundImageError: (exception, stackTrace) {
              print("Failed to load user avatar: $exception");
            },
          ),
          SizedBox(height: 20),
          Text(
            "Hi, ${user?.fullName ?? 'there'}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            "Start by creating your workspace and boards.",
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCreateWorkspacePressed,
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
