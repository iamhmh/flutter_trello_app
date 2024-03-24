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
      print("Error loading members : $e");
    }
  }

  Future<void> _loadBoards() async {
      if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final boards = await _trelloApi.getBoards(widget.workspace.id);
      await _updateBoardMembersCount(boards);
        if (!mounted) return;
      setState(() {
        _boards = boards;
        _isLoading = false;
      });
    } catch (e) {
       if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateBoardMembersCount(List<Board> boards) async {
    for (var board in boards) {
      try {
        int membersCount = await _trelloApi.getBoardMemberships(board.id);
        board.membersCount = membersCount;
      } catch (e) {
        print("Error ${board.id}: $e");
        board.membersCount = 0;
      }
    }
  }

  Future<void> _promptCreateBoard() async {
    final TextEditingController _boardNameController = TextEditingController();
    bool _defaultLists = true; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( 
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Create a new board'),
              content: Column(
                mainAxisSize: MainAxisSize.min, 
                children: [
                  TextField(
                    controller: _boardNameController,
                    decoration: InputDecoration(hintText: "Name of the board"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Kanban board (default lists)'),
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
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Create'),
                  onPressed: () async {
                    if (_boardNameController.text.isNotEmpty) {
                      try {
                        final newBoard = await _trelloApi.createBoard(
                            widget.workspace.id, _boardNameController.text.trim(),
                            defaultLists: _defaultLists); 
                        Navigator.of(context).pop();
                        _loadBoards(); 
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
    final TextEditingController _editNameController = TextEditingController(text: board.name);
    List<Member>? members = await _trelloApi.getBoardMembers(board.id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update board ${board.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: _editNameController,
                  decoration: InputDecoration(hintText: "New name of the board"),
                ),
                ...members!.map((member) {
                  return ListTile(
                    title: Text(member.fullName),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () async {
                        _promptRemoveMemberFromBoard(board, member);
                        _loadBoards();
                      },
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                Navigator.of(context).pop();
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
          title: Text('Confirm'),
          content: Text('Would you like to delete this board?'),
          actions: <Widget>[
            TextButton(child: Text('Cancel'), onPressed: () => Navigator.of(context).pop()),
            TextButton(
              child: Text('Delete'),
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
    String? selectedBoardId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Assign ${member.fullName} to a board'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Choose a board to assign ${member.fullName} to:'),
                    DropdownButton<String>(
                      hint: Text("Select a board"),
                      value: selectedBoardId,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedBoardId = newValue;
                        });
                      },
                      items: _boards.map<DropdownMenuItem<String>>((Board board) {
                        return DropdownMenuItem<String>(
                          value: board.id,
                          child: Text(board.name),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Assign'),
                  onPressed: selectedBoardId == null ? null : () async {
                    try {
                      await _trelloApi.assignMemberToBoard(selectedBoardId!, member.id, "normal");
                      Navigator.of(context).pop();
                      _loadBoards();
                    } catch (error) {
                      print(error);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error assigning member to board.')));
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

  Future<void> _promptRemoveMemberFromBoard(Board board, Member member) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete member from board'),
          content: Text('Would you like to delete ${member.fullName} from ${board.name}?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _removeMemberFromBoard(board.id, member.id);
                _loadBoards(); 
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _removeMemberFromBoard(String boardId, String memberId) async {
    try {
      await _trelloApi.removeMemberFromBoard(boardId, memberId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deleted member from board.')));
      _loadBoards();
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting member from board.')));
    }
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
        color: Color(0xfff57b51),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search a board...',
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
              margin: EdgeInsets.symmetric(horizontal: 6.0), 
              decoration: BoxDecoration(
                color: Color(0xfffceee7),
                borderRadius: BorderRadius.circular(20),
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
                        subtitle: Text(member.email ?? 'No email provided'),
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
            SizedBox(height: 10),
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
                            subtitle: Text('${board.membersCount} member(s)'),
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
