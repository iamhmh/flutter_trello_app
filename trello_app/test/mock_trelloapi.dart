// Importez les packages nécessaires
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/services/trello_api.dart';

// Créez le mock
class MockTrelloApi extends Mock implements TrelloApi {}

void main() {
  testWidgets('Votre test', (WidgetTester tester) async {
    var mockTrelloApi = MockTrelloApi();
    
    when(mockTrelloApi.getMemberInfo('token')).thenAnswer((_) async => Member(fullName: 'John Doe', email: 'johndoe@email.com', username: 'johndoe', id: '123', avatarUrl: 'https://example.com/avatar'));    
  });
}
