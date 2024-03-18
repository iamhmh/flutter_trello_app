import 'package:flutter/material.dart';
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/services/trello_api.dart'; // Assurez-vous que ce soit le bon chemin d'accès
import 'package:trello_app/src/models/board.dart'; // Assurez-vous que ce soit le bon chemin d'accès

class WorkspaceDetailScreen extends StatefulWidget {
  final Workspace workspace;

  WorkspaceDetailScreen({Key? key, required this.workspace}) : super(key: key);

  @override
  _WorkspaceDetailScreenState createState() => _WorkspaceDetailScreenState();
}

class _WorkspaceDetailScreenState extends State<WorkspaceDetailScreen> {
  final TrelloApi _trelloApi = TrelloApi();
  List<Board> _boards = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBoards();
  }

  Future<void> _loadBoards() async {
    setState(() => _isLoading = true);
    try {
      final boards = await _trelloApi.getBoards(widget.workspace.id);
      setState(() {
        _boards = boards;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> _promptCreateBoard() async {
    final TextEditingController _boardNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Créer un nouveau board'),
          content: TextField(
            controller: _boardNameController,
            decoration: InputDecoration(hintText: "Nom du board"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Créer'),
              onPressed: () async {
                if (_boardNameController.text.isNotEmpty) {
                  // Ici, vous créez le board en utilisant l'API
                  try {
                    final newBoard = await _trelloApi.createBoard(
                        widget.workspace.id, _boardNameController.text.trim());
                    Navigator.of(context)
                        .pop(); // Fermer la boîte de dialogue après la création
                    _loadBoards(); // Recharger la liste des boards pour afficher le nouveau board
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Board créé avec succès: ${newBoard.name}')));
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Erreur lors de la création du board')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Le nom du board ne peut pas être vide')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _editBoard(Board board) async {
    final TextEditingController _editNameController =
        TextEditingController(text: board.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le board'),
          content: TextField(
            controller: _editNameController,
            decoration: InputDecoration(hintText: "Nouveau nom du board"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                if (_editNameController.text.isNotEmpty) {
                  try {
                    await _trelloApi.updateBoard(
                        board.id, _editNameController.text.trim());
                    Navigator.of(context)
                        .pop(); // Fermer la boîte de dialogue après la modification
                    _loadBoards(); // Recharger la liste des boards pour afficher les modifications
                  } catch (error) {
                    print(error);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content:
                            Text('Erreur lors de la modification du board')));
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Le nom du board ne peut pas être vide')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBoard(String boardId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Voulez-vous vraiment supprimer ce board ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                try {
                  await _trelloApi.deleteBoard(boardId);
                  Navigator.of(context)
                      .pop(); // Fermer la boîte de dialogue après la suppression
                  _loadBoards(); // Recharger la liste des boards pour afficher les changements
                } catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Erreur lors de la suppression du board')));
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _filterBoards(String query) async {
    if (query.isEmpty) {
      _loadBoards();
      return;
    }

    final filteredBoards = _boards
        .where(
            (board) => board.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() {
      _boards = filteredBoards;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workspace.name,
            style: TextStyle(color: Color(0xfffceee7))),
        backgroundColor: Color(0xfff57b51),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            color: Color(0xfffceee7),
            onPressed: _promptCreateBoard,
          ),
        ],
      ),
      body: Container(
        color: Color(0xfff57b51), // Définissez la couleur de fond à orange
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Rechercher un board',
                  labelStyle: TextStyle(color: Color(0xfffceee7)),
                  hintStyle: TextStyle(color: Color(0xfffceee7)),
                  alignLabelWithHint: true,
                  iconColor: Color(0xfffceee7),
                  border: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xfffceee7), width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(0xfffceee7), width: 2.0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  suffixIcon: IconButton(
                    color: Color(0xfffceee7),
                    icon: Icon(Icons.search),
                    onPressed: () {
                      _filterBoards(_searchController.text);
                    },
                  ),
                ),
                onChanged: (value) {
                  _filterBoards(value);
                },
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _boards.length,
                      itemBuilder: (context, index) {
                        final board = _boards[index];
                        return Card(
                          color: Color(0xfffceee7),
                          child: ListTile(
                            title: Text(board.name),
                            leading: Icon(Icons.dashboard),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _editBoard(board),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deleteBoard(board.id),
                                ),
                              ],
                            ),
                            onTap: () {
                              // Logique pour ouvrir le board et afficher ses détails ou listes
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
