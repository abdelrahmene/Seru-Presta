import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FacebookProfileWidget extends StatelessWidget {
  final Map<String, dynamic> profile;
  final double avatarSize;
  final bool showDetails;

  const FacebookProfileWidget({
    Key? key,
    required this.profile,
    this.avatarSize = 40,
    this.showDetails = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: profile['picture']['data']['url'],
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.person),
                width: avatarSize,
                height: avatarSize,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12.0),
          // Informations
          if (showDetails)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    profile['email'] ?? '...',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
