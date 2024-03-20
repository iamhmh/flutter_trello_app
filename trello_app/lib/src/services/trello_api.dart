import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trello_app/src/models/board.dart';
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/models/lists.dart';
import 'package:trello_app/src/models/card.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/utils/constants.dart';

class TrelloApi {
  //Workspaces
  Future<List<Workspace>> getWorkspaces() async {
    final response = await http.get(
      Uri.parse(
          'https://api.trello.com/1/members/me/organizations?key=${Constants.apiKey}&token=${Constants.apiToken}'),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;
      return jsonData.map((data) => Workspace.fromJson(data)).toList();
    } else {
      throw Exception('Failed to get workspaces: ${response.statusCode}');
    }
  }

  Future<Workspace> createWorkspace(String displayName) async {
    final url = Uri.parse('https://api.trello.com/1/organizations');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'displayName': displayName, 
        'key': Constants.apiKey,
        'token': Constants.apiToken,
      }),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Workspace.fromJson(
          jsonData);
    } else {
      print('Erreur lors de la création du workspace: ${response.statusCode}');
      print('Réponse: ${response.body}');
      throw Exception(
          'Failed to create workspace: ${response.statusCode}, ${response.body}');
    }
  }

  Future<Workspace> updateWorkspace(String idWorkspace, String newName) async {
    final url =
        'https://api.trello.com/1/organizations/$idWorkspace?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Workspace.fromJson(jsonData);
    } else {
      throw Exception('Failed to update workspace: ${response.statusCode}');
    }
  }

  Future<void> deleteWorkspace(String idWorkspace) async {
    final url =
        'https://api.trello.com/1/organizations/$idWorkspace?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Workspace deleted successfully.');
    } else {
      throw Exception('Failed to delete workspace: ${response.statusCode}');
    }
  }

  //Boards

  Future<List<Board>> getBoards(String idOrganization) async {
    final response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/organizations/$idOrganization/boards?key=${Constants.apiKey}&token=${Constants.apiToken}',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Board.fromJson(data)).toList();
    } else {
      throw Exception('Failed to get boards: ${response.statusCode}');
    }
  }

  Future<Board> createBoard(String workspaceId, String name, {bool defaultLists = true}) async {
    final response = await http.post(
      Uri.parse('https://api.trello.com/1/boards/?name=$name&idOrganization=$workspaceId&defaultLists=$defaultLists&key=${Constants.apiKey}&token=${Constants.apiToken}'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Board.fromJson(jsonData);
    } else {
      throw Exception('Failed to create board: ${response.statusCode}');
    }
  }

  Future<Board> updateBoard(String id, String newName) async {
    final url =
        'https://api.trello.com/1/boards/$id?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Board.fromJson(jsonData);
    } else {
      throw Exception('Failed to update board: ${response.statusCode}');
    }
  }

  Future<void> deleteBoard(String id) async {
    final url =
        'https://api.trello.com/1/boards/$id?key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.delete(Uri.parse(url));

    if (response.statusCode == 200) {
      print('Board deleted successfully.');
    } else {
      throw Exception('Failed to delete board: ${response.statusCode}');
    }
  }

  //Lists

  Future<List<Lists>> getLists(String boardId) async {
    final response = await http.get(
      Uri.parse(
        'https://api.trello.com/1/boards/$boardId/lists?key=${Constants.apiKey}&token=${Constants.apiToken}',
      ),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;
      return jsonData.map((data) => Lists.fromJson(data)).toList();
    } else {
      throw Exception('Failed to get lists: ${response.statusCode}');
    }
  }

  Future<Lists> createLists(String boardId, String name) async {
    final url = Uri.parse('https://api.trello.com/1/lists?name=$name&idBoard=$boardId&key=${Constants.apiKey}&token=${Constants.apiToken}');
    final response = await http.post(url, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Lists.fromJson(jsonData);
    } else {
      throw Exception('Failed to create list: ${response.statusCode}');
    }
  }

  Future<Lists> updateLists(String id, String newName) async {
    final url =
        'https://api.trello.com/1/lists/$id?name=$newName&key=${Constants.apiKey}&token=${Constants.apiToken}';
    final response = await http.put(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return Lists.fromJson(jsonData);
    } else {
      throw Exception('Failed to update lists: ${response.statusCode}');
    }
  }

  Future<void> archiveList(String listId, bool value) async {
    final url = Uri.parse('https://api.trello.com/1/lists/$listId/closed?key=${Constants.apiKey}&token=${Constants.apiToken}');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'value': value,
      }),
    );

    if (response.statusCode == 200) {
      print('List successfully archived.');
    } else {
      throw Exception('Failed to archive list: ${response.statusCode}');
    }
  }

  //Cards

  Future<List<Cards>> getCards(String listId) async {
    final response = await http.get(
      Uri.parse('https://api.trello.com/1/lists/$listId/cards?key=${Constants.apiKey}&token=${Constants.apiToken}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Cards.fromJson(data)).toList();
    } else {
      throw Exception('Failed to get cards: ${response.statusCode}');
    }
  }

  Future<Cards> createCard(String listId, String name, {String? desc}) async {
    final response = await http.post(
      Uri.parse('https://api.trello.com/1/cards?name=$name&idList=$listId&desc=${desc ?? ""}&key=${Constants.apiKey}&token=${Constants.apiToken}'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Cards.fromJson(jsonData);
    } else {
      throw Exception('Failed to create card: ${response.statusCode}');
    }
  }

  Future<Cards> updateCard(String cardId, {String? name, String? desc}) async {
    final Map<String, dynamic> updates = {};
    if (name != null) updates['name'] = name;
    if (desc != null) updates['desc'] = desc;

    final response = await http.put(
      Uri.parse('https://api.trello.com/1/cards/$cardId?key=${Constants.apiKey}&token=${Constants.apiToken}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(updates),
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Cards.fromJson(jsonData);
    } else {
      throw Exception('Failed to update card: ${response.statusCode}');
    }
  }

  Future<void> deleteCard(String cardId) async {
    final response = await http.delete(
      Uri.parse('https://api.trello.com/1/cards/$cardId?key=${Constants.apiKey}&token=${Constants.apiToken}'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete card: ${response.statusCode}');
    }
  }

  //Members

  Future<Member> getMemberInfo(String token) async {
    final url = Uri.parse('https://api.trello.com/1/tokens/$token/member?key=${Constants.apiKey}&token=${Constants.apiToken}');
    final response = await http.get(url, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return Member.fromJson(jsonData);
    } else {
      throw Exception('Failed to get member info: ${response.statusCode}');
    }
  }

  Future<List<Member>> getMembers(String boardId) async {
    final response = await http.get(
      Uri.parse('https://api.trello.com/1/boards/$boardId/members?key=${Constants.apiKey}&token=${Constants.apiToken}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Member.fromJson(data)).toList();
    } else {
      throw Exception('Failed to get members: ${response.statusCode}');
    }
  }

  Future<void> addMemberToBoard(String boardId, String memberId) async {
    final response = await http.post(
      Uri.parse('https://api.trello.com/1/boards/$boardId/members?key=${Constants.apiKey}&token=${Constants.apiToken}&value=$memberId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add member to board: ${response.statusCode}');
    }
  }

  Future<void> removeMemberFromBoard(String boardId, String memberId) async {
    final response = await http.delete(
      Uri.parse('https://api.trello.com/1/boards/$boardId/members/$memberId?key=${Constants.apiKey}&token=${Constants.apiToken}'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove member from board: ${response.statusCode}');
    }
  }
}