import 'package:flutter/material.dart';

class BoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Rechercher',
                suffixIcon: Icon(Icons.search),
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
            child: ListView.builder(
              itemCount: 4,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text('Tableau $index'),
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
}
