import 'package:flutter/material.dart';
import 'package:trello_app/src/models/board.dart';
import 'package:trello_app/src/models/lists.dart';
import 'package:trello_app/src/models/card.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/services/trello_api.dart';
import 'package:trello_app/src/widgets/card_widget.dart';

class BoardDetailScreen extends StatefulWidget {
  final Board board;

  BoardDetailScreen({Key? key, required this.board}) : super(key: key);

  @override
  _BoardDetailScreenState createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  List<Lists> _lists = [];
  List<Cards> _cards = [];
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
      await Future.forEach(lists, (Lists list) async {
        final cards = await _trelloApi.getCards(list.id);
        for (var card in cards) {
          var members = await _trelloApi.getCardMembers(card.id);
          card.members = members;
        }
        list.cards = cards;
      });
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
                      _lists.add(newList); 
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
                    print(error);
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

  Future<void> _promptCreateCard(String listId) async {
    final TextEditingController _cardNameController = TextEditingController();
    final TextEditingController _cardDescController = TextEditingController();
    List<Member> members = await _trelloApi.getBoardMembers(widget.board.id); // Chargez les membres du tableau
    Map<String, bool> selectedMembers = Map.fromIterable(members, key: (member) => member.id, value: (member) => false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Créer une nouvelle carte'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _cardNameController,
                      decoration: InputDecoration(hintText: "Nom de la carte"),
                    ),
                    TextField(
                      controller: _cardDescController,
                      decoration: InputDecoration(hintText: "Description de la carte"),
                    ),
                    ...members.map((member) => CheckboxListTile(
                          title: Text(member.fullName),
                          value: selectedMembers[member.id],
                          onChanged: (bool? value) {
                            setState(() {
                              selectedMembers[member.id] = value!;
                            });
                          },
                        )),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Annuler'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text('Créer'),
                  onPressed: () async {
                    final cardName = _cardNameController.text.trim();
                    final cardDesc = _cardDescController.text.trim();
                    List<String> memberIds = selectedMembers.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
                    if (cardName.isNotEmpty) {
                      try {
                        final newCard = await _trelloApi.createCard(listId, cardName, desc: cardDesc, memberIds: memberIds);
                        Navigator.of(context).pop();
                        _loadLists();
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

  Future<void> _promptUpdateCard(Cards card) async {
    final TextEditingController _cardNameController = TextEditingController(text: card.name);
    final TextEditingController _cardDescController = TextEditingController(text: card.desc ?? "");
    List<Member> allMembers = await _trelloApi.getBoardMembers(widget.board.id); // Chargez tous les membres du tableau
    Map<String, bool> memberSelections = { for (var m in allMembers) m.id : card.members.any((cm) => cm.id == m.id) };

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Modifier la carte'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: _cardNameController, decoration: InputDecoration(hintText: "Nom de la carte")),
                    TextField(controller: _cardDescController, decoration: InputDecoration(hintText: "Description de la carte")),
                    ...allMembers.map((member) => CheckboxListTile(
                          title: Text(member.fullName),
                          value: memberSelections[member.id],
                          onChanged: (bool? value) {
                            setState(() {
                              memberSelections[member.id] = value!;
                            });
                          },
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(child: Text('Annuler'), onPressed: () => Navigator.pop(context)),
                TextButton(
                  child: Text('Enregistrer'),
                  onPressed: () async {
                    final newName = _cardNameController.text.trim();
                    final newDesc = _cardDescController.text.trim();
                    List<String> updatedMemberIds = memberSelections.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
                    if (newName.isNotEmpty || newDesc.isNotEmpty || updatedMemberIds.isNotEmpty) {
                      try {
                        await _trelloApi.updateCard(
                          card.id,
                          name: newName,
                          desc: newDesc,
                          memberIds: updatedMemberIds,
                        );
                        Navigator.pop(context);
                        _loadLists();
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


  Future<void> _promptDeleteCard(String cardId, String listId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Supprimer la carte'),
          content: Text('Êtes-vous sûr de vouloir supprimer cette carte ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () async {
                try {
                  await _trelloApi.deleteCard(cardId);
                  setState(() {
                    final listIndex = _lists.indexWhere((list) => list.id == listId);
                    if (listIndex != -1) {
                      _lists[listIndex].cards.removeWhere((card) => card.id == cardId);
                    }
                  });
                  Navigator.pop(context);
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

  Future<void> _moveCardToList(Cards card, String newListId) async {
    try {
      final updatedCard = _trelloApi.updateCard(card.id, listId: newListId);
      _loadLists();
    } catch (error) {
      print(error);
    }
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
            color: Color(0xfff57b51),
          ),
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 5.0,
                    runSpacing: 5.0,
                    direction: Axis.horizontal,
                    children: _buildLists(),
                  ),
                ),
        ],
      ),
    );
  }

  List<Widget> _buildLists() {
    return _lists.map((list) {
      return DragTarget<Cards>(
        onWillAccept: (data) => true,
        onAccept: (data) {
          _moveCardToList(data, list.id);
        },
        builder: (context, candidateData, rejectedData) => Container(
          width: 300,
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: Color(0xfffceee7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(list.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, size: 20),
                      onPressed: () => _promptUpdateList(list),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, size: 20),
                      onPressed: () => _promptArchiveList(list.id),
                    ),
                  ],
                ),
              ),
              list.cards.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(10),
                      child: Text("Pas de cartes", style: TextStyle(color: Colors.grey)),
                    )
                  : Column(
                      children: list.cards.map((card) {
                        List<Member> assignedMembers = card.members;
                        return Draggable<Cards>(
                          data: card,
                          child: CardWidget(
                            card: card,
                            onUpdate: () => _promptUpdateCard(card),
                            onDelete: () => _promptDeleteCard(card.id, list.id),
                            assignedMembers: assignedMembers,
                          ),
                          feedback: Material(
                            child: CardWidget(card: card, onUpdate: () {}, onDelete: () {}, assignedMembers: assignedMembers,),
                            elevation: 4.0,
                          ),
                          childWhenDragging: Container(),
                        );
                      }).toList(),
                    ),
              Center(
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _promptCreateCard(list.id),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLists();
  }

}