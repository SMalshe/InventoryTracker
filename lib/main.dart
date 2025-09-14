import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  runApp(HomeInventoryApp());
}

class HomeInventoryApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Inventory',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryPage(),
    );
  }
}

class InventoryPage extends StatefulWidget {
  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DBHelper().getItems();
    setState(() {
      _items = data;
    });
  }

  void _addItem(String name, String category, double value, String? imagePath) async {
    final item = {
      'name': name,
      'category': category,
      'value': value,
      'imagePath': imagePath,
    };

    await DBHelper().insertItem(item);
    _loadItems(); // refresh UI
  }

void _showAddItemDialog() {
  String name = '';
  String category = '';
  double value = 0;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text("Add Item"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Name"),
              onChanged: (val) => name = val,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Category"),
              onChanged: (val) => category = val,
            ),
            TextField(
              decoration: InputDecoration(labelText: "Amount"),
              keyboardType: TextInputType.number,
              onChanged: (val) => value = double.tryParse(val) ?? 0,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text("Save"),
            onPressed: () async {
              // Create new item map
              final newItem = {
                'name': name,
                'category': category,
                'value': value,
                'imagePath': null, // optional image
              };
              await DBHelper().insertItem(newItem); // insert new item
              _loadItems(); // refresh UI
              Navigator.pop(context); // close dialog
            },
          ),
        ],
      );
    },
  );
}


  void _deleteItem(int id) async {
    await DBHelper().deleteItem(id);
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Inventory")),
      body: _items.isEmpty
          ? Center(child: Text("No items yet. Add some!"))
          : ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("${item['category']} – \$${item['value']}"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteItem(item['id']),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
