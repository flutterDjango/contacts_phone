import 'package:contacts_phone/screens/contacts_screens.dart';
import 'package:flutter/material.dart';

class ContactsPhone extends StatelessWidget {
  const ContactsPhone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Numéros inconnus',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true,),
      // home: const PhoneManagerScreen()
      home: const ContactsScreen()
    );
  }
}