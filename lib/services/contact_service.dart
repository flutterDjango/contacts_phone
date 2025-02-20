import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class ContactService {
  String _simplifyAccountType(String type) {
    final parts = type.split('.');
    return parts.isNotEmpty ? parts.last : type;
  }

  Future<List<Contact>> loadContacts() async {
    bool permissionGranted =
        await FlutterContacts.requestPermission(readonly: true);

    if (!permissionGranted) {
      throw Exception('Permission refusée');
    }

    final allContacts = await FlutterContacts.getContacts(
      withProperties: true,
      withPhoto: false,
      withAccounts: true,
    );

    return allContacts.where((contact) => contact.phones.isNotEmpty).toList();
  }

  Future<String> exportToCsv(List<Contact> contacts) async {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Permission d\'écriture refusée');
    }

    final csvContent = [
      'Nom,Numéro,Type',
      ...contacts.map((contact) {
        final type = contact.accounts.isNotEmpty
            ? _simplifyAccountType(contact.accounts.first.type)
            : 'Local';

        return '${contact.displayName},${contact.phones.first.number},$type';
      })
    ].join('\n');

    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('Impossible d\'accéder au stockage');
    }

    // final timestamp = DateTime.now().millisecondsSinceEpoch;

    // final file = File('${directory.path}/contacts_$timestamp.csv');
    // await file.writeAsString(csvContent);

    String newPath = "";
    List<String> folders = directory!.path.split('/');
    for (int x = 1; x < folders.length; x++) {
      String folder = folders[x];
      if (folder != "Android") {
        newPath += "/$folder";
      } else {
        break;
      }
    }
    newPath = "$newPath/contactsPhone";
    Directory? folder;
    folder = Directory(newPath);
      if (!await folder.exists()) {
        await folder.create(recursive: true);
      }
      final file = File('$newPath/contacts.csv');
      debugPrint(newPath);
      await file.writeAsString(csvContent);
    return file.path;
  }
}
