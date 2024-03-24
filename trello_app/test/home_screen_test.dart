import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trello_app/src/screens/home_screen.dart';

void main() {
  group('HomeScreen Tests', () {
    testWidgets('Vérifie la présence de texte, d\'images et de boutons', (WidgetTester tester) async {
      // Charge le HomeScreen dans le widget test
      await tester.pumpWidget(MaterialApp(home: HomeScreen()));

      // Vérifie la présence de l'image du logo
      expect(find.byType(Image), findsOneWidget);

      // Vérifie la présence des textes
      expect(find.text('Just manage your tasks.'), findsOneWidget);
      expect(find.text('Log in'), findsWidgets); // findsWidgets car ils peuvent être présents plusieurs fois
      expect(find.text('Sign up'), findsWidgets);

      // Vérifie la présence des boutons
      expect(find.byType(ElevatedButton), findsNWidgets(2));
    });

    // Ajoutez plus de tests ici pour tester d'autres fonctionnalités comme les interactions
  });
}
