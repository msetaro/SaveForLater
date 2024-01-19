import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:save_for_later/util/database.dart';
import 'package:save_for_later/util/for_later_tile.dart';
import 'package:save_for_later/util/tile_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final myBox = Hive.box("mybox");
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _reminderIntController = TextEditingController();

  Database db = Database();

  @override
  void initState()
  {
    if(myBox.get("MAINKEY") != null)
    {
      db.loadDataFromStorage();
    }
    super.initState();
  }

  deleteItemFromList(int index)
  {
    setState(() {
      db.storage.removeAt(index);
    });
    db.updateDataAndStore();
  }


  void onCancelPressed()
  {
    _itemNameController.clear();
    _linkController.clear();
    _reminderIntController.clear();
    Navigator.of(context).pop();
  }

  void onSavePressed() 
  {
    // add that data to a new ForLaterTile
    setState(() {
          db.storage.add(
          TileModel(
            emoji: '🩷', 
            customName: _itemNameController.text, 
            linkToProduct: _linkController.text, 
            daysTillNotification: int.parse(_reminderIntController.text)
          )
        );
        _itemNameController.clear();
        _linkController.clear();
        _reminderIntController.clear();
    });
    db.updateDataAndStore();
    Navigator.of(context).pop();
  }

  void createNewItem() {
    showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            height: 500,
            width: 400,
            child: Column(
              children: [
                const Text(
                  "Enter a new item",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  ),
                ),

                // emoji picker -- need to pick random emoji
                const Text('🩷',
                  style: 
                  TextStyle(fontSize: 50)
                ),

                const SizedBox(height: 20),

                // Item name
                TextField(
                  controller: _itemNameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Item name"
                  ),
                ),

                const SizedBox(height: 20),

                // Link
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Link to item"
                  ),
                ),


                const SizedBox(height: 20),

                // Remind in n days
                TextField(
                  controller: _reminderIntController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Remind me in (days)"
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),

                const SizedBox(height: 30),

                // Cancel
                MaterialButton(
                  onPressed: onCancelPressed,
                  minWidth: 200,
                  height: 50,
                  color: Colors.red,
                  child: const Text("Cancel")
                ),

                const SizedBox(height: 17),

                // Save
                MaterialButton(
                  onPressed: onSavePressed,
                  minWidth: 200,
                  height: 50,
                  color: Colors.blue,
                  child: const Text("Save")
                ),

              ]),
          ),
        );
      }
    );
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewItem,
        child: const Icon(Icons.add)),

      backgroundColor: Colors.grey[200],

      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Save For Later"),
        elevation: 0,
      ),

      body: ListView.builder(
          itemCount: db.storage.length,
          itemBuilder: (context, index) {
            return ForLaterTile(
              model: db.storage[index], 
              deleteItem: (context) => deleteItemFromList(index),
            );
          },
      ),
    );
  }
}