import 'package:contacts_phone/services/contact_service.dart';
import 'package:contacts_phone/widgets/contact_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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

  void _checkPermission() async {
    // Vérifier si on a déjà la permission
    bool permissionGranted =
        await FlutterContacts.requestPermission(readonly: true);

    if (!permissionGranted) {
      if (_mounted) {
        _showSnackBar(
            'L\'accès aux contacts est nécessaire pour utiliser cette fonctionnalité');
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }
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
        _showSnackBar('Erreur lors de la lecture des contacts: ${e.toString()}');
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
      // final filePath = await _contactService.exportToCsv(_contacts);
      _showSnackBar('Fichier CSV exporté avec succès : Stokage interne/contactsPhone');
      // _showSnackBar('Fichier CSV exporté avec succès : $filePath');
    } catch (e) {
      _showSnackBar('Erreur lors de l\'export : ${e.toString()}');
    }
  }


  // String _simplifyAccountType(String type) {
  //   // Récupérer la partie après le dernier point
  //   final parts = type.split('.');
  //   return parts.isNotEmpty ? parts.last : type;
  // }

  // Future<void> _exportToCsv() async {
  //   Directory? directory;
  //   try {
  //     // Vérifier la permission d'écriture
  //     var status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       _showSnackBar('Permission d\'écriture refusée');
  //       return;
  //     }
  //     final csvContent = [
  //       'Nom,Numéro,Type', // En-tête
  //       ..._contacts.map((contact) {
  //         final type = contact.accounts.isNotEmpty
  //             ? _simplifyAccountType(contact.accounts.first.type)
  //             : 'Local';

  //         return '${contact.displayName},${contact.phones.first.number},$type';
  //       })
  //     ].join('\n');

  //     directory = await getExternalStorageDirectory();
  //     if (directory == null) {
  //       _showSnackBar('Impossible d\'accéder au stockage');
  //       return;
  //     }
  //     String newPath = "";
  //     List<String> folders = directory!.path.split('/');
  //     for (int x = 1; x < folders.length; x++) {
  //       String folder = folders[x];
  //       if (folder != "Android") {
  //         newPath += "/$folder";
  //       } else {
  //         break;
  //       }
  //     }
  //     newPath = "$newPath/contactsPhone";
  //     directory = Directory(newPath);
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //     final file = File('$newPath/contacts.csv');
  //     debugPrint(newPath);
  //     await file.writeAsString(csvContent);
  //     _showSnackBar(
  //         'Fichier CSV exporté avec succès : "Stokage interne/contactsPhone');
  //   } catch (e) {
  //     _showSnackBar('Erreur lors de l\'export : ${e.toString()}');
  //   }
  // }

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
