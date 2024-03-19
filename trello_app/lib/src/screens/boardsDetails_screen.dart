import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';
import 'package:trello_app/src/models/board.dart';
import 'package:trello_app/src/models/lists.dart';
import 'package:trello_app/src/services/trello_api.dart';

class BoardDetailScreen extends StatefulWidget {
  final Board board;

  BoardDetailScreen({Key? key, required this.board}) : super(key: key);

  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  List<Lists> _lists = []; 
  bool _isLoading = true;
  final TrelloApi _trelloApi = TrelloApi();

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    try {
      final lists = await _trelloApi.getLists(widget.board.id);
      setState(() {
        _lists = lists;
        _isLoading = false;
      });
    } catch (error) {
      print(error);
    }
  }

  Future<void> _promptCreateList() async {
    final TextEditingController _listNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Créer une nouvelle liste'),
          content: TextField(
            controller: _listNameController,
            decoration: InputDecoration(hintText: "Nom de la liste"),
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
                if (_listNameController.text.isNotEmpty) {
                  try {
                    final newList = await _trelloApi.createLists(widget.board.id, _listNameController.text.trim());
                    setState(() {
                      _lists.add(newList); // Supposant que _lists est votre liste de listes en mémoire
                    });
                    Navigator.of(context).pop();
                  } catch (error) {
                    print(error);
                  }
                } else {
                  print('Le nom de la liste ne peut pas être vide.');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptUpdateList(Lists list) async {
    final TextEditingController _listNameController = TextEditingController(text: list.name);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la liste'),
          content: TextField(controller: _listNameController),
          actions: [
            TextButton(child: Text('Annuler'), onPressed: () => Navigator.pop(context)),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                final newName = _listNameController.text.trim();
                if (newName.isNotEmpty) {
                  try {
                    final updatedList = await _trelloApi.updateLists(list.id, newName);
                    Navigator.pop(context);
                    _loadLists();
                  } catch (error) {
                    // Gérez les erreurs ici
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptArchiveList(String listId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Archiver la liste'),
          content: Text('Êtes-vous sûr de vouloir archiver cette liste ?'),
          actions: [
            TextButton(child: Text('Annuler'), onPressed: () => Navigator.pop(context)),
            TextButton(
              child: Text('Archiver'),
              onPressed: () async {
                try {
                  await _trelloApi.archiveList(listId, true);
                  Navigator.pop(context);
                  _loadLists();
                } catch (error) {
                  print(error);
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
        title: Text(widget.board.name),
        backgroundColor: Color(0xfff57b51),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _promptCreateList,
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Color(0xfff57b51), // Définit la couleur de fond de l'écran complet
          ),
          _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildLists(),
                ),
              ),
        ],
      ),
    );
  }

  List<Widget> _buildLists() {
    return _lists.map((list) {
      var cards = list.cards ?? [];
      return Container(
        width: 300,
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(0xfffceee7),
          borderRadius: BorderRadius.circular(10),
        ),
        height: cards.length * 50.0 + 150.0,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(list.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _promptUpdateList(list),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _promptArchiveList(list.id),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return ListTile(title: Text(cards[index].name));
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () {
                // Implémentez la logique pour ajouter une carte
              },
            ),
          ],
        ),
      );
    }).toList();
  }


}
