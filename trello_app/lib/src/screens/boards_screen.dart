import 'package:flutter/material.dart';
import 'package:trello_app/src/components/custom_app_bar.dart';
import 'package:trello_app/src/components/custom_navigation_bar.dart';
import 'package:trello_app/src/models/member.dart';
import 'package:trello_app/src/services/trello_api.dart'; // Assurez-vous que le chemin d'accès est correct
import 'package:trello_app/src/models/workspace.dart';
import 'package:trello_app/src/screens/workspaceDetails_screen.dart'; 

class BoardScreen extends StatefulWidget {
  final bool shouldOpenCreateWorkspace;

  BoardScreen({this.shouldOpenCreateWorkspace = true});

  @override
  _BoardScreenState createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final TrelloApi _trelloApi = TrelloApi();
  List<Workspace> _workspaces = [];
  bool _isLoading = true;
  final TextEditingController _workspaceNameController = TextEditingController();

@override
  void initState() {
    super.initState();
    _loadWorkspaces();
    
    if (widget.shouldOpenCreateWorkspace) {
      WidgetsBinding.instance!.addPostFrameCallback((_) => _promptCreateWorkspace());
    }
  }

  Future<void> _loadWorkspaces() async {
    setState(() { _isLoading = true; });

    try {
      final workspaces = await _trelloApi.getWorkspaces();
      final membersCountsFutures = workspaces.map((workspace) {
        return _trelloApi.getMembershipsOfOrganization(workspace.id);
      }).toList();

      final membersCounts = await Future.wait(membersCountsFutures);
      for (int i = 0; i < workspaces.length; i++) {
        workspaces[i].membersCount = membersCounts[i];
      }

      setState(() {
        _workspaces = workspaces;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
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
  TextEditingController _editNameController = TextEditingController(text: currentName);
  List<Member> members = [];

  try {
    members = await _trelloApi.getMembersOfOrganisation(idWorkspace);
  } catch (e) {
    print("Erreur lors de la récupération des membres: $e");
  }

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier le workspace'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _editNameController,
                decoration: InputDecoration(hintText: "Nouveau nom du workspace"),
              ),
              // Liste des membres pour suppression
              for (var member in members)
                ListTile(
                  title: Text(member.fullName),
                  subtitle: Text(member.email ?? 'Pas d\'email'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await _trelloApi.removeMemberFromOrganization(idWorkspace, member.id);
                      Navigator.of(context).pop(); // Fermer la boîte de dialogue après suppression
                      _loadWorkspaces(); // Recharger les workspaces pour refléter les changements
                    },
                  ),
                ),
            ],
          ),
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
                await _trelloApi.updateWorkspace(idWorkspace, _editNameController.text.trim());
                Navigator.of(context).pop();
                _loadWorkspaces(); // Recharger les workspaces après la mise à jour
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

  Future<void> _promptInviteToOrganization(BuildContext context, String organizationId) async {
    final TextEditingController emailController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inviter à rejoindre l\'organisation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(hintText: "Email"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Inviter'),
              onPressed: () {
                // Utilisez _trelloApi pour appeler inviteToOrganization
                _trelloApi.inviteToOrganization(organizationId, emailController.text);
                Navigator.of(context).pop();
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
      body: Container(
        color: Color(0xfffceee7),// Définir la couleur de fond ici
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: _workspaceNameController,
                      decoration: InputDecoration(
                        labelText: 'Search a workspace',
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
                    tooltip: 'Create a new workspace',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your workspaces',
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
                          color: Colors.white,
                          child: ListTile(
                            title: Text(workspace.name),
                            subtitle: Text('${workspace.membersCount} member(s)'),
                            leading: Icon(Icons.space_dashboard),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () => _showEditDialog(workspace.id, workspace.name),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _confirmAndDeleteWorkspace(workspace.id),
                                ),
                                IconButton(
                                  icon: Icon(Icons.person_add),
                                  onPressed: () => _promptInviteToOrganization(context, workspace.id),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => WorkspaceDetailScreen(workspace: workspace),
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
      ),
    );
  }

  @override
  void dispose() {
    _workspaceNameController.dispose();
    super.dispose();
  }
}