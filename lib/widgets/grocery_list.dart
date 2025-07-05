import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
      ),
      body: ListView.builder(
          itemBuilder: (ctx, item) => ListTile(
                title: Text(groceryItems[item].name),
                leading: Container(
                  width: 24,
                  height: 24,
                  color: groceryItems[item].category.color,
                ),
                trailing: Text(groceryItems[item].quantity.toString()),
              )),
    );
  }
}
