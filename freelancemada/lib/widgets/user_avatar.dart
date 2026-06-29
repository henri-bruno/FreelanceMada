import 'package:flutter/material.dart';
import '../core/constants.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String nom;
  final double radius;
  final bool isOnline;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.nom,
    this.radius = 24,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppConstants.card2Color,
          backgroundImage: photoUrl != null && photoUrl!.isNotEmpty
              ? NetworkImage(photoUrl!)
              : null,
          child: photoUrl == null || photoUrl!.isEmpty
              ? Text(
                  nom.isNotEmpty ? nom[0].toUpperCase() : '?',
                  style: TextStyle(
                    color: AppConstants.goldColor,
                    fontWeight: FontWeight.bold,
                    fontSize: radius * 0.7,
                  ),
                )
              : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: radius * 0.4,
              height: radius * 0.4,
              decoration: BoxDecoration(
                color: AppConstants.successColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppConstants.primaryColor, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}
