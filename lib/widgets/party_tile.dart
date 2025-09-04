import 'package:flutter/material.dart';

import '../models/party.dart';

class PartyTile extends StatelessWidget {
  final Party party;
  final VoidCallback? onTap;

  const PartyTile({super.key, required this.party, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: party.photoUrl != null
            ? CircleAvatar(backgroundImage: NetworkImage(party.photoUrl!))
            : const CircleAvatar(child: Icon(Icons.person)),
        title: Text(party.name),
        subtitle: Text(party.phone),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}

