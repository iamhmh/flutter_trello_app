import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 200,
          child: Center(
            child: Text('Bottom Sheet Content'),
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
        mainAxisAlignment: MainAxisAlignment.center, // Ajouté pour centrer verticalement dans Column
        children: [
          Padding( // Modifié pour ajouter le Padding ici
            padding: const EdgeInsets.only(top: 50), // Ajustez selon le margin souhaité
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
                    'Gère tes tâches, tout simplement.',
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
                        'Connexion',
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
                        'Inscription',
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
