import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:trello_app/src/screens/home_screen.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/services/trello_api.dart';
import 'package:trello_app/src/utils/constants.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final storage = FlutterSecureStorage();
  Member? user;
  bool isLoading = true;

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


  Future<void> logout(BuildContext context) async {
    await storage.delete(key: 'authToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {

    ImageProvider<Object> imageProvider;
    if (user?.avatarUrl != null && user!.avatarUrl.isNotEmpty) {
      String modifiedAvatarUrl = "${user!.avatarUrl}/50.png";
      imageProvider = NetworkImage(modifiedAvatarUrl);
    } else {
      imageProvider = AssetImage("assets/images/utilisateur.png");
    }

    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              color: Color(0xfffceee7),
              child: Column(
                children: [
                  Container(
                    color: Color(0xfff57b51),
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: imageProvider,
                          backgroundColor: Colors.transparent,
                          onBackgroundImageError: (exception, stackTrace) {
                            print("Failed to load user avatar: $exception");
                          },
                        ),
                        SizedBox(height: 10),
                        Text(user?.username ?? 'Username', style: TextStyle(fontSize: 20, color: Colors.white)),
                        Text(user?.email ?? 'email@example.com', style: TextStyle(fontSize: 15, color: Colors.white70)),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Text('Account', style: TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Card(
                    child: ListTile(
                      tileColor: Colors.white,
                      leading: Icon(Icons.logout),
                      title: Text('Log out'),
                      onTap: () => logout(context),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
