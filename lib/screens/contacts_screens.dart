import 'package:contacts_phone/services/contact_service.dart';
import 'package:contacts_phone/widgets/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();
  List<Contact> _contacts = [];
  bool _isLoading = false;
  bool _mounted = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!_mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _loadContacts() async {
    if (_mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final contacts = await _contactService.loadContacts();
      if (_mounted) {
        setState(() {
          _contacts = contacts;
        });
      }
    } catch (e) {
      if (_mounted) {
        _showSnackBar(
            'Erreur lors de la lecture des contacts: ${e.toString()}');
      }
    } finally {
      if (_mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleExportToCsv() async {
    try {
      await _contactService.exportToCsv(_contacts);
      _showSnackBar(
          'Fichier CSV exporté avec succès : Stokage interne/contactsPhone');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'export : ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts (${_contacts.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleExportToCsv,
            tooltip: 'Exporter en CSV',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ContactList(contacts: _contacts),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadContacts,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
