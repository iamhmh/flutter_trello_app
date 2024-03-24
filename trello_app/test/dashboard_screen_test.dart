import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trello_app/src/screens/dashboard_screen.dart';
import 'package:trello_app/src/services/trello_api.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:trello_app/src/screens/search_screen.dart';

class MockTrelloApi extends Mock implements TrelloApi {}

void main() {
  // Création d'un mock pour TrelloApi
  final mockTrelloApi = MockTrelloApi();


  // Fonction utilitaire pour charger le DashboardScreen avec les dépendances nécessaires
  Widget createDashboardScreen() => MaterialApp(
        home: Provider<TrelloApi>(
          create: (_) => mockTrelloApi,
          child: DashboardScreen(),
        ),
      );

  group('DashboardScreen Tests', () {
    testWidgets('Affiche la barre de navigation inférieure', (WidgetTester tester) async {
      await tester.pumpWidget(createDashboardScreen());

      // Vérification de la présence de la CustomNavigationBar
      expect(find.byKey(Key('customNavigationBar')), findsOneWidget);
    });

    testWidgets('Navigation entre les écrans à partir de la barre de navigation inférieure', (WidgetTester tester) async {
      await tester.pumpWidget(createDashboardScreen());

      // Tap sur le deuxième item de la BottomNavigationBar
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle(); // Attend que l'animation se termine

      // Vérifie si le SearchScreen est affiché
      expect(find.byType(SearchScreen), findsOneWidget);

      // Répéter pour les autres items si nécessaire
    });
  });
}
