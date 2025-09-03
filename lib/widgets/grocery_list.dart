import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItem = [];
  bool _isLoading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try {
      final url = Uri.https('grocery-app-c1d37-default-rtdb.firebaseio.com/');
      final response = await http.get(url);
      if (response.statusCode >= 404) {
        setState(() {
          error = "Failed to fetch data. Please try again later";
        });
      }

      if (response.body == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere((e) => e.value.title == item.value['category'])
            .value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category));
      }
      setState(() {
        _groceryItem = loadedItems;
        _isLoading = false;
      });
    } catch (e) {
      print("Exception in loadItems : ${e.toString()}");
      setState(() {
        error = "Something went wrong!. Please try again later";
      });
      // throw Exception("Exception in loadItem : ${e.toString()}");
    }
  }

  void _addItem() async {
    /// for use context we use stateful widget
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (context) => const NewItem()));
    // _loadItems();
    if (newItem == null) {
      return;
    }
    setState(() {
      groceryItems.add(newItem);
    });
  }

  void _removeItme(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });
    final url = Uri.https(
        'grocery-app-c1d37-default-rtdb.firebaseio.com/shopping-list/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      // Optional: show error message
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("No Item added yet."),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
          itemCount: _groceryItem.length,
          itemBuilder: (ctx, item) => Dismissible(
                key: ValueKey(_groceryItem[item]),
                onDismissed: (direction) {
                  _removeItme(_groceryItem[item]);
                },
                child: ListTile(
                  title: Text(_groceryItem[item].name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItem[item].category.color,
                  ),
                  trailing: Text(_groceryItem[item].quantity.toString()),
                ),
              ));
    }

    if (error != null) {
      content = Center(
        child: Text(error!),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Groceries'),
          actions: [
            IconButton(onPressed: _addItem, icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
