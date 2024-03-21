import 'package:flutter/material.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/services/trello_api.dart';
import 'package:trello_app/src/models/board.dart';
import 'package:trello_app/src/screens/boardsDetails_screen.dart';

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
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _loadBoards();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() {
      widget.workspace.membersCount = 0;
    });
    try {
      List<Member> members = await _trelloApi.getMembersOfOrganisation(widget.workspace.id);
      setState(() {
        widget.workspace.membersCount = members.length;
        _members = members;
      });
    } catch (e) {
      print("Erreur lors du chargement des membres: $e");
    }
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
    bool _defaultLists = true; // Par défaut, les listes seront créées

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Utilisez StatefulBuilder pour mettre à jour l'état local dans le dialogue
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Créer un nouveau board'),
              content: Column(
                mainAxisSize: MainAxisSize.min, // Pour éviter l'excès d'espace
                children: [
                  TextField(
                    controller: _boardNameController,
                    decoration: InputDecoration(hintText: "Nom du board"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tableau Kanban'),
                      Checkbox(
                        value: _defaultLists,
                        onChanged: (bool? value) {
                          setState(() {
                            _defaultLists = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
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
                      try {
                        final newBoard = await _trelloApi.createBoard(
                            widget.workspace.id, _boardNameController.text.trim(),
                            defaultLists: _defaultLists); // Passez le choix de l'utilisateur
                        Navigator.of(context).pop(); // Fermer le dialogue
                        _loadBoards(); // Recharger les tableaux
                      } catch (error) {
                        print(error);
                      }
                    }
                  },
                ),
              ],
            );
          },
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
            TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                try {
                  await _trelloApi.deleteBoard(boardId);
                  setState(() {
                    _boards.removeWhere((board) => board.id == boardId);
                  });
                  Navigator.of(context).pop();
                } catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la suppression du board')));
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

  Future<void> _promptAssignMemberToBoard(Member member) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Assigner un membre à un board'),
          content: Text('Voulez-vous vraiment assigner ${member.fullName} à un board ?'),
          actions: <Widget>[
            TextButton(child: Text('Annuler'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Assigner'),
              onPressed: () async {
                try {
                  await _trelloApi.assignMemberToBoard(member.id, _boards.first.id);
                  Navigator.of(context).pop();
                } catch (error) {
                  print(error);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de l\'assignation du membre au board')));
                }
              },
            ),
          ],
        );
      },
    );
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
            SizedBox(height: 10),
            Text(
              'Member(s) (${widget.workspace.membersCount})',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 5),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 6.0), // Assurez-vous que ce conteneur est aligné avec les autres éléments
              decoration: BoxDecoration(
                color: Color(0xfffceee7),
                borderRadius: BorderRadius.circular(20), // Bords arrondis
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(), 
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      return ListTile(
                        title: Text(member.fullName),
                        subtitle: Text(member.email ?? 'Pas d\'email'),
                        trailing: IconButton(
                          icon: Icon(Icons.playlist_add),
                          onPressed: () => _promptAssignMemberToBoard(member),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 10), // Ajoute un espace entre les éléments (équivalent à margin-bottom en CSS
            Text(
              'Boards (${_boards.length})',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 5),
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
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => BoardDetailScreen(board: board),
                              ));
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
