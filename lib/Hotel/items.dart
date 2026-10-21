import 'package:flutter/material.dart';

class ItemsScreen extends StatelessWidget {
  ItemsScreen({super.key});

  final List<String> items =
  List<String>.generate(10, (index) => "Item ${index + 1}");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ListItmes'),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 7,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: const Icon(
                  Icons.label_important,
                  color: Colors.blue,
                ),
                title: Text(items[index]),
                subtitle: Text(items[index]),
                trailing: const Icon(Icons.ice_skating),
                tileColor: Colors.white,
                shape:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            );
          }),
    );
  }
}