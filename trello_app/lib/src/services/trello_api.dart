import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:trello_app/src/models/board.dart';
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/models/lists.dart';
import 'package:trello_app/src/models/card.dart';
import 'package:trello_app/src/utils/constants.dart';

class TrelloApi{

  //Workspaces

  Future<List<Workspace>> getWorkspaces(String idWorkspace) async {
  final response = await http.get(
    Uri.parse('https://api.trello.com/1/organizations/$idWorkspace?key=${Constants.apiKey}&token=${Constants.apiToken}'),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as List;
    return jsonData.map((data) => Workspace.fromJson(data)).toList();
  } else {
    throw Exception('Failed to get workspaces: ${response.statusCode}');
  }
  }

  Future<Workspace> createWorkspace(String name) async {
    final url = 'https://api.trello.com/1/organizations?name=$name&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Workspace.fromJson(jsonData);
    } else {
      throw Exception('Failed to create workspace: ${response.statusCode}');
    }
  }

  Future<Workspace> updateWorkspace(String idWorkspace, String newName) async {
    final url = 'https://api.trello.com/1/organizations/$idWorkspace?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Workspace.fromJson(jsonData);
    } else {
      throw Exception('Failed to update workspace: ${response.statusCode}');
    }
  }

  Future<void> deleteWorkspace(String idWorkspace) async {
    final url = 'https://api.trello.com/1/organizations/$idWorkspace?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Workspace deleted successfully.');
    } else {
      throw Exception('Failed to delete workspace: ${response.statusCode}');
    }
  }

  //Boards 

  Future<List<Board>> getBoards(String idBoard) async {
    final response = await http.get(
    Uri.parse('https://api.trello.com/1/boards/${idBoard}?key=${Constants.apiKey}&token=${Constants.apiToken}'),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as List;
    return jsonData.map((data) => Board.fromJson(data)).toList();
  } else {
    throw Exception('Failed to get boards: ${response.statusCode}');
  }
  }

  Future<Board> createBoard(String name) async {
  final url = 'https://api.trello.com/1/boards?name=$name&key=${Constants.apiKey}&token=${Constants.apiToken}';
  final response = await http.post(Uri.parse(url));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
    return Board.fromJson(jsonData);
  } else {
    throw Exception('Failed to create board: ${response.statusCode}');
  }
}


  Future<Board> updateBoard(String id, String newName) async {
        final url = 'https://api.trello.com/1/boards/$id?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Board.fromJson(jsonData);
    } else {
      throw Exception('Failed to update board: ${response.statusCode}');
    }
  }

  Future<void> deleteBoard(String id) async {
        final url = 'https://api.trello.com/1/boards/$id?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Board deleted successfully.');
    } else {
      throw Exception('Failed to delete board: ${response.statusCode}');
    }
  }

  //Lists

  Future<List<Lists>> getLists(String idLists) async {
      final response = await http.get(
    Uri.parse('https://api.trello.com/1/lists/$idLists?key=${Constants.apiKey}&token=${Constants.apiToken}'),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as List;
    return jsonData.map((data) => Lists.fromJson(data)).toList();
  } else {
    throw Exception('Failed to get lists: ${response.statusCode}');
  }
  }

  Future<Lists> createLists(String name) async {
    final url = 'https://api.trello.com/1/lists?name=$name&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Lists.fromJson(jsonData);
    } else {
      throw Exception('Failed to create lists: ${response.statusCode}');
    }
  }

  Future<Lists> updateLists(String id, String newName) async {
        final url = 'https://api.trello.com/1/lists/$id?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Lists.fromJson(jsonData);
    } else {
      throw Exception('Failed to update lists: ${response.statusCode}');
    }
  }

  Future<void> deleteLists(String id) async {
        final url = 'https://api.trello.com/1/lists/$id?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('List deleted successfully.');
    } else {
      throw Exception('Failed to delete list: ${response.statusCode}');
    }
  }

  //Cards

  Future<List<Card>> getCards(String idCards) async {
      final response = await http.get(
    Uri.parse('https://api.trello.com/1/cards/$idCards?key=${Constants.apiKey}&token=${Constants.apiToken}'),
  );

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body) as List;
    return jsonData.map((data) => Card.fromJson(data)).toList();
  } else {
    throw Exception('Failed to get cards: ${response.statusCode}');
  }
  }

  Future<Card> createCards(String name) async {
    final url = 'https://api.trello.com/1/cards?name=$name&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.post(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Card.fromJson(jsonData);
    } else {
      throw Exception('Failed to create cards: ${response.statusCode}');
    }
  }

  Future<Card> updateCards(String id, String newName) async {
        final url = 'https://api.trello.com/1/cards/$id?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Card.fromJson(jsonData);
    } else {
      throw Exception('Failed to update card: ${response.statusCode}');
    }
  }

  Future<void> deleteCards(String id) async {
        final url = 'https://api.trello.com/1/cards/$id?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Card deleted successfully.');
    } else {
      throw Exception('Failed to delete card: ${response.statusCode}');
    }
  }


}