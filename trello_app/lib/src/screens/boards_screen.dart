import 'package:flutter/material.dart';
import 'package:trello_app/src/services/trello_api.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/screens/workspaceDetails_screen.dart'; 

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

  Future<void> _createWorkspace(String workspaceName) async {
    try {
      final newWorkspace = await _trelloApi.createWorkspace(workspaceName);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Workspace créé : ${newWorkspace.name}')));
      _workspaceNameController.clear();
      _loadWorkspaces();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Erreur lors de la création du workspace. Vérifiez votre connexion et les détails de l'API.")));
    }
  }

  Future<void>  _filterWorkspaces(String query) async {
    if (query.isEmpty) {
      _loadWorkspaces();
      return;
    }

    final filteredWorkspaces = _workspaces
        .where((workspace) =>
            workspace.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    setState(() => _workspaces = filteredWorkspaces);
  }

  Future<void> _confirmAndDeleteWorkspace(String idWorkspace) async {
    bool confirm = await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Confirmation'),
              content: Text('Voulez-vous vraiment supprimer ce workspace ?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Supprimer'),
                ),
              ],
            );
          },
        ) ??
        false; // La valeur par défaut est `false` si rien n'est retourné (par exemple, si l'utilisateur ferme la boîte de dialogue)

    if (confirm) {
      try {
        await _trelloApi.deleteWorkspace(idWorkspace);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Workspace supprimé')));
        _loadWorkspaces(); // Recharger la liste des workspaces après la suppression
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                "Erreur lors de la suppression du workspace. Vérifiez votre connexion et les détails de l'API.")));
      }
    }
  }

  Future<void> _updateWorkspace(String idWorkspace, String newName) async {
    try {
      final updatedWorkspace =
          await _trelloApi.updateWorkspace(idWorkspace, newName);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Workspace mis à jour : ${updatedWorkspace.name}')));
      _loadWorkspaces();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Erreur lors de la mise à jour du workspace. Vérifiez votre connexion et les détails de l'API.")));
    }
  }

  Future<void> _showEditDialog(String idWorkspace, String currentName) async {
    final TextEditingController _editNameController =
        TextEditingController(text: currentName);
    return showDialog<void>(
      context: context,
      barrierDismissible:
          false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier le nom du workspace'),
          content: TextField(
            controller: _editNameController,
            decoration: InputDecoration(hintText: "Entrez le nouveau nom ici"),
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
              onPressed: () {
                if (_editNameController.text.isNotEmpty) {
                  _updateWorkspace(
                      idWorkspace, _editNameController.text.trim());
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptCreateWorkspace() async {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nouveau workspace'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Nom du workspace'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty) {
                await _createWorkspace(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Créer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 3, // Prend les 3/4 de l'espace
                  child: TextField(
                    controller: _workspaceNameController,
                    decoration: InputDecoration(
                      labelText: 'Rechercher un workspace',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onChanged: (value) => _filterWorkspaces(value),
                  ),
                ),
                SizedBox(width: 8), // Espacement entre le champ de texte et le bouton
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () => _promptCreateWorkspace(),
                  tooltip: 'Créer un nouveau workspace',
                ),
              ],
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
                      final workspace = _workspaces[index];
                      return Card(
                        child: ListTile(
                          title: Text(workspace.name),
                          leading: Icon(Icons.dashboard),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _showEditDialog(
                                    workspace.id, workspace.name),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => _confirmAndDeleteWorkspace(workspace.id),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkspaceDetailScreen(
                                  workspace: workspace,
                                )
                              ),
                            );
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
