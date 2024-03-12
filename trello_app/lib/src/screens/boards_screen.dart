import 'package:flutter/material.dart';
import 'package:trello_app/src/services/trello_api.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:trello_app/src/models/workspace.dart';

class BoardScreen extends StatefulWidget {
  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final TrelloApi _trelloApi = TrelloApi();
  List<Workspace> _workspaces = [];
  bool _isLoading = true;
  final TextEditingController _workspaceNameController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadWorkspaces();
  }

Future<void> _loadWorkspaces() async {
  setState(() {
    _isLoading = true;
  });
  try {
    final workspaces = await _trelloApi.getWorkspaces();
    setState(() {
      _workspaces = workspaces;
    });
  } catch (e) {
    print(e);
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}


  Future<void> _createWorkspace() async {
    if (_workspaceNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Le nom du workspace ne peut pas être vide.")));
      return;
    }
    try {
      final newWorkspace = await _trelloApi.createWorkspace(_workspaceNameController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Workspace créé : ${newWorkspace.name}')));
      _workspaceNameController.clear();
      _loadWorkspaces(); // Recharger les workspaces pour inclure le nouveau
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur lors de la création du workspace. Vérifiez votre connexion et les détails de l'API.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
                controller: _workspaceNameController,
                decoration: InputDecoration(
                labelText: 'Nom du nouveau workspace',
                suffixIcon: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _createWorkspace,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Vos espaces de travail',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _workspaces.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: ListTile(
                          title: Text(_workspaces[index].name),
                          leading: Icon(Icons.dashboard),
                          onTap: () {
                            // Action lors du clic sur un tableau
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    super.dispose();
  }
}
