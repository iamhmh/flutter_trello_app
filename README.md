# Application Flutter de gestion de projets avec l'API de Trello

Cette application est un outil de gestion de projets qui permet aux utilisateurs de gérer leurs tableaux, listes et cartes Trello directement depuis une interface mobile conviviale. Elle a été construite en utilisant Flutter pour le développement multiplateforme, en s'appuyant sur l'API de Trello pour la manipulation des données et Material UI pour l'esthétique de l'application.

## Technologies Utilisées

- Flutter
- API de Trello
- Material UI

## Fonctionnalités

- Gestion des workspaces : les utilisateurs peuvent créer, visualiser, modifier et supprimer des workspaces, et inviter une/des personne(s) à le rejoindre. 
- Gestion des tableaux : les utilisateurs peuvent créer, visualiser, modifier et supprimer des tableaux ainsi qu'assigner une personne à un tableau.
- Gestion des listes : au sein des tableaux, les utilisateurs peuvent gérer les listes pour organiser les tâches.
- Gestion des cartes : les tâches individuelles peuvent être détaillées à travers des cartes, avec la possibilité de les modifier et de les supprimer, ainsi qu'assigner une tâche à une personne.
- Authentification des utilisateurs : intégration de l'authentification Trello pour permettre aux utilisateurs d'accéder à leurs données.

## Configuration et Installation

Pour exécuter ce projet localement, commencez par cloner le dépôt Git ou téléchargez-le en tant que fichier ZIP et extrayez-le sur votre machine.

- Ouvrez le projet dans votre éditeur de code préféré.
- Assurez-vous d'avoir Flutter installé sur votre machine. Si ce n'est pas le cas, suivez les instructions sur le [site officiel de Flutter](https://flutter.dev/docs/get-started/install).

Pour configurer l'application :

1. Allez dans le dossier du projet Flutter et ouvrez le fichier `constants.dart` qui se trouve dans `/lib/src/utils`.
2. Ajoutez votre clé API et votre token Trello dans le fichier `constants.dart`:

```env
static const String apiKey = '';
static const String apiToken = '';
```

Pour obtenir votre clé API et token Trello, suivez les instructions sur la page de documentation de l'API Trello.

Puis, dans le terminal :
```
$ cd your_project_directory
$ flutter pub get (pour installer les dépendances)
$ flutter run (pour lancer l'application)
```

## Auteur

- **HICHEM GOUIA** - (https://github.com/iamhmh)
- **MELVYN DENIS** - (https://github.com/MelvynDenisEpitech)
- **ROMAIN DE MATOS RIBEIRO** - (https://github.com/romdmr)