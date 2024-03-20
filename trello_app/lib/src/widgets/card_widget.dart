import 'package:flutter/material.dart';
import 'package:trello_app/src/models/card.dart';

class CardWidget extends StatelessWidget {
  final Cards card;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const CardWidget({
    Key? key,
    required this.card,
    required this.onUpdate,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: screenWidth * 0.85,
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child:
                Text(
                    card.name,
                    style: TextStyle(fontWeight: FontWeight.bold, ),
                  ), 
                ),
                IconButton(
                  icon: Icon(Icons.edit, size: 15),
                  onPressed: onUpdate,
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 15),
                  onPressed: onDelete,
                ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            card.desc ?? "Pas de description",
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}