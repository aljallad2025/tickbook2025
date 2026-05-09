
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TicketUserAvatar extends StatelessWidget {
  final String? url;
  final bool isAdmin;
  const TicketUserAvatar({super.key, required this.url, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final icon = isAdmin ? Icons.support_agent : Icons.person;
    if (url == null || url!.isEmpty) {
      return CircleAvatar(radius: 14, child: Icon(icon, size: 16));
    }
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: CachedNetworkImageProvider(url!),
      onBackgroundImageError: (_, __) {},
      child: const SizedBox.shrink(),
    );
  }
}
