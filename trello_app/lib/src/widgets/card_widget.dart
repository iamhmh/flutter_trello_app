import 'package:flutter/material.dart';
import 'package:trello_app/src/models/card.dart';
import 'package:trello_app/src/models/member.dart';

class CardWidget extends StatelessWidget {
  final Cards card;
  final List<Member> assignedMembers;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;

  const CardWidget({
    Key? key,
    required this.card,
    required this.assignedMembers,
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(card.name, style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  IconButton(icon: Icon(Icons.edit, size: 15), onPressed: onUpdate),
                  IconButton(icon: Icon(Icons.delete, size: 15), onPressed: onDelete),
                ],
              ),
              SizedBox(height: 4),
              Text(
                card.desc ?? "Pas de description",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          Positioned(
            bottom: 2,
            right: 13,
            child: _buildAssignedMembersAvatars(),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignedMembersAvatars() {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: assignedMembers.map((member) {
      var avatarUrl = member.avatarUrl;

      String displayAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty
          ? "$avatarUrl/50.png"
          : "assets/images/utilisateur.png";

      return Container(
        width: 20,
        height: 20,
        margin: EdgeInsets.only(left: 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: displayAvatarUrl.startsWith('http')
                ? NetworkImage(displayAvatarUrl) as ImageProvider
                : AssetImage(displayAvatarUrl),
            fit: BoxFit.fill,
          ),
        ),
      );
    }).toList(),
  );
}

}
