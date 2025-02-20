import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';

class ContactList extends StatelessWidget {
  final List<Contact> contacts;
  const ContactList({
    super.key,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    if (contacts.isEmpty) {
      return const Center(
        child: Text('Aucun contact avec numéro de téléphone trouvé'),
      );
    }

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return ListTile(
          leading: const CircleAvatar(
            child: Icon(Icons.person),
          ),
          title: Text(contact.displayName),
          subtitle: Text(contact.phones.first.number),
        );
      },
    );
  }
}
